import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.SketchAug.module.common.table import Table
from python_lib.perf_timer import PerfTimer

import os

from data_helper.data_write_helper.result_tofino_dp import TofinoDPCounterWriteHelper

class REGISTER_COUNT_TABLE(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(REGISTER_COUNT_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('REGISTER_COUNT_TABLE')
        self.logger.info("Setting up register table...")

        self.pipe_index = 1

        table_string = "pipe.SwitchIngress.epoch_count_2.cs_table"
        self.table = self.bfrt_info.table_get(table_string)
        self.target = client.Target(device_id=0, pipe_id=0xffff)

    def read(self, size, epoch, api):
        counter_list = []
        print("read " + "pipe.SwitchIngress.epoch_count_2.cs_table")
        self.table.operations_execute(self.target, 'Sync')
        for i in range(0, 100):
            resp = self.table.entry_get(
                self.target,
                [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', i)])],
                {"from_hw": False})
            data, _ = next(resp)
            data_dict = data.to_dict()
            data_per_pipe = data_dict[u'SwitchIngress.epoch_count_2.cs_table.f1']
            counter = data_per_pipe[self.pipe_index]
            if(counter & 0x80000000):
                counter = -0x100000000 + counter
            if counter != 0:
                print(i, counter)
            counter_list.append(counter)

        file_helper = TofinoDPCounterWriteHelper("mrb", api, size, epoch)
        file_helper.write(counter_list)
