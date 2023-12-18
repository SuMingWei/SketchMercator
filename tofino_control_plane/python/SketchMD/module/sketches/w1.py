from tofino_control_plane.python.SketchMD.module.common.connection import Connection
from tofino_control_plane.python.SketchMD.module.common.table_register import REGISTER_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_above_threshold import ABOVE_THRESHOLD_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_threshold import THRESHOLD_TABLE
from tofino_control_plane.python.SketchMD.module.common.table_exact import EXACT_TABLE

import socket, threading, thread
from python_lib.perf_timer import PerfTimer
from time import sleep
from data_helper.data_write_helper.result_tofino_dp import file_write
import traceback

is_print = False
# is_print = True

class W1(Connection):

    def __init__(self, args):
        self.program_name = args.program_name
        print(self.program_name)
        self.is_simulator = args.simulator
        super(W1, self).__init__(self.program_name, self.is_simulator)

    ### args.setup -- ports / table_init / configure
    def table_init(self, args):
        print("[PYTHON] [W1] table_init")
        super(W1, self).table_init()
        table_name = "pipe.SwitchIngress.threshold.tbl_get_threshold"
        self.set_threshold_table = THRESHOLD_TABLE(self.gc, self.bfrt_info, table_name, "workload1")
        self.above_threshold_table_list = []
        for d, r in zip([1, 2, 3, 4, 5, 6], [1, 5, 2, 5, 2, 5]):
            table_name = "pipe.SwitchIngress.d_%d_above_threshold.tbl_threshold" % d
            table = ABOVE_THRESHOLD_TABLE(self.gc, self.bfrt_info, table_name, r, "cm")
            self.above_threshold_table_list.append(table)

        self.exact_table_list = [None] # it makes start from 1
        self.dupcheck_dict = {}

        if args.before_after == "before":
            for i in range(1, 7):
                table = EXACT_TABLE(self.gc, self.bfrt_info, i)
                self.exact_table_list.append(table)
                self.dupcheck_dict[i] = []
        else:
            table = EXACT_TABLE(self.gc, self.bfrt_info, 0)
            self.exact_table_list.append(table)
            self.dupcheck_dict[1] = []

    def configure(self, args):
        print("[PYTHON] [W1] configure")
        self.set_threshold_table.configure(args)
        for table in self.above_threshold_table_list:
            table.configure()
    ###


    ### args.digest
    def digest(self, args):
        # global is_print
        # f = open("a.txt", "w+")
        total_digest_count = 0
        prev_epoch_index = -1
        epoch_six_flag = False
        while True:
            # if is_print:
            #     print("[digest] listening")
            msg = self.c._get_stream_message("digest", timeout=3600)
            if msg is not None:
                # if is_print:
                #     print ('[digest] received!')
                digest = msg.digest
                learn_filter = self.bfrt_info.learn_get("heavy_flowkey_digest")
                data_list = learn_filter.make_data_list(digest)
                data_dict = data_list[0].to_dict()

                src_addr, dst_addr, src_port, dst_port, proto = (data_dict['src_addr'], data_dict['dst_addr'], data_dict['src_port'], data_dict['dst_port'], data_dict['proto'])
                epoch_index, epoch_count = (data_dict['epoch_index'], data_dict['epoch_count'])
                total_digest_count += 1

                if total_digest_count % 100 == 0:
                    print("\nepoch_index (%d) epoch_count (%d) before_digest_count(%d) " % (epoch_index, epoch_count, total_digest_count))

                # if dst_port == 45918:
                #     print("\nepoch_index (%d) epoch_count (%d) before_digest_count(%d) " % (epoch_index, epoch_count, total_digest_count))
                #     print(src_addr, dst_addr, src_port, dst_port, proto)
                #     print(data_dict['i01'], data_dict['i02'], data_dict['i03'], data_dict['i04'], data_dict['i05'], data_dict['i06'])

                if epoch_index == 7: # epoch index starts from 0
                    if epoch_six_flag == False:
                        print("[digest] finish, let's write")
                        if args.before_after == "before":
                            for d in range(1, 7):
                                for e in range(0, len(self.dupcheck_dict[d])):
                                    file_path = "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/dupcheck/inst%d/%d.txt" % \
                                        (args.workload_name, args.program_name, args.pcap_name, args.date, d, e)
                                    # if d == 5:
                                    #     print("epoch:", e)
                                    #     for elem in self.dupcheck_dict[d][e]:
                                    #         print(elem)
                                    #     print()
                                    file_write(file_path, self.dupcheck_dict[d][e])

                        else:
                            for i in range(0, epoch_index):
                                print(i, len(self.dupcheck_dict[1][i]))

                                file_path = "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/dupcheck/%d.txt" % \
                                    (args.workload_name, args.program_name, args.pcap_name, args.date, i)
                                file_write(file_path, self.dupcheck_dict[1][i])
                        epoch_six_flag = True
                    # break

                if prev_epoch_index != epoch_index: # reset timing
                    prev_epoch_index = epoch_index
                    print("\nepoch_index (%d) epoch_count (%d) before_digest_count(%d) " % (epoch_index, epoch_count, total_digest_count))
                    total_digest_count = 0

                    print("[digest] reset")
                    if args.before_after == "before":
                        epoch_list = [0, 4, 1, 3, 3, 2, 4]
                        for i in range(1, 7):
                            if epoch_index == 0 or (epoch_index-1) % epoch_list[i] == 0:
                                self.exact_table_list[i].clear()
                                self.dupcheck_dict[i].append(set())
                                # if i == 5:
                                #     print("dupcheck_dict len:", len(self.dupcheck_dict[i]))
                    else:
                        self.exact_table_list[1].clear()
                        self.dupcheck_dict[1].append(set())

                if args.before_after == "before":
                    for i in range(1, 7):
                        if data_dict['i%02d' % i] == 1:
                            if i == 1 or i == 2:
                                key = [src_addr]
                            elif i == 3:
                                key = [src_addr, dst_addr]
                            elif i == 4:
                                key = [src_addr, src_port]
                            elif i == 5:
                                key = [dst_addr, dst_port]
                            elif i == 6:
                                key = [src_addr, dst_addr, src_port, dst_port, proto]
                            
                            if str(key) not in self.dupcheck_dict[i][-1]:
                                # print("new key %s insert to %s" % (str(key), i))
                                # if i == 5 and dst_port == 45918:
                                #     print(key, len(self.dupcheck_dict[i]), "added")
                                self.dupcheck_dict[i][-1].add(str(key))
                                try:
                                    self.exact_table_list[i].add_entry(key)
                                except Exception as e:
                                    if epoch_index <= 6:
                                        traceback.print_exc()
                                        print(epoch_index, i, key)
                else:
                    if epoch_count != 0:
                        key = [src_addr, dst_addr, src_port, dst_port, proto]
                        # print(key)
                        if str(key) not in self.dupcheck_dict[1][-1]:
                            # print("new key, insert")
                            self.dupcheck_dict[1][-1].add(str(key))
                            self.exact_table_list[1].add_entry(key)
