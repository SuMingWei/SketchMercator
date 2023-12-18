import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

import os

from tofino_control_plane.python.SketchMD.module.common.table import Table

class REGISTER_TABLE(Table):

    def __init__(self, client, bfrt_info, table_name, table_string, size):
        super(REGISTER_TABLE, self).__init__(client, bfrt_info)

        print("[PYTHON] [Register Table Init] [%s(%d)] [%s]" % (table_name, size, table_string))

        self.table_name = table_name
        self.table_string = table_string
        self.key = unicode(table_string+'.f1')
        self.size = size

        self.pipe_index = 1
        self.table = self.bfrt_info.table_get(table_string)
        self.target = client.Target(device_id=0, pipe_id=0xffff)

    def read(self, index):
        counter_list = []
        self.table.operations_execute(self.target, 'Sync')
        resp = self.table.entry_get(
            self.target,
            [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', index)])],
            {"from_hw": False})
        data, _ = next(resp)

        data_dict = data.to_dict()
        data_per_pipe = data_dict[self.key]
        counter = data_per_pipe[self.pipe_index]
        if(counter & 0x80000000):
            counter = -0x100000000 + counter
        return counter

    def read_whole(self):
        counter_list = []
        self.table.operations_execute(self.target, 'Sync')
        for i in range(0, self.size):
            resp = self.table.entry_get(
                self.target,
                [self.table.make_key([gc.KeyTuple('$REGISTER_INDEX', i)])],
                {"from_hw": False})
            data, _ = next(resp)

            data_dict = data.to_dict()
            data_per_pipe = data_dict[self.key]
            counter = data_per_pipe[self.pipe_index]
            if(counter & 0x80000000):
                counter = -0x100000000 + counter
            if counter != 0:
                print(i, counter)
            counter_list.append(counter)
        return counter_list

    def write(self, index, val):
        self.table.entry_add(
            self.target,
            [
                self.table.make_key(
                    [gc.KeyTuple('$REGISTER_INDEX', index)]
                )
            ],
            [
                self.table.make_data(
                    [gc.DataTuple(self.key, val)]
                )
            ]
        )
    def reg_clear(self):
        self.table.entry_del(self.target)
