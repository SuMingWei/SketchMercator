from multiprocessing import Process, current_process
import socket
import traceback
import os

# pcap_name = "test_20480_300_5000ms.pcap"
# pcap_name = "test_20480_3000_2000ms_us.pcap"

# pcap_name = "test_65536_2000_5000ms.pcap"
# pcap_name = "test_65536_5000_2000ms_us.pcap"

# pcap_name = "test_4096_2000ms_10us.pcap"
# pcap_name = "test_8192_2000ms_10us.pcap"
# pcap_name = "test_16384_2000ms_10us.pcap"
# pcap_name = "test_32768_2000ms_10us.pcap"
pcap_name = "test_65536_2000ms_10us.pcap"

def tcpreplay():
    # cmd = "sudo tcpreplay -i eth5 /data/sketch_home/pcap_editor/python/%s" % pcap_name
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
        # if msg == 'read':
        #     # send_pcap()
        #     s.sendall(b'read')
        # elif msg == 'read_test':
        #     # send_pcap()
        #     s.sendall(b'read_test')
        # elif msg == 'reset':
        #     s.sendall(b'reset')
        # elif msg == 'reset_test':
        #     send_pcap()
        #     s.sendall(b'reset_test')
        # elif msg == 'clear':
        #     s.sendall(b'clear')
        # else:
        #     s.sendall(b'none')
        #     pass
        # if msg == 'start':
        #     send_pcap()
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

# msg_list = [
#     "start_10_4096",
#     "start_20_4096",
#     "start_30_4096",
#     "start_10_8192",
#     "start_20_8192",
#     "start_30_8192",
#     "start_20_16384",
#     "start_30_16384",
#     "start_10_16384",
# ]

# # msg_list = [
# #     "start_30_4096",
# # ]

# for msg in msg_list:
#     execute(msg)
#     sleep(70)

# # for epoch in (10, 20, 30)
# # for i in range(0, 10):
# #     execute("read_test")
# #     sleep(3)
# #     execute("reset")
# #     sleep(1)

# #     execute("reset_test")
# #     sleep(3)
# #     execute("read")
# #     sleep(1)
# #     execute("reset")
# #     sleep(1)

# # # execute("clear")
