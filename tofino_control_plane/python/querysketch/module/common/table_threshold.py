import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.querysketch.module.common.table import Table

class THRESHOLD_TABLE(Table):

    def __init__(self, client, bfrt_info, table_name, type):
        # set up base class
        super(THRESHOLD_TABLE, self).__init__(client, bfrt_info)

        print("[PYTHON] table init - %s" % table_name)
        self.table = self.bfrt_info.table_get(table_name)
        self.table_name = table_name
        self.type = type

    def configure(self, args):
        target = gc.Target(device_id=0, pipe_id=0xffff)
        print("Configure - %s" % self.table_name)
        self.clear()
        if self.type == "workload1":
            if args.caida_date == "20140320":
                threshold_list = [0, 17018, 4599628, 8050832, 12764416, 5462468, 8351]

            elif args.caida_date == "20160121":
                threshold_list = [0, 16939, 2267822, 9596016, 9694968, 7463342, 12391]

            elif args.caida_date == "20140619":
                threshold_list = [0, 17753, 5542456, 9251356, 15167964, 7206120, 10215]

            elif args.caida_date == "20180517":
                threshold_list = [0, 23575, 6585421, 15272393, 18613932, 10324432, 15230]

            elif args.caida_date == "20180816":
                threshold_list = [0, 22809, 6747358, 14255800, 19171844, 10041000, 14925]

            self.table.entry_add(
                target,
                [self.table.make_key([
                    gc.KeyTuple('hdr.ethernet.ether_type', 2048)
                    ])],
                [
                self.table.make_data(
                    [
                        gc.DataTuple('threshold_1', threshold_list[1]),
                        gc.DataTuple('threshold_2', threshold_list[2]),
                        gc.DataTuple('threshold_3', threshold_list[3]),
                        gc.DataTuple('threshold_4', threshold_list[4]),
                        gc.DataTuple('threshold_5', threshold_list[5]),
                        gc.DataTuple('threshold_6', threshold_list[6]),
                    ],
                    'tbl_get_threshold_act'
                    )
                ]
                )

        elif self.type == "workload2":
            if args.caida_date == "20140320":
                threshold_list = [0, 3929, 8894895, 8894895]

            elif args.caida_date == "20140619":
                threshold_list = [0, 4845, 10443836, 10443836]

            elif args.caida_date == "20160121":
                threshold_list = [0, 4400, 10443836, 10443836]
                # threshold_list = [0, 4845, 10443836, 10443836]

            elif args.caida_date == "20180517":
                threshold_list = [0, 3843, 14930897, 15361041]

            elif args.caida_date == "20180816":
                # threshold_list = [0, 3714, 14044876, 15012184]
                threshold_list = [0, 3714, 18091632, 18091632]
            self.table.entry_add(
            target,
            [self.table.make_key([
                gc.KeyTuple('hdr.ethernet.ether_type', 2048)
                ])],
            [
            self.table.make_data(
                [
                    gc.DataTuple('threshold_2', threshold_list[1]),
                    gc.DataTuple('threshold_8', threshold_list[2]),
                    gc.DataTuple('threshold_9', threshold_list[3]),
                ],
                'tbl_get_threshold_act'
                )
            ]
            )


        elif self.type == "workload4":
            if args.caida_date == "20140320":
                threshold_list = [0, 5600]

            if args.caida_date == "20140619":
                # threshold_list = [0, 6751]
                threshold_list = [0, 6000]

            if args.caida_date == "20160121":
                # threshold_list = [0, 9064]
                threshold_list = [0, 8300]

            if args.caida_date == "20180517":
                # threshold_list = [0, 9997]
                threshold_list = [0, 7000]

            if args.caida_date == "20180816":
                # threshold_list = [0, 8880]
                threshold_list = [0, 6900]

            self.table.entry_add(
                target,
                [self.table.make_key([
                    gc.KeyTuple('hdr.ethernet.ether_type', 2048)
                    ])],
                [
                self.table.make_data(
                    [
                        gc.DataTuple('threshold_8', threshold_list[1]),
                    ],
                    'tbl_get_threshold_act'
                    )
                ]
                )
