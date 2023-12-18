import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.SketchAug.module.common.table import Table
from python_lib.perf_timer import PerfTimer

import os

class REGISTER_INDEX_TABLE(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(REGISTER_INDEX_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('REGISTER_INDEX_TABLE')
        self.logger.info("Setting up register table...")

        self.pipe_index = 1

        table_string = "pipe.SwitchIngress.epoch_count_1.cs_table"
        self.table = self.bfrt_info.table_get(table_string)
        self.target = client.Target(device_id=0, pipe_id=0xffff)

    def write(self, index, val):
        print("[write] %d" % val)
        self.table.entry_add(
            self.target,
            [
                self.table.make_key(
                    [gc.KeyTuple('$REGISTER_INDEX', index)]
                )
            ],
            [
                self.table.make_data(
                    [gc.DataTuple('SwitchIngress.epoch_count_1.cs_table.f1', val)]
                )
            ]
        )

    def bulk_read_SW(self):

        self.table.operations_execute(self.target, 'Sync')
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": False})

        timer = PerfTimer("read")
        data, _ = next(resp)
        data_dict = data.to_dict()
        data_per_pipe = data_dict[u'SwitchIngress.epoch_count_1.cs_table.f1']
        counter = data_per_pipe[self.pipe_index]
        if(counter & 0x80000000):
            counter = -0x100000000 + counter
        print("[read (bulk) (cache)] %d" % counter)

    def read_HW(self):
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": True})

        timer = PerfTimer("read")
        data, _ = next(resp)
        data_dict = data.to_dict()
        data_per_pipe = data_dict[u'SwitchIngress.epoch_count_1.cs_table.f1']
        counter = data_per_pipe[self.pipe_index]
        if(counter & 0x80000000):
            counter = -0x100000000 + counter
        print("[read (HW)] %d" % counter)

    def read_SW(self):
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": False})

        timer = PerfTimer("read")
        data, _ = next(resp)
        data_dict = data.to_dict()
        data_per_pipe = data_dict[u'SwitchIngress.epoch_count_1.cs_table.f1']
        counter = data_per_pipe[self.pipe_index]
        if(counter & 0x80000000):
            counter = -0x100000000 + counter
        print("[read (cache)] %d" % counter)
