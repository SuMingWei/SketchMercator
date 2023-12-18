from tofino_control_plane.python.SketchAug.module.common.connection import Connection
from tofino_control_plane.python.SketchAug.module.common.table_register import REGISTER_TABLE
from tofino_control_plane.python.SketchAug.module.common.table_tcam import TCAM

import socket, threading, thread
from python_lib.perf_timer import PerfTimer
from time import sleep

class HLL(Connection):

    def __init__(self, args):
        if args.mode == "pingpong":
            self.program_name = "p416_hll_pp"
        else:
            self.program_name = "p416_hll"

        print(self.program_name)
        self.is_simulator = args.simulator
        super(HLL, self).__init__(self.program_name, self.is_simulator)

    def configure(self, args):
        # print("[PYTHON] [HLL] configure")
        self.tcam = TCAM(self.gc, self.bfrt_info)
        self.tcam.setup_hll()

    def table_setup(self, args):
        # args has only information about sketch_name / mode
        # setup is only necessary for sol3.
        print("[PYTHON] [HLL] table_setup")
        super(HLL, self).table_setup()
        if args.mode != "pingpong":
            self.table_dict = {}
            for array_size in [512, 1024, 2048, 4096]:
                table_list = []
                template = "SwitchIngress.update_%d" % array_size + ".cs_table"
                table = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1", template, array_size)
                table_list.append(table)
                self.table_dict[array_size] = table_list

    def read(self, params):
        print("[PYTHON] [HLL] read - not implemented")

    def reset(self, params): # bulk reset, only called by sol3
        print("[PYTHON] [HLL] reset")
        array_size = params["array_size"]
        for table in self.table_dict[array_size]:
            table.reg_clear()

    def clear(self, args, params): # baseline, pingpong, noreset, sol3
        print("[PYTHON] [HLL] clear")
        super(HLL, self).clear(args, params)

        array_size = params["array_size"]
        if args.mode == "pingpong":
 
            template_0 = "SwitchIngress.update_%d" % array_size + "_0.cs_table"
            template_1 = "SwitchIngress.update_%d" % array_size + "_1.cs_table"

            self.reg_table_1_0 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1_0", template_0, array_size)
            self.reg_table_1_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1_1", template_1, array_size)

            self.reg_table_1_0.clear()
            self.reg_table_1_1.clear()

        else:
            template = "SwitchIngress.update_%d" % array_size + ".cs_table"

            self.reg_table_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1", template, array_size)
            self.reg_table_1.clear()
