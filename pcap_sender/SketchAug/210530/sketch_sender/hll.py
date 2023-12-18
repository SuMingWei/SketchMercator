from sketch_sender.sketch import Sketch

class HLL(Sketch):
    def __init__(self, name):
        self.name = name

    def turn_on_switch(self):
        print("[HLL] turn on switch")

    def configure(self):
        print("[HLL] configure")

    def start_flowkey_monitor(self):
        print("[HLL] start_flowkey_monitor")

    def timer_signal(self):
        print("[HLL] timer_signal")

    def turn_off_switch(self):
        print("[HLL] turn off switch")
