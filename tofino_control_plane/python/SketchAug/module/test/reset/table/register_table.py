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

    def __init__(self, client, bfrt_info, array_size):
        # set up base class
        super(REGISTER_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('REGISTER_TABLE')
        self.logger.info("Setting up register table...")

        self.array_size = array_size

        self.pipe_index = 1

        table_string = "pipe.SwitchIngress.update_%d.cs_table" % (self.array_size)
        self.table = self.bfrt_info.table_get(table_string)

        self.target = client.Target(device_id=0, pipe_id=0xffff)

        self.result1 = []
        self.result2 = []
        self.result3 = []

    def read(self, epoch, count):
        self.table.operations_execute(self.target, 'Sync')
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": False})

        self.counters = []

        timer = PerfTimer("read")
        for i in range(0, self.array_size):
            data, _ = next(resp)
            data_dict = data.to_dict()
            # print(data_dict)
            # {'is_default_entry': False, u'SwitchIngress.update_4096_64.cs_table.second': [0, 0], u'SwitchIngress.update_4096_64.cs_table.first': [0, 0], 'action_name': None}
            # {'is_default_entry': False, u'SwitchIngress.update_1.cs_table.f1': [0, 0, 0, 0], 'action_name': None}

            data_per_pipe = data_dict[u'SwitchIngress.update_%d.cs_table.f1' % (self.array_size)]
            counter = data_per_pipe[self.pipe_index]
            if(counter & 0x80000000):
                counter = -0x100000000 + counter
            # print(counter)
            self.counters.append(counter)

        print(i+1, timer.lap_micro_string())

        file_helper = TofinoDPDataWriteHelper("mrb", self.array_size, epoch, count)
        file_helper.write(self.counters)

    def reset(self):
        self.table.entry_del(self.target)
