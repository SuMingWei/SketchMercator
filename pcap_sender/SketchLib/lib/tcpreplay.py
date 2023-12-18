from multiprocessing import Process, current_process
import os

def tcpreplay_execute(pcap_file_name):
    cmd = "sudo tcpreplay -i eth5 %s" % pcap_file_name
    # cmd = "sudo tcpreplay -i eth4 %s" % pcap_file_name
    print(cmd)
    os.system(cmd)

def send_pcap(pcap_file_name):
    proc = Process(target=tcpreplay_execute, args=(pcap_file_name, ))
    proc.start()

