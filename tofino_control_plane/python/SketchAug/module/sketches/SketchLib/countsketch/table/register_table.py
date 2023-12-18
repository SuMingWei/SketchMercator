import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from module.common.table import Table
from perf_timer import PerfTimer

import os

class REGISTER_TABLE(Table):

    def __init__(self, client, bfrt_info, cs_index, simulator):
        # set up base class
        super(REGISTER_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('REGISTER_TABLE')
        self.logger.info("Setting up register table...")
        
        self.cs_index = cs_index
        self.simulator = simulator

        # if simulator == 1:
        #     self.pipe_index = 0
        # else:
        #     self.pipe_index = 1
        self.pipe_index = 1

        table_string = "pipe.SwitchIngress.update_%d.cs_table" % cs_index
        self.table = self.bfrt_info.table_get(table_string)

        # set format annotations
        # self.table.info.key_field_annotation_add("hdr.ethernet.dst_addr", "mac")

        # clear and add defaults
        # self.clear()
        self.target = client.Target(device_id=0, pipe_id=0xffff)

        self.result1 = []
        self.result2 = []
        self.result3 = []

    def delay_test(self):
        timer = PerfTimer('Counter Register Load')
        # self.table.operations_execute(self.target, 'Sync')

        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": True})

        self.counters = []

        # for i in range(0, 2048):
        for i in range(0, 4096):
        # for i in range(0, 8192):
        # for i in range(0, 12288):
        # for i in range(0, 16384):
        # for i in range(0, 20480):
        # for i in range(0, 32768):
        # for i in range(0, 36864):
        # for i in range(0, 65536):
            pass
            if i % 1000 == 0:
                print(i, timer.lap_10_milli_string())
            # if i == 100:
            #     break
            data, _ = next(resp)
            if i == 0:
                print(i, timer.lap_10_milli_string())

            data_dict = data.to_dict()
            # print(data_dict) # {'is_default_entry': False, u'SwitchIngress.update_1.cs_table.f1': [0, 0, 0, 0], 'action_name': None}
            data_per_pipe = data_dict[u'SwitchIngress.update_%d.cs_table.f1' % self.cs_index]
            counter = data_per_pipe[self.pipe_index]
            if(counter & 0x80000000):
                counter = -0x100000000 + counter
            # if counter != 0:
            #     print(i, counter)
            # print(counter)
            # if (counter != 0):
            #     print(i, counter)
            self.counters.append(counter)
            # self.counters.append(1)

        ret = timer.lap_micro()
        self.result1.append(ret)

        timer.lap_10_milli()
        print(timer.lap_micro_string())

        self.timer2 = PerfTimer('Between')
        self.result2.append(self.timer2.lap_micro())

        from datetime import datetime
        t1 = datetime.now()
        t2 = datetime.now()
        print(t2 - t1)

        result = []
        timer = PerfTimer('Counter Register Clear')

        self.table.entry_del(self.target)

        # resp = self.table.entry_get(
        #     self.target,
        #     [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', 2047)])],
        #     {"from_hw": True})
        # data_dict = next(resp)[0].to_dict()
        # print(data_dict)


        ret = timer.lap_micro()
        self.result3.append(ret)
        # print("clear result")
        # print(result)
            # print()

    def load_registers(self):

        timer = PerfTimer('Counter Register Load')
        # self.table.operations_execute(self.target, 'Sync')

        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": True})

        self.counters = []

        for i in range(0, 4096):
            if i % 1000 == 0:
                print(i, timer.lap_10_milli_string())
            # if i == 100:
            #     break
            data, _ = next(resp)
            if i == 0:
                print(i, timer.lap_10_milli_string())

            data_dict = data.to_dict()
            # print(data_dict) # {'is_default_entry': False, u'SwitchIngress.update_1.cs_table.f1': [0, 0, 0, 0], 'action_name': None}
            data_per_pipe = data_dict[u'SwitchIngress.update_%d.cs_table.f1' % self.cs_index]
            counter = data_per_pipe[self.pipe_index]
            if(counter & 0x80000000):
                counter = -0x100000000 + counter
            # if counter != 0:
            #     print(i, counter)
            # print(counter)
            if (counter != 0):
                print(i, counter)
            self.counters.append(counter)

        timer.lap_10_milli()

    def tableClear(self):
        self.table.entry_del(self.target)

    def save_to_file(self, folder_name, file_name):

        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        full_path = os.path.join(folder_name, file_name)

        f = open(full_path, "w")
        for i in range(0, 4096):
            f.write(str(self.counters[i]) + '\n')
        f.close()

