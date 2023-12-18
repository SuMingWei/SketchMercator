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

# def execute_cpp(msg):
#     try:
#         HOST = '10.81.1.32'
#         PORT = 10001
#         s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#         s.connect((HOST, PORT))

#         send_pcap()
#         s.sendall(str.encode(msg))
#         s.close()

#     except Exception as e:
#         print("except")
#         s.close()
#         traceback.print_exc()


def execute_python(msg):
    try:
        HOST = '10.81.1.32'
        PORT = 10002
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

# msg = sys.argv[1]
# execute(msg)

delays = {}
delays[4096] = 1.722243
delays[8192] = 3.53519
delays[16384] = 7.345157
delays[32768] = 14.843539
delays[65536] = 30.30019

msg_list = []
for epoch in [1, 5, 10, 20, 30]:
    for size in [4096, 8192, 16384, 32768, 65536]:
        # if epoch == 1 and size == 4096:
        #     continue
        # if epoch == 1 and size == 8192:
        #     continue
        # msg = "%d_%d" % (epoch, size)
        # print(msg)
        # execute_cpp(msg)
        # sleep(75)
        # clear_msg = "clear_%d_%d" % (epoch, size)

        start_msg = "start_%d_%d" % (epoch, size)        
        if epoch <= delays[size]:
            continue
        print(start_msg)
        # else:
        #     print(start_msg + " no")
        execute_python(start_msg)
        sleep(85)
        # sleep(7)
