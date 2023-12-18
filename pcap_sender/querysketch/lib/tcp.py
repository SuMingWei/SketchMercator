from multiprocessing import Process, current_process
import socket
import traceback
import os
import subprocess
import signal

from pcap_sender.querysketch.config import TOFINO_STR

def tcpreplay(pcap_file_name):
    if TOFINO_STR == "tofino1":
        cmd = "sudo tcpreplay --stats 10 -i eth4 %s" % pcap_file_name
    else:
        cmd = "sudo tcpreplay --stats 10 -i eth5 %s" % pcap_file_name
    print(cmd)
    timeout_s = 65
    try:
        p = subprocess.Popen(cmd.split(' '), start_new_session=True)
        p.wait(timeout=timeout_s)
        # p = subprocess.run(cmd.split(' '), timeout=timeout_s)
    except subprocess.TimeoutExpired:
        print(f'Timeout for {cmd} ({timeout_s}s) expired')
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)

def send_pcap(pcap_file_name):
    proc = Process(target=tcpreplay, args=(pcap_file_name, ))
    proc.start()

def execute(msg, HOST, PORT, pcap_file_name):
    try:
        # if pcap_file_name != None:
        #     send_pcap(pcap_file_name)
        # return
        
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
