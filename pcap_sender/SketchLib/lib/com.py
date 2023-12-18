import os
import subprocess
import time
import sys
import signal
from multiprocessing import Process, current_process
from pcap_sender.SketchLib.lib.tcp import tcp_execute

SCRIPT_PATH_CPP = "$sketch_home/tofino_control_plane/cpp/SketchLib/ssh.sh"
SCRIPT_PATH_PYTHON = "$sketch_home/tofino_control_plane/python/SketchLib/ssh.sh"

# TOFINO_STR = "tofino1"
TOFINO_STR = "tofino2"


def turn_on_switch_cpp_internal(sketch_name):
    tofino_cmd = "%s %s" % (SCRIPT_PATH_CPP, sketch_name)
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)

def turn_on_switch_python_internal(sketch_name):
    tofino_cmd = "%s %s" % (SCRIPT_PATH_PYTHON, sketch_name)
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)

def turn_on_switch_cpp(sketch_name):
    proc = Process(target=turn_on_switch_cpp_internal, args=(sketch_name, ))
    proc.start()

def turn_on_switch_python(sketch_name):
    proc = Process(target=turn_on_switch_python_internal, args=(sketch_name, ))
    proc.start()

def turn_off_switch_python(sketch_name):
    tcp_execute("exit", TOFINO_STR, "python")

def turn_off_switch_cpp(sketch_name):
    tcp_execute("exit", TOFINO_STR, "cpp")


import datetime

def send_msg_cpp(msg):
    tcp_execute(msg, TOFINO_STR, "cpp")

def send_msg_python(msg):
    tcp_execute(msg, TOFINO_STR, "python")