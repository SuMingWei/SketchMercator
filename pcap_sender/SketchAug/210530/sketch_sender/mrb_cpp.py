from multiprocessing import Process, current_process
import socket
import traceback
import os

def tcpreplay():
    cmd = "sudo tcpreplay -i eth5 60s.pcap"
    print(cmd)
    os.system(cmd)

def send_pcap():
    proc = Process(target=tcpreplay, args=())
    proc.start()

def execute(msg, PORT, is_send_pcap):
    try:
        HOST = '10.81.1.32'
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        if is_send_pcap:
            send_pcap()
        s.sendall(str.encode(msg))
        s.close()

    except Exception as e:
        print("except")
        s.close()
        traceback.print_exc()


def execute_cpp(msg, is_send_pcap):
    execute(msg, 10001, is_send_pcap)

def execute_python(msg, is_send_pcap):
    execute(msg, 10002, is_send_pcap)

from time import sleep
import sys

# msg = sys.argv[1]
# execute(msg)

# msg_list = []
# for epoch in [1, 5, 10, 20, 30]:
#     for size in [4096, 8192, 16384, 32768, 65536]:

epoch = 1
size = 4096

# msg = "%d_%d" % (epoch, size)
# print(msg)
# execute_cpp(msg, True)
# sleep(75)

clear_msg = "clear_%d_%d" % (epoch, size)
execute_python(clear_msg, False)
sleep(7)
