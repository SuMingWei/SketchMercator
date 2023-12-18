import logging
from pprint import pprint, pformat
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from module.common.table import Table
from perf_timer import PerfTimer

import os

class FLOWKEY_REGISTER_TABLE(Table):

    def __init__(self, client, bfrt_info, size, simulator):
        # set up base class
        super(FLOWKEY_REGISTER_TABLE, self).__init__(client, bfrt_info)

        self.logger = logging.getLogger('FLOWEY_REGISTER_TABLE')
        self.logger.info("Setting up flowkey register table...")

        self.size = size
        self.simulator = simulator

        if simulator == 1:
            self.pipe_index = 0
        else:
            self.pipe_index = 1

        self.table = self.bfrt_info.table_get("pipe.SwitchIngress.store_flowkey.flowkey_hash_table")

        # set format annotations
        # self.table.info.key_field_annotation_add("hdr.ethernet.dst_addr", "mac")

        # clear and add defaults
        # self.clear()
        self.target = client.Target(device_id=0, pipe_id=0xffff)



    def load_registers(self):
        timer = PerfTimer('Flowkey Register Load')
        resp = self.table.entry_get(
            self.target,
            [],
            {"from_hw": True})

        self.flowkeys = []


        for i in range(0, self.size):
            if i % 3000 == 0:
                print(i, timer.lap_10_milli_string())
            # if i == 100:
            #     break
            data, _ = next(resp)
            data_dict = data.to_dict()
            # print(data_dict) # {'is_default_entry': False, u'SwitchIngress.store_flowkey.flowkey_hash_table.f1': [16843009, 0, 0, 0], 'action_name': None}
            data_per_pipe = data_dict[u'SwitchIngress.store_flowkey.flowkey_hash_table.f1']
            flowkey = data_per_pipe[self.pipe_index]
            self.flowkeys.append(flowkey)

        timer.lap_10_milli()

    def save_to_file(self, folder_name, file_name, is_print):

        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        full_path = os.path.join(folder_name, file_name)

        f = open(full_path, "w")
        for i in range(0, self.size):
            f.write(str(self.flowkeys[i]) + '\n')
            if is_print == True:
                print(self.flowkeys[i])
        f.close()

    def tableClear(self):
        self.table.entry_del(self.target)
