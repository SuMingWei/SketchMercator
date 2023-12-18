import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from module.common.table import Table

class THRESHOLD_INSERT(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(THRESHOLD_INSERT, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('THRESHOLD_INSERT')
        self.logger.info("Setting up threshold_insert table...")
        
        # get this table
        self.table = self.bfrt_info.table_get("pipe.SwitchIngress.tbl_get_threshold")
        self.clear()

    def setup(self, date):

        if date == 20140320:
            th = 13324
        if date == 20140619:
            th = 12775
        if date == 20160121:
            th = 9303
        if date == 20180517:
            th = 14688
        if date == 20180816:
            th = 13839

        print("date:", date)
        print("threhsold:", th)

        target = gc.Target(device_id=0, pipe_id=0xffff)

        self.table.entry_add(
            target,
            [self.table.make_key([
                gc.KeyTuple('hdr.ethernet.ether_type', 2048)
                ])],
            [
            self.table.make_data(
                [
                    gc.DataTuple('threshold', th)
                ],
                'tbl_get_threshold_act'
                )
            ]
            )
