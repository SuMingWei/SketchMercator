from multiprocessing import Process, current_process
import socket
import traceback
import os

def tcpreplay(array_size):
    pcap_name = "test_%d_2000ms_10us.pcap" % array_size
    cmd = "sudo tcpreplay -i eth5 /data/sketch_home/pcap_editor/python/%s" % pcap_name
    print(cmd)
    os.system(cmd)

def send_pcap(array_size):
    proc = Process(target=tcpreplay, args=(array_size, ))
    proc.start()

def execute(op, array_size):
    try:
        msg = "%s_%d" % (op, array_size)
        print(msg)
        # HOST = '10.81.1.30' # tofino1
        HOST = '10.81.1.32' # tofino 2
        PORT = 10001
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        if op == "readtest" or op == "resettest" or op == "bulkresettest":
            send_pcap(array_size)
        s.sendall(str.encode(msg))
        s.close()

    except Exception as e:
        print("except")
        s.close()
        traceback.print_exc()

from time import sleep

def finegrained_measurement():
    # for array_size in [8192, 32768]:
    for array_size in [4096, 16384, 65536]:
        # for i in range(0, 10):

        execute("reset", array_size)
        sleep(2)

        for i in range(0, 10):
            execute("readtest", array_size)
            sleep(4)

            execute("reset", array_size)
            sleep(2)

            execute("resettest", array_size)
            sleep(4)
            execute("resettestread", array_size)
            sleep(4)

            execute("reset", array_size)
            sleep(2)

        execute("clear", array_size)
        sleep(2)

def bulk_reset_measurement():
    # for array_size in [4096, 8192, 16384, 32768, 65536]:
    for array_size in [4096, 16384, 65536]:
    # for array_size in [4096]:

        execute("reset", array_size)
        sleep(2)

        for i in range(0, 10):
        # for i in range(0, 1):

            execute("bulkresettest", array_size)
            sleep(4)

            execute("resettestread", array_size)
            sleep(4)

            execute("reset", array_size)
            sleep(2)

        execute("clear", array_size)
        sleep(2)

# finegrained_measurement()
bulk_reset_measurement()
