from multiprocessing import Process, current_process
import socket
import traceback
import os

def tcpreplay():
    cmd = "sudo tcpreplay -i eth5 pcap/60s.pcap"
    print(cmd)
    os.system(cmd)

def tcpreplay():
    cmd = "sudo tcpreplay -i eth5 pcap/60s.pcap"
    print(cmd)
    os.system(cmd)

def send_pcap():
    proc = Process(target=tcpreplay, args=())
    proc.start()

def execute(msg, HOST, PORT, is_send_pcap):
    try:
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

def tofino1_execute_cpp(msg, is_send_pcap):
    execute(msg, '10.81.1.30', 10001, is_send_pcap)

def tofino1_execute_python(msg, is_send_pcap):
    execute(msg, '10.81.1.30', 10002, is_send_pcap)

def tofino2_execute_cpp(msg, is_send_pcap):
    execute(msg, '10.81.1.32', 10001, is_send_pcap)

def tofino2_execute_python(msg, is_send_pcap):
    execute(msg, '10.81.1.32', 10002, is_send_pcap)

