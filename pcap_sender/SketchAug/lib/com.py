import os
import subprocess
import time
import sys
import signal
from multiprocessing import Process, current_process
from pcap_sender.SketchAug.lib.tcp import tcp_execute

SCRIPT_PATH_CPP = "$sketch_home/tofino_control_plane/cpp/SketchAug/ssh.sh"
SCRIPT_PATH_PYTHON = "$sketch_home/tofino_control_plane/python/SketchAug/ssh.sh"

TOFINO_STR = "tofino1"
# TOFINO_STR = "tofino2"


def turn_on_switch_cpp_internal(sketch_name, mode, array_size):
    tofino_cmd = "%s %s %s" % (SCRIPT_PATH_CPP, sketch_name, mode)
    cmd = "ssh %s \'%s\' %d" % (TOFINO_STR, tofino_cmd, array_size)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)

def turn_on_switch_python_internal(sketch_name, mode, array_size):
    tofino_cmd = "%s %s %s" % (SCRIPT_PATH_PYTHON, sketch_name, mode)
    cmd = "ssh %s \'%s\' %d" % (TOFINO_STR, tofino_cmd, array_size)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)

def turn_on_switch_cpp(sketch_name, mode, array_size):
    proc = Process(target=turn_on_switch_cpp_internal, args=(sketch_name, mode, array_size, ))
    proc.start()

def turn_on_switch_python(sketch_name, mode, array_size):
    proc = Process(target=turn_on_switch_python_internal, args=(sketch_name, mode, array_size, ))
    proc.start()

def turn_off_switch_python(sketch_name, mode):
    tcp_execute("exit", TOFINO_STR, "python", None)

def turn_off_switch_cpp(sketch_name, mode):
    tcp_execute("exit", TOFINO_STR, "cpp", None)
import datetime

def send_msg_cpp_without_pcap(mode, op, epoch, array_size, pcap_full_path, date):
    pcap_file_name = os.path.basename(pcap_full_path)
    msg = "%s/%s/%d/%d/%s/%s" % (mode, op, epoch, array_size, pcap_file_name, date)
    tcp_execute(msg, TOFINO_STR, "cpp", None)

def send_msg_cpp_with_pcap(mode, op, epoch, array_size, pcap_full_path, date):
    pcap_file_name = os.path.basename(pcap_full_path)
    msg = "%s/%s/%d/%d/%s/%s" % (mode, op, epoch, array_size, pcap_file_name, date)
    tcp_execute(msg, TOFINO_STR, "cpp", pcap_full_path)

def send_msg_python(mode, op, epoch, array_size, pcap_full_path, API, date):
    pcap_file_name = os.path.basename(pcap_full_path)
    msg = "%s/%s/%d/%d/%s/%s/%s" % (mode, op, epoch, array_size, pcap_file_name, API, date)
    tcp_execute(msg, TOFINO_STR, "python", None)

