from tofino_control_plane.python.SketchAug.SketchLib.common.connection import Connection

import socket, threading, thread
from python_lib.perf_timer import PerfTimer
from time import sleep

class FCM_TOPK(Connection):

    def __init__(self, args):
        print("lets do port figure manually")
        # self.program_name = "p414_fcm_topk"
        # print(self.program_name)
        # self.is_simulator = args.simulator
        # super(FCM_TOPK, self).__init__(self.program_name, self.is_simulator)

    def configure(self):
        print("FCM TOPK configure")
        pass


class FCM_O6(Connection):

    def __init__(self, args):
        self.program_name = "p416_eval_fcm"
        print(self.program_name)
        self.is_simulator = args.simulator
        super(FCM_O6, self).__init__(self.program_name, self.is_simulator)

    def configure(self):
        print("FCM configure")
        pass

    def flowkey_start(self, params):
        print("FCM flowkey start")
        pass

    def flowkey_stop(self, params):
        print("FCM flowkey stop")
        pass
