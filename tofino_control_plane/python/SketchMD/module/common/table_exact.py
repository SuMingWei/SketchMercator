import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from module.common.table import Table

class EXACT_TABLE(Table):

    def __init__(self, client, bfrt_info, d):
        # set up base class
        super(EXACT_TABLE, self).__init__(client, bfrt_info)
        self.d = d
        if d == 0:
            table_name = "pipe.SwitchIngress.heavy_flowkey_storage.tbl_exact_match"
        else:
            table_name = "pipe.SwitchIngress.heavy_flowkey_storage_%d.tbl_exact_match" % d
        print("[PYTHON] table init - %s" % table_name)
        self.table = self.bfrt_info.table_get(table_name)

        self.target = client.Target(device_id=0, pipe_id=0xffff)
    def add_entry(self, key_list):
        entry_list = []
        for i, key_entry in enumerate(key_list, 1):
            entry_list.append(gc.KeyTuple('key%d' % i, key_entry))

        if self.d == 0:
            action_name_str = 'SwitchIngress.heavy_flowkey_storage.tbl_exact_match_hit'
        else:
            action_name_str = 'SwitchIngress.heavy_flowkey_storage_%d.tbl_exact_match_hit' % self.d

        self.table.entry_add(
            self.target,
            [self.table.make_key(
                entry_list
                )
            ],
            [self.table.make_data(action_name=action_name_str)]
            )
