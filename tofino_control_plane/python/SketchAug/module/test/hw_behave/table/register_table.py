import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.SketchAug.module.common.table import Table
from python_lib.perf_timer import PerfTimer

import os

class REGISTER_TABLE(Table):

    def __init__(self, client, bfrt_info, array_size):
        # set up base class
        super(REGISTER_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('REGISTER_TABLE')
        self.logger.info("Setting up register table...")

        self.array_size = array_size
        self.counter_size = 32

        self.pipe_index = 1

        table_string = "pipe.SwitchIngress.update_%d_%d.cs_table" % (self.array_size, self.counter_size)
        self.table = self.bfrt_info.table_get(table_string)

        self.target = client.Target(device_id=0, pipe_id=0xffff)
    
    def reset(self):
        self.table.entry_del(self.target)