import os
import sys
from scapy.all import * 

try:
    # Import BFRT GRPC stuff
    import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
    import bfrt_grpc.client as gc
    import grpc
except:
    sys.path.append(os.environ['SDE_INSTALL'] + "/lib/python2.7/site-packages/tofino")
    import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
    import bfrt_grpc.client as gc
    import grpc

from tofino_control_plane.python.SketchMD.module.common.table_register import REGISTER_TABLE
from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path
from data_helper.data_write_helper.result_tofino_dp import file_write

class Connection(object):
    def __init__(self, program_name, is_simulator):
        self.program_name = program_name
        self.is_simulator = is_simulator
        # print("[program name] %s" % self.program_name)
        self.gc = gc
        self.c = gc.ClientInterface("{}:{}".format('localhost', 50052), 0, 0, is_master=False)
        self.c.bind_pipeline_config(self.program_name)
        self.bfrt_info = self.c.bfrt_info_get(self.program_name)


    ### args.setup -- ports / table_init / configure
    def ports(self):
        print("[PYTHON] [Connection] ports is_simulator=%d" % self.is_simulator)
        if self.is_simulator == 0:
            from module.common.ports import Ports 
            ports = Ports(self.gc, self.bfrt_info)
            port_list = [1, 2]
            for port in port_list:
                ports.add_port(port, 0, 100, 'rs')
    def table_init(self):
        print("[PYTHON] [Connection] table_init")
        self.index_table = REGISTER_TABLE(self.gc, self.bfrt_info, "index_register", "SwitchIngress.epoch_count_1.cs_table", 1024)
        self.count_table = REGISTER_TABLE(self.gc, self.bfrt_info, "count_register", "SwitchIngress.epoch_count_2.cs_table", 1024)
    def configure(self):
        pass
    ###

    ### args.digest
    def digest(self, args):
        pass
    ###

    ### args.save_epoch
    def epoch(self, args):
        print("[PYTHON] [Connection] save epoch")
        self.index_table.clear()
        counter_list = self.count_table.read_whole()
        file_path = "/home/hnamkung/sketch_home/result_tofino_dp/sketchMD/%s/%s/%s/%s/epoch.txt" % \
            (args.workload_name, args.program_name, args.pcap_name, args.date)
        file_write(file_path, counter_list)
        self.count_table.clear()
    ### 


    def teardown(self):
        self.c._tear_down_stream()
