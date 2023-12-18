import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.SketchAug.module.common.table import Table
from python_lib.perf_timer import PerfTimer

import os

from data_helper.data_write_helper.result_tofino_dp import TofinoDPDataWriteHelper

class REGISTER_TABLE(Table):

    def __init__(self, client, bfrt_info, array_size, counter_size, small_or_large):
        # set up base class
        super(REGISTER_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('REGISTER_TABLE')
        self.logger.info("Setting up register table...")

        self.array_size = array_size
        self.counter_size = counter_size

        self.pipe_index = 1

        table_string = "pipe.SwitchIngress.update_%d_%d.cs_table" % (self.array_size, self.counter_size)
        self.table = self.bfrt_info.table_get(table_string)

        self.small_or_large = small_or_large

        self.target = client.Target(device_id=0, pipe_id=0xffff)

        self.result1 = []
        self.result2 = []
        self.result3 = []

    def read(self, resp, title):

        self.counters = []
        self.counters_1 = []
        self.counters_2 = []

        timer = PerfTimer(title)
        for i in range(0, self.array_size):
            if i == 0 or i == 1 or i == 2 or (i+1) % 5000 == 0:
                print(i+1, timer.lap_micro_string())
            data, _ = next(resp)
            data_dict = data.to_dict()
            # print(data_dict)
            # {'is_default_entry': False, u'SwitchIngress.update_4096_64.cs_table.second': [0, 0], u'SwitchIngress.update_4096_64.cs_table.first': [0, 0], 'action_name': None}
            # {'is_default_entry': False, u'SwitchIngress.update_1.cs_table.f1': [0, 0, 0, 0], 'action_name': None}

            if self.small_or_large == "small":
                data_per_pipe = data_dict[u'SwitchIngress.update_%d_%d.cs_table.f1' % (self.array_size, self.counter_size)]
                counter = data_per_pipe[self.pipe_index]
                if(counter & 0x80000000):
                    counter = -0x100000000 + counter
                self.counters.append(counter)

            if self.small_or_large == "large":
                data_per_pipe_1 = data_dict[u'SwitchIngress.update_%d_%d.cs_table.first' % (self.array_size, self.counter_size)]
                counter_1 = data_per_pipe_1[self.pipe_index]
                if(counter_1 & 0x80000000):
                    counter_1 = -0x100000000 + counter_1
                self.counters_1.append(counter_1)

                data_per_pipe_2 = data_dict[u'SwitchIngress.update_%d_%d.cs_table.second' % (self.array_size, self.counter_size)]
                counter_2 = data_per_pipe_2[self.pipe_index]
                if(counter_2 & 0x80000000):
                    counter_2 = -0x100000000 + counter_2
                self.counters_2.append(counter_2)

        print(i+1, timer.lap_micro_string())

        file_helper = TofinoDPDataWriteHelper(self.array_size, self.counter_size, title)
        if self.small_or_large == "small":
            file_helper.write(self.counters)
        if self.small_or_large == "large":
            file_helper.write_2(self.counters_1, self.counters_2)



    def delay_test_1(self):
        self.table.operations_execute(self.target, 'Sync')
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": False})
        self.read(resp, 'delay_test_1')


    def delay_test_2(self):
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": True})
        self.read(resp, 'delay_test_2')
    

    def delay_test_3(self):
        timer = PerfTimer('Delay test 3')
        self.table.operations_execute(self.target, 'Sync')
        for i in range(0, self.array_size):
            if i == 0 or i == 1 or i == 2 or (i+1) % 5000 == 0:
                print(i+1, timer.lap_micro_string())
            resp = self.table.entry_get(
                self.target,
                [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', i)])],
                {"from_hw": False})
        print(i+1, timer.lap_micro_string())

    def delay_test_4(self):
        timer = PerfTimer('Delay test 4')
        for i in range(0, self.array_size):
            if i == 0 or i == 1 or i == 2 or (i+1) % 5000 == 0:
                print(i+1, timer.lap_micro_string())
            resp = self.table.entry_get(
                self.target,
                [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', i)])],
                {"from_hw": True})
        print(i+1, timer.lap_micro_string())

    def reset_test(self):
        timer = PerfTimer('Counter Register Clear')
        self.table.entry_del(self.target)
        print(timer.lap_micro_string())
        


            # if i < 10:
            #     data_dict = next(resp)[0].to_dict()
            #     print(data_dict)
            # else:
            #     break
            # if i < 10:
            #     data_dict = next(resp)[0].to_dict()
            #     print(data_dict)
            # else:
            #     break

            # if i < 10:
            #     print(data)
            # else:
            #     break
            # data_dict = data.to_dict()
            # # print(data_dict) # {'is_default_entry': False, u'SwitchIngress.update_1.cs_table.f1': [0, 0, 0, 0], 'action_name': None}
            # data_per_pipe = data_dict[u'SwitchIngress.update_%d.cs_table.f1' % self.cs_index]
            # counter = data_per_pipe[self.pipe_index]
            # if(counter & 0x80000000):
            #     counter = -0x100000000 + counter
            # if counter != 0:
            #     print(i, counter)
            # print(counter)
            # if (counter != 0):
            #     print(i, counter)
            # self.counters.append(counter)
            # self.counters.append(1)

            # data_dict = next(resp)[0].to_dict()

            # print(data_dict)

    #     # print(timer.lap_micro_string())

    #     # ret = timer.lap_micro()
    #     # self.result1.append(ret)

    #     # timer.lap_10_milli()
    #     # print(timer.lap_micro_string())

    #     # self.timer2 = PerfTimer('Between')
    #     # self.result2.append(self.timer2.lap_micro())

    #     # from datetime import datetime
    #     # t1 = datetime.now()
    #     # t2 = datetime.now()
    #     # print(t2 - t1)

    #     # result = []
    #     # timer = PerfTimer('Counter Register Clear')

    #     # self.table.entry_del(self.target)

    #     # # resp = self.table.entry_get(
    #     # #     self.target,
    #     # #     [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', 2047)])],
    #     # #     {"from_hw": True})
    #     # # data_dict = next(resp)[0].to_dict()
    #     # # print(data_dict)


    #     # ret = timer.lap_micro()
    #     # self.result3.append(ret)
    #     # # print("clear result")
    #     # # print(result)
    #     #     # print()
