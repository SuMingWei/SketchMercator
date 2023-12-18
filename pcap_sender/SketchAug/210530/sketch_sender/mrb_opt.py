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

def execute(msg):
    try:
        HOST = '10.81.1.32'
        PORT = 10001
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))

        # send_pcap()
        s.sendall(str.encode(msg))
        s.close()

    except Exception as e:
        print("except")
        s.close()
        traceback.print_exc()


def execute_clear(msg):
    try:
        HOST = '10.81.1.32'
        PORT = 10002
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
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

# msg_list = []
# for epoch in [20, 30]:
#     for size in [4096, 8192, 16384, 32768, 65536]:
#         # if epoch == 1 and size == 4096:
#         #     continue
#         # if epoch == 1 and size == 8192:
#         #     continue
#         msg = "%d_%d" % (epoch, size)
#         print(msg)
#         execute(msg)
#         sleep(75)

#         clear_msg = "clear_%d_%d" % (epoch, size)
#         execute_clear(clear_msg)
#         sleep(7)

# # for epoch in [1]:
# #     for size in [4096, 8192]:
