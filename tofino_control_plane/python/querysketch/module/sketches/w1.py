from tofino_control_plane.python.querysketch.module.common.connection import Connection
from tofino_control_plane.python.querysketch.module.common.table_register import REGISTER_TABLE
from tofino_control_plane.python.querysketch.module.common.table_above_threshold import ABOVE_THRESHOLD_TABLE
from tofino_control_plane.python.querysketch.module.common.table_threshold import THRESHOLD_TABLE
from tofino_control_plane.python.querysketch.module.common.table_exact import EXACT_TABLE
from tofino_control_plane.python.querysketch.module.common.table_tcam import TCAM_TABLE

import socket, threading, thread
from python_lib.perf_timer import PerfTimer
from time import sleep
from data_helper.data_write_helper.result_tofino_dp import file_write
import traceback

is_print = False
# is_print = True

class W1(Connection):

    def __init__(self, args):
        self.program_name = args.program_name
        print(self.program_name)
        self.is_simulator = args.simulator
        super(W1, self).__init__(self.program_name, self.is_simulator)

    ### args.setup -- ports / table_init / configure
    def table_init(self, args):
        print("[PYTHON] [W1] table_init")
        super(W1, self).table_init()

        id_list =    [1, 3]
        type_list =  ["hll", "mrac"]
        width_list = [16384, 8192]
        level_list = [1, 8]

        self.tcam_table_dict = {}

        for i, type, width, level in zip(id_list, type_list, width_list, level_list):
            table_name = "pipe.SwitchIngress.d_%d_tcam_lpm.tbl_select_level" % i
            table = TCAM_TABLE(self.gc, self.bfrt_info, table_name, type, width, level, "workload1")
            self.tcam_table_dict[i] = table

    def configure(self, args):
        print("[PYTHON] [W1] configure")
        for i in [1, 3]:
            self.tcam_table_dict[i].configure(args)
