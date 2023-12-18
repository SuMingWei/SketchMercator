from multiprocessing import Process, current_process
import socket
import traceback
import os

def tcpreplay(pcap_file_name):
    # cmd = "sudo tcpreplay -i eth5 %s" % pcap_file_name
    cmd = "sudo tcpreplay -i eth4 %s" % pcap_file_name
    print(cmd)
    os.system(cmd)

def send_pcap(pcap_file_name):
    proc = Process(target=tcpreplay, args=(pcap_file_name, ))
    proc.start()

def execute(msg, HOST, PORT, pcap_file_name):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        if pcap_file_name != None:
            send_pcap(pcap_file_name)
        s.sendall(str.encode(msg))
        s.close()
        # exit(1)

    except Exception as e:
        print("except")
        s.close()
        traceback.print_exc()

def tcp_execute(msg, tofino_str, api, pcap_file_name):
    if api == "cpp":
        PORT = 10001
    elif api == "python":
        PORT = 10002

    if tofino_str == 'tofino1':
        HOST = '10.81.1.30'
    elif tofino_str == 'tofino2':
        HOST = '10.81.1.32'
    
    execute(msg, HOST, PORT, pcap_file_name)
