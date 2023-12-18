from multiprocessing import Process, current_process
import socket, threading, thread
from time import sleep


from python_lib.perf_timer import PerfTimer

from tofino_control_plane.python.SketchAug.SketchLib.common.connection import Connection
from tofino_control_plane.python.SketchAug.SketchLib.common.track_heavy_flowkey import FLOWKEY_LEARN
# from tofino_control_plane.python.SketchAug.SketchLib.common.threshold_insert_table import THRESHOLD_INSERT

class CM(Connection):

    def __init__(self, args):
        self.program_name = "p416_eval_countmin"
        print(self.program_name)
        self.is_simulator = args.simulator
        super(CM, self).__init__(self.program_name, self.is_simulator)

        # self.TH = THRESHOLD_INSERT(self.gc, self.bfrt_info)
        self.FL = FLOWKEY_LEARN(self.gc, self.bfrt_info, args.simulator, is_print=True)

    def configure(self):
        print("CM configure")
        # self.TH.setup(10)

    def flowkey_start(self, params):
        print("CM flowkey start")
        print(params["pcap_name"])
    
        # proc = Process(target=self.FL.sniff_start)
        # proc.start()

        self.FL.sniff_start()

    def flowkey_stop(self, params):
        print("CM flowkey stop")
        self.FL.clear_and_save()
