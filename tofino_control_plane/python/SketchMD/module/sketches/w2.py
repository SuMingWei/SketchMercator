from tofino_control_plane.python.SketchMD.module.common.connection import Connection
from tofino_control_plane.python.SketchMD.module.common.table_register import REGISTER_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_above_threshold import ABOVE_THRESHOLD_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_threshold import THRESHOLD_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_exact import EXACT_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_tcam import TCAM_TABLE

import socket, threading, thread
from python_lib.perf_timer import PerfTimer
from time import sleep
from data_helper.data_write_helper.result_tofino_dp import file_write

is_print = False
# is_print = True

class W2(Connection):

    def __init__(self, args):
        self.program_name = args.program_name
        print(self.program_name)
        self.is_simulator = args.simulator
        super(W2, self).__init__(self.program_name, self.is_simulator)

    ### args.setup -- ports / table_init / configure
    def table_init(self, args):
        print("[PYTHON] [W2] table_init")
        super(W2, self).table_init()

        table_name = "pipe.SwitchIngress.threshold.tbl_get_threshold"
        self.set_threshold_table = THRESHOLD_TABLE(self.gc, self.bfrt_info, table_name, "workload2")

        self.above_threshold_table_list = []
        self.tcam_table_dict = {}
        self.exact_table_dict = {}
        self.dupcheck_dict = {}

        id_list =    [    3,      4,     6,     10]
        type_list =  ["mrb", "mrac", "mrb", "mrac"]
        width_list = [16384,   2048, 16384,   2048]
        level_list = [    8,      8,    16,      8]

        for i, type, width, level in zip(id_list, type_list, width_list, level_list):
            table_name = "pipe.SwitchIngress.d_%d_tcam_lpm.tbl_select_level" % i
            table = TCAM_TABLE(self.gc, self.bfrt_info, table_name, type, width, level, "workload2")
            self.tcam_table_dict[i] = table

        if args.before_after == "before":
            for d, r, type in zip([2, 8, 9], [3, 3, 1], ["cs", "cm", "cm"]):
                table_name = "pipe.SwitchIngress.d_%d_above_threshold.tbl_threshold" % d
                table = ABOVE_THRESHOLD_TABLE(self.gc, self.bfrt_info, table_name, r, type)
                self.above_threshold_table_list.append(table)

            for i in [2, 8, 9]:
                table = EXACT_TABLE(self.gc, self.bfrt_info, i)
                self.exact_table_dict[i] = table
                self.dupcheck_dict[i] = []

        if args.before_after == "after":
            for d, r, type in zip([2, 8], [3, 3], ["cs", "cm"]):
                table_name = "pipe.SwitchIngress.d_%d_above_threshold.tbl_threshold" % d
                table = ABOVE_THRESHOLD_TABLE(self.gc, self.bfrt_info, table_name, r, type)
                self.above_threshold_table_list.append(table)

            self.exact_table_dict[1] = EXACT_TABLE(self.gc, self.bfrt_info, 0)
            self.dupcheck_dict[1] = []

    def configure(self, args):
        print("[PYTHON] [W2] configure")

        self.set_threshold_table.configure(args)

        for table in self.above_threshold_table_list:
            table.configure()

        for i in [    3,      4,     6,     10]:
            self.tcam_table_dict[i].configure(args)



    ### args.digest
    def digest(self, args):
        # global is_print
        # f = open("a.txt", "w+")
        total_digest_count = 0
        prev_epoch_index = -1

        epoch_six_flag = False
        while True:
            if is_print:
                print("[digest] listening")
            msg = self.c._get_stream_message("digest", timeout=3600)
            if msg is not None:
                if is_print:
                    print ('[digest] received!')
                digest = msg.digest
                learn_filter = self.bfrt_info.learn_get("heavy_flowkey_digest")
                data_list = learn_filter.make_data_list(digest)
                data_dict = data_list[0].to_dict()

                dst_addr, dst_port = (data_dict['dst_addr'], data_dict['dst_port'])
                epoch_index, epoch_count = (data_dict['epoch_index'], data_dict['epoch_count'])
                total_digest_count += 1

                if is_print:
                    print("\nepoch_index (%d) epoch_count (%d)" % (epoch_index, epoch_count))
                    print(dst_addr, dst_port)
                    if args.before_after == "before":
                        print(data_dict['i02'], data_dict['i08'], data_dict['i09'])


                if epoch_index == 7: # epoch index starts from 0
                    if epoch_six_flag == False:
                        print("[digest] finish, let's write")
                        if args.before_after == "before":
                            # for d in [6, 7, 8]:
                            for d in [2, 8, 9]:
                                for e in range(0, len(self.dupcheck_dict[d])):
                                    file_path = "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/dupcheck/inst%d/%d.txt" % \
                                        (args.workload_name, args.program_name, args.pcap_name, args.date, d, e)
                                    file_write(file_path, self.dupcheck_dict[d][e])

                        else:
                            for i in range(0, epoch_index):
                                print(i, len(self.dupcheck_dict[1][i]))
                                file_path = "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/dupcheck/%d.txt" % \
                                    (args.workload_name, args.program_name, args.pcap_name, args.date, i)
                                file_write(file_path, self.dupcheck_dict[1][i])
                        epoch_six_flag = True
                    # continue
                    # break

                if prev_epoch_index != epoch_index: # reset timing
                    prev_epoch_index = epoch_index
                    print("\nepoch_index (%d) epoch_count (%d) before_digest_count(%d) " % (epoch_index, epoch_count, total_digest_count))
                    total_digest_count = 0

                    print("[digest] reset")
                    if args.before_after == "before":
                        epoch_dict = {}
                        epoch_dict[2] = 1
                        epoch_dict[8] = 3
                        epoch_dict[9] = 3
                        for i in [2, 8, 9]:
                            if epoch_index == 0 or (epoch_index-1) % epoch_dict[i] == 0:
                                self.exact_table_dict[i].clear()
                                self.dupcheck_dict[i].append(set())
                    else:
                        self.exact_table_dict[1].clear()
                        self.dupcheck_dict[1].append(set())

                if args.before_after == "before":
                    key = [dst_addr, dst_port]
                    for i in [2, 8, 9]:
                        if data_dict['i%02d' % i] == 1:
                            if str(key) not in self.dupcheck_dict[i][-1]:
                                # print("new key %s insert to %s" % (str(key), i))
                                self.dupcheck_dict[i][-1].add(str(key))
                                self.exact_table_dict[i].add_entry(key)

                else:
                    if epoch_count != 0:
                        key = [dst_addr, dst_port]
                        # print(key)
                        if str(key) not in self.dupcheck_dict[1][-1]:
                            # print("new key, insert")
                            self.dupcheck_dict[1][-1].add(str(key))
                            self.exact_table_dict[1].add_entry(key)
