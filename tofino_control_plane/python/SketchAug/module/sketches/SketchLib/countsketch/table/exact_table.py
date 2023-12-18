import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from module.common.table import Table

class EXACT_TABLE(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(EXACT_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('EXACT_TABLE')
        self.logger.info("Setting up tbl_exact_match table...")
        
        # get this table
        self.table = self.bfrt_info.table_get("pipe.SwitchIngress.store_flowkey.tbl_exact_match")

        # set format annotations
        # self.table.info.key_field_annotation_add("hdr.ipv4.src_addr", "ipv4")

        self.target = client.Target(device_id=0, pipe_id=0xffff)

        # clear and add defaults
        self.clear()
        
    def add_entry(self, ipv4_addr):
        # target all pipes on device 0
        # target = gc.Target(device_id=0, pipe_id=0xffff)
        
        self.table.entry_add(
            self.target,
            [self.table.make_key(
                [gc.KeyTuple('hdr.ipv4.src_addr', ipv4_addr)]
                )
            ],
            [self.table.make_data(action_name='SwitchIngress.store_flowkey.tbl_exact_match_hit')]
            # [self.table.make_data([gc.DataTuple('dummy', 1)],'SwitchIngress.store_flowkey.tbl_exact_match_hit')]
            )

    def tableClear(self):
        self.table.entry_del(self.target)
