import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

import sys

from tofino_control_plane.python.SketchAug.module.common.table import Table

class TCAM(Table):

    def __init__(self, client, bfrt_info):
        # set up base class
        super(TCAM, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('TCAM')
        self.logger.info("Setting up tcam table...")
        
        # get this table
        self.table = self.bfrt_info.table_get("pipe.SwitchIngress.tcam.tbl_select_level")
        self.target = client.Target(device_id=0, pipe_id=0xffff)

    def setup_hll(self):
        self.clear()
        one_bit_list = []
        for i in range(1, 21):
            one_bit_list.append(1 << (20-i))
        print(one_bit_list)

        sampling_hash_list = [0]
        p_length_list = [1]
        level_list = [0]

        for i in range(1, 20):
            temp = one_bit_list[0]
            for j in range(1, i):
                temp = temp | one_bit_list[j]
            sampling_hash_list.append(temp)
            p_length_list.append(i+1)
            level_list.append(i)
        sampling_hash_list.append(1048575)
        p_length_list.append(20)
        level_list.append(20)


        print("%6s %6s %6s" % ("s_hash", "p_length", "level"))

        target = gc.Target(device_id=0, pipe_id=0xffff)

        for s_hash, length, lev in zip(sampling_hash_list, p_length_list, level_list):
            print("%6s %6s %6s" % (s_hash, length, lev))
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
                        gc.DataTuple('level', lev),
                    ],
                    'tbl_act'
                    )
                ]
                )

    def setup_mrb(self):
        self.clear()
        one_bit_list = []
        for i in range(1, 16):
            one_bit_list.append(1 << (15-i))
        print(one_bit_list)

        sampling_hash_list = [0]
        p_length_list = [1]
        level_list = [0]

        for i in range(1, 15):
            temp = one_bit_list[0]
            for j in range(1, i):
                temp = temp | one_bit_list[j]
            sampling_hash_list.append(temp)
            p_length_list.append(i+1)
            level_list.append(i)
        sampling_hash_list.append(32767)
        p_length_list.append(15)
        level_list.append(15)

        print("%6s %6s %6s" % ("s_hash", "p_length", "level"))

        for s_hash, length, lev in zip(sampling_hash_list, p_length_list, level_list):
            print("%6d %6d %6d" % (s_hash, length, lev))
            self.table.entry_add(
                self.target,
                [
                self.table.make_key(
                    [gc.KeyTuple('sampling_hash', s_hash, prefix_len=length)]
                    )
                ],
                [
                self.table.make_data(
                    [
                        gc.DataTuple('level', lev),
                    ],
                    'tbl_act'
                    )
                ]
                )


    def setup_univmon(self):
        self.clear()
        one_bit_list = []
        for i in range(1, 17):
            one_bit_list.append(1 << (16-i))
        print(one_bit_list)

        sampling_hash_list = [0]
        p_length_list = [1]
        level_list = [1]
        base_list = [0]

        for i in range(1, 16):
            temp = one_bit_list[0]
            for j in range(1, i):
                temp = temp | one_bit_list[j]
            sampling_hash_list.append(temp)
            p_length_list.append(i+1)
            level_list.append(i+1)
            base_list.append(2048*i)

        threshold_list = [13324, 7937, 4706, 2756, 1418, 630, 242, 101, 47, 15, 6, 1, 0, 0, 0, 0]

        sampling_hash_list.append(65535)
        p_length_list.append(16)
        level_list.append(17)
        base_list.append(0)
        threshold_list.append(0)

        print("%6s %6s %6s %6s %6s" % ("s_hash", "p_length", "level", "base", "threshold" ))

        target = gc.Target(device_id=0, pipe_id=0xffff)

        for s_hash, length, lev, b, th in zip(sampling_hash_list, p_length_list, level_list, base_list, threshold_list):
            print("%6s %6s %6s %6s %6s" % (s_hash, length, lev, b, th))
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
                        gc.DataTuple('level', lev),
                        gc.DataTuple('base', b),
                        gc.DataTuple('threshold', th)
                    ],
                    'tbl_act'
                    )
                ]
                )
