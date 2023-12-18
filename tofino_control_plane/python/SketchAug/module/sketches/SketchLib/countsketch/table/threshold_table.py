import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from module.common.table import Table

class THRESHOLD(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(THRESHOLD, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('THRESHOLD')
        self.logger.info("Setting up threshold table...")
        
        # get this table
        self.table = self.bfrt_info.table_get("pipe.SwitchIngress.store_flowkey.tbl_threshold")

        # set format annotations
        # self.table.info.key_field_annotation_add("hdr.ethernet.dst_addr", "mac")

        # clear and add defaults
        self.clear()

    def setup(self):

        target = gc.Target(device_id=0, pipe_id=0xffff)

        print("%6s %6s %6s %6s %6s" % ('c_1', 'c_2', 'c_3', 'c_4', 'c_5'))
        for c1 in [0, 1]:
            for c2 in [0, 1]:
                for c3 in [0, 1]:
                    for c4 in [0, 1]:
                        for c5 in [0, 1]:
                            if c1+c2+c3+c4+c5 <= 2:
                                print("%6d %6d %6d %6d %6d" % (c1, c2, c3, c4, c5))
                                self.table.entry_add(
                                    target,
                                    [self.table.make_key([
                                        gc.KeyTuple('ig_md.c_1', c1),
                                        gc.KeyTuple('ig_md.c_2', c2),
                                        gc.KeyTuple('ig_md.c_3', c3),
                                        gc.KeyTuple('ig_md.c_4', c4),
                                        gc.KeyTuple('ig_md.c_5', c5)
                                        ])],
                                    [
                                    self.table.make_data(
                                        [],
                                        'tbl_threshold_above_action'
                                        )
                                    ]
                                    )
