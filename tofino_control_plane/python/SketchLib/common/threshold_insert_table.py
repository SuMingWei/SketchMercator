import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.SketchAug.SketchLib.common.table import Table

class THRESHOLD_INSERT(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(THRESHOLD_INSERT, self).__init__(client, bfrt_info)

        self.table = self.bfrt_info.table_get("pipe.SwitchIngress.get_threshold.tbl_get_threshold")
        self.clear()

    def setup(self, threshold):

        target = gc.Target(device_id=0, pipe_id=0xffff)

        self.table.entry_add(
            target,
            [self.table.make_key([
                gc.KeyTuple('hdr.ethernet.ether_type', 2048)
                ])],
            [
            self.table.make_data(
                [
                    gc.DataTuple('threshold', threshold)
                ],
                'tbl_get_threshold_act'
                )
            ]
            )
