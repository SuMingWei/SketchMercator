import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

import sys

from tofino_control_plane.python.SketchMD.module.common.table import Table

class BITMASK_TABLE(Table):

    def __init__(self, client, bfrt_info, table_name):
        super(BITMASK_TABLE, self).__init__(client, bfrt_info)

        print("[PYTHON] table init - %s" % table_name)
        self.table = self.bfrt_info.table_get(table_name)
        self.table_name = table_name

    def configure(self):
        target = gc.Target(device_id=0, pipe_id=0xffff)
        print("Configure - %s" % self.table_name)
        self.clear()
        level_list = [i for i in range(0, 32)]
        bitmask_list = []
        for level in level_list:
            bitmask_list.append(1 << level)
        print("%10s %34s" % ("level", "bitmask"))

        for level, bitmask in zip(level_list, bitmask_list):
            hash_string = str(bin(bitmask))

            print("%10d %34s" % (level, hash_string))
            self.table.entry_add(
                target,
                [
                self.table.make_key(
                    [gc.KeyTuple('level', level)]
                    )
                ],
                [
                self.table.make_data(
                    [
                        gc.DataTuple('bitmask', bitmask)
                    ],
                    'tbl_act'
                    )
                ]
                )
