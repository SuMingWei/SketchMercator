from tofino_control_plane.python.SketchAug.module.common.connection import Connection
from tofino_control_plane.python.SketchAug.module.common.table_register import REGISTER_TABLE

import socket, threading, thread
from python_lib.perf_timer import PerfTimer
from time import sleep

class CM(Connection):

    def __init__(self, args):
        if args.mode == "pingpong":
            self.program_name = "p416_cm_pp"
        else:
            self.program_name = "p416_cm"

        print(self.program_name)
        self.is_simulator = args.simulator
        super(CM, self).__init__(self.program_name, self.is_simulator)

    def configure(self, args):
        # print("[PYTHON] [CM] configure")
        pass

    def table_setup(self, args):
        # args has only information about sketch_name / mode
        # setup is only necessary for sol3.
        print("[PYTHON] [CM] table_setup")
        super(CM, self).table_setup()
        if args.mode != "pingpong":
            self.table_dict = {}
            for array_size in [1024, 2048, 4096, 8192, 16384]:
                table_list = []
                template = "SwitchIngress.update_%d" % array_size + "_%d.cs_table"
                for row in range(1, 5):
                    table = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1", template % row, array_size)
                    table_list.append(table)
                self.table_dict[array_size] = table_list


    def read(self, params):
        print("[PYTHON] [CM] read - not implemented")

    def reset(self, params): # bulk reset, only called by sol3
        print("[PYTHON] [CM] reset")
        array_size = params["array_size"]
        for table in self.table_dict[array_size]:
            table.reg_clear()

    def clear(self, args, params): # baseline, pingpong, noreset, sol3
        print("[PYTHON] [CM] clear")
        super(CM, self).clear(args, params)

        array_size = params["array_size"]
        if args.mode == "pingpong":
 
            template_0 = "SwitchIngress.update_%d" % array_size + "_%d_0.cs_table"
            template_1 = "SwitchIngress.update_%d" % array_size + "_%d_1.cs_table"

            self.reg_table_1_0 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1_0", template_0 % 1, array_size)
            self.reg_table_2_0 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_2_0", template_0 % 2, array_size)
            self.reg_table_3_0 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_3_0", template_0 % 3, array_size)
            self.reg_table_4_0 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_4_0", template_0 % 4, array_size)

            self.reg_table_1_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1_1", template_1 % 1, array_size)
            self.reg_table_2_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_2_1", template_1 % 2, array_size)
            self.reg_table_3_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_3_1", template_1 % 3, array_size)
            self.reg_table_4_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_4_1", template_1 % 4, array_size)

            self.reg_table_1_0.clear()
            self.reg_table_2_0.clear()
            self.reg_table_3_0.clear()
            self.reg_table_4_0.clear()

            self.reg_table_1_1.clear()
            self.reg_table_2_1.clear()
            self.reg_table_3_1.clear()
            self.reg_table_4_1.clear()

        else:
            template = "SwitchIngress.update_%d" % array_size + "_%d.cs_table"

            self.reg_table_1 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_1", template % 1, array_size)
            self.reg_table_2 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_2", template % 2, array_size)
            self.reg_table_3 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_3", template % 3, array_size)
            self.reg_table_4 = REGISTER_TABLE(self.gc, self.bfrt_info, "reg_table_4", template % 4, array_size)

            self.reg_table_1.clear()
            self.reg_table_2.clear()
            self.reg_table_3.clear()
            self.reg_table_4.clear()
