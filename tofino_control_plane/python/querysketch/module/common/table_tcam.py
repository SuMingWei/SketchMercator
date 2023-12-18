import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

import sys

from tofino_control_plane.python.querysketch.module.common.table import Table

class TCAM_TABLE(Table):

    def __init__(self, client, bfrt_info, table_name, type, width, level, workload_name):
        super(TCAM_TABLE, self).__init__(client, bfrt_info)

        print("[PYTHON] table init - %s" % table_name)
        self.table = self.bfrt_info.table_get(table_name)
        self.table_name = table_name
        self.type = type
        self.width = width
        self.level = level
        self.workload_name = workload_name

    def configure(self, args):
        target = gc.Target(device_id=0, pipe_id=0xffff)
        print("Configure - %s" % self.table_name)
        self.clear()

        if self.type == "mrb" or self.type == "mrac" or self.type == "um":
            sampling_hash_list = [0]
            p_length_list = [1]
            level_list = [0]

            one_bit_list = []
            for i in range(1, self.level): # 1 ~ level-1
                one_bit_list.append(1 << (16-i))
            
            for i in range(1, self.level): # 1 ~ level-2
                temp = one_bit_list[0]
                for j in range(1, i):
                    temp = temp | one_bit_list[j]
                sampling_hash_list.append(temp)
                level_list.append(i)
                if i == self.level-1:
                    p_length_list.append(i)
                else:
                    p_length_list.append(i+1)

            if self.type == "mrb" or self.type == "mrac":
                print("%18s %10s %10s %10s" % ("s_hash", "p_length", "level", "base"))

                for s_hash, length, level in zip(sampling_hash_list, p_length_list, level_list):
                    if s_hash == 0:
                        hash_string = "0b0000000000000000"
                    else:
                        hash_string = str(bin(s_hash))

                    print("%18s %10d %10d %10d" % (hash_string, length, level, level * self.width))

                    self.table.entry_add(
                        target,
                        [
                        self.table.make_key(
                            [gc.KeyTuple('sampling_hash', s_hash, prefix_len=length)]
                            )
                        ],
                        [
                        self.table.make_data(
                            [
                                gc.DataTuple('base', level * self.width)
                            ],
                            'tbl_act'
                            )
                        ]
                        )
            if self.type == "um":
                # print("come??", self.workload_name)
                print("%18s %10s %10s %10s %10s" % ("s_hash", "p_length", "level", "base", "threshold"))
                if self.workload_name == "workload3":
                    if args.caida_date == "20140320":
                        if self.table_name == "pipe.SwitchIngress.d_4_tcam_lpm.tbl_select_level":
                            threshold_list = [4779, 3691, 2216, 1413, 921, 368, 212, 87, 39, 18, 6, 1, 0, 0, 0, 0]
                        if self.table_name == "pipe.SwitchIngress.d_5_tcam_lpm.tbl_select_level":
                            threshold_list = [7549, 4470, 2499, 1334, 712, 337, 126, 51, 23, 10, 6, 2, 1, 0, 0, 0]

                    if args.caida_date == "20140619":
                        if self.table_name == "pipe.SwitchIngress.d_4_tcam_lpm.tbl_select_level":
                            threshold_list = [5995, 4177, 2489, 1611, 1122, 479, 224, 120, 44, 22, 9, 2, 0, 0, 0, 0]
                        if self.table_name == "pipe.SwitchIngress.d_5_tcam_lpm.tbl_select_level":
                            threshold_list = [7841, 5188, 2578, 1585, 747, 360, 176, 70, 28, 11, 8, 3, 1, 0, 0, 0]

                    if args.caida_date == "20160121":
                        if self.table_name == "pipe.SwitchIngress.d_4_tcam_lpm.tbl_select_level":
                            # threshold_list = [7491, 4384, 2959, 1435, 743, 343, 217, 112, 40, 14, 7, 1, 0, 0, 0, 0]
                            threshold_list = [7000, 4384, 2959, 1435, 743, 343, 217, 112, 40, 14, 7, 1, 0, 0, 0, 0]
                        if self.table_name == "pipe.SwitchIngress.d_5_tcam_lpm.tbl_select_level":
                            threshold_list = [6862, 5143, 2637, 1429, 813, 417, 205, 74, 40, 16, 7, 3, 0, 0, 0, 0]

                    if args.caida_date == "20180517":
                        if self.table_name == "pipe.SwitchIngress.d_4_tcam_lpm.tbl_select_level":
                            # threshold_list = [8200, 4708, 2987, 2190, 975, 432, 210, 60, 27, 10, 6, 2, 0, 0, 0, 0]
                            threshold_list = [7000, 4708, 2987, 2190, 975, 432, 210, 60, 27, 10, 6, 2, 0, 0, 0, 0]
                        if self.table_name == "pipe.SwitchIngress.d_5_tcam_lpm.tbl_select_level":
                            threshold_list = [10757, 5590, 3946, 2496, 1156, 518, 186, 53, 17, 8, 3, 1, 0, 0, 0, 0]

                    if args.caida_date == "20180816":
                        if self.table_name == "pipe.SwitchIngress.d_4_tcam_lpm.tbl_select_level":
                            threshold_list = [7359, 4369, 2898, 1795, 1054, 392, 178, 54, 20, 15, 6, 2, 1, 0, 0, 0]
                        if self.table_name == "pipe.SwitchIngress.d_5_tcam_lpm.tbl_select_level":
                            threshold_list = [9435, 6067, 3473, 2493, 1025, 544, 131, 48, 20, 6, 4, 1, 0, 0, 0, 0]

                for s_hash, length, level, threshold in zip(sampling_hash_list, p_length_list, level_list, threshold_list):
                    if s_hash == 0:
                        hash_string = "0b0000000000000000"
                    else:
                        hash_string = str(bin(s_hash))

                    print("%18s %10d %10d %10d %10d" % (hash_string, length, level, level * self.width, threshold))

                    self.table.entry_add(
                        target,
                        [
                        self.table.make_key(
                            [gc.KeyTuple('sampling_hash', s_hash, prefix_len=length)]
                            )
                        ],
                        [
                        self.table.make_data(
                            [
                                gc.DataTuple('base', level * self.width),
                                gc.DataTuple('threshold', threshold)
                            ],
                            'tbl_act'
                            )
                        ]
                        )
        if self.type == "hll" or self.type == "pcsa":
            sampling_hash_list = [0]
            p_length_list = [1]
            level_list = [0]

            one_bit_list = []
            for i in range(1, 32): # 1 ~ level-1
                one_bit_list.append(1 << (32-i))
            
            for i in range(1, 32): # 1 ~ level-2
                temp = one_bit_list[0]
                for j in range(1, i):
                    temp = temp | one_bit_list[j]
                sampling_hash_list.append(temp)
                level_list.append(i)
                if i == self.level-1:
                    p_length_list.append(i)
                else:
                    p_length_list.append(i+1)

            print("%34s %10s %10s" % ("s_hash", "p_length", "level"))

            for s_hash, length, level in zip(sampling_hash_list, p_length_list, level_list):
                if s_hash == 0:
                    hash_string = "0b00000000000000000000000000000000"
                else:
                    hash_string = str(bin(s_hash))

                print("%34s %10d %10d" % (hash_string, length, level))
                self.table.entry_add(
                    target,
                    [
                    self.table.make_key(
                        [gc.KeyTuple('sampling_hash', s_hash, prefix_len=length)]
                        )
                    ],
                    [
                    self.table.make_data(
                        [
                            gc.DataTuple('level', level)
                        ],
                        'tbl_act'
                        )
                    ]
                    )
            pass
