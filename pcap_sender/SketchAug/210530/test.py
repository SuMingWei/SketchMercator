from multiprocessing import Process, current_process
import socket
import traceback
import os

pcap_name = "test_4096_2000ms_10us.pcap"
# pcap_name = "test_65536_2000ms_10us.pcap"

def tcpreplay():
    cmd = "sudo tcpreplay -i eth5 /data/sketch_home/pcap_editor/python/%s" % pcap_name
    print(cmd)
    os.system(cmd)
def send_pcap():
    proc = Process(target=tcpreplay, args=())
    proc.start()

def execute(msg):
    try:
        # HOST = '10.81.1.30' # tofino1
        HOST = '10.81.1.32' # tofino2
        PORT = 10001
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        send_pcap()
        s.sendall(str.encode(msg))
        s.close()

    except Exception as e:
        print("except")
        s.close()
        traceback.print_exc()

from time import sleep

import sys
msg = sys.argv[1]
execute(msg)