import os
import subprocess
import time
import sys
import signal
from multiprocessing import Process, current_process
from pcap_sender.querysketch.lib.tcp import tcp_execute
from pcap_sender.querysketch.config import TOFINO_STR
from scapy.all import *

SCRIPT_PATH_CPP = "$sketch_home/tofino_control_plane/cpp/querysketch"
SCRIPT_PATH_CPP_TURN_OFF = "/home/hnamkung/sketch_home/tofino_control_plane/tools/turn_off_switch.py"

from pcap_sender.querysketch.config import TOFINO_STR

### turn_on_switch_cpp
def turn_on_switch_cpp_internal(tuple):
    tofino_cmd = "%s/ssh.sh" % (SCRIPT_PATH_CPP) + " %s %s" % tuple
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)

def turn_on_switch_cpp(tuple):
    proc = Process(target=turn_on_switch_cpp_internal, args=(tuple, ))
    proc.start()
###

### turn_off_switch_cpp
def turn_off_switch_cpp():
    tofino_cmd = "python %s" % (SCRIPT_PATH_CPP_TURN_OFF)
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)
### 


SCRIPT_PATH_PYTHON = "$sketch_home/tofino_control_plane/python/querysketch"
SCRIPT_PATH_PYTHON_TURN_OFF = "/home/hnamkung/sketch_home/tofino_control_plane/tools/turn_off_python.py"
### python_setup
def python_setup(tuple, caida_date):
    tofino_cmd = "%s/ssh_setup.sh" % SCRIPT_PATH_PYTHON + " %s %s " % tuple + caida_date
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)
###


### python_epoch
def python_epoch(tuple, caida_date):
    tofino_cmd = "%s/ssh_epoch.sh" % SCRIPT_PATH_PYTHON + " %s %s %s %s %s " % tuple + caida_date
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)
###

### python_digest
def python_digest_internal(tuple, caida_date):
    tofino_cmd = "%s/ssh_flowkey.sh" % SCRIPT_PATH_PYTHON + " %s %s %s %s %s " % tuple + caida_date
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)

def python_digest(tuple, caida_date):
    proc = Process(target=python_digest_internal, args=(tuple, caida_date, ))
    proc.start()
###

def turn_off_switch_python():

    packet = Ether(dst="00:0f:66:56:fa:d2", src="00:ae:f3:52:aa:d1")/IP(src="1.1.1.1", dst="2.2.2.2")/TCP(sport=0x0F0F, dport=0x0A0A)
    if TOFINO_STR == "tofino1":
        sendp(packet, iface='eth4')
    else:
        sendp(packet, iface='eth5')

    tofino_cmd = "python %s" % (SCRIPT_PATH_PYTHON_TURN_OFF)
    cmd = "ssh %s \'%s\'" % (TOFINO_STR, tofino_cmd)
    print("[cmd - %s]\n" % cmd)
    os.system(cmd)



def send_msg_cpp_without_pcap(op, pcap_full_path, date):
    pcap_file_name = os.path.basename(pcap_full_path)
    msg = "%s/%s/%s" % (op, pcap_file_name, date)
    tcp_execute(msg, TOFINO_STR, "cpp", None)

def send_msg_cpp_with_pcap(op, pcap_full_path, date):
    pcap_file_name = os.path.basename(pcap_full_path)
    msg = "%s/%s/%s" % (op, pcap_file_name, date)
    tcp_execute(msg, TOFINO_STR, "cpp", pcap_full_path)
