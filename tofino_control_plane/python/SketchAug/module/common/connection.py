import os
import sys
try:
    # Import BFRT GRPC stuff
    import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
    import bfrt_grpc.client as gc
    import grpc
except:
    sys.path.append(os.environ['SDE_INSTALL'] + "/lib/python2.7/site-packages/tofino")
    import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
    import bfrt_grpc.client as gc
    import grpc

from tofino_control_plane.python.SketchAug.module.common.table_register import REGISTER_TABLE
from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path
from data_helper.data_write_helper.result_tofino_dp import file_write

class Connection(object):
    def __init__(self, program_name, is_simulator):
        self.program_name = program_name
        self.is_simulator = is_simulator
        # print("[program name] %s" % self.program_name)
        self.gc = gc
        self.c = gc.ClientInterface("{}:{}".format('localhost', 50052), 0, 0, is_master=False)
        self.c.bind_pipeline_config(self.program_name)
        self.bfrt_info = self.c.bfrt_info_get(self.program_name)

    def ports(self):
        print("[PYTHON] [Connection] ports is_simulator=%d" % self.is_simulator)
        if self.is_simulator == 0:
            from module.common.ports import Ports 
            ports = Ports(self.gc, self.bfrt_info)
            port_list = [1, 2]
            for port in port_list:
                ports.add_port(port, 0, 100, 'rs')

    def table_setup(self):
        print("[PYTHON] [Connection] table_setup")
        self.index_table = REGISTER_TABLE(self.gc, self.bfrt_info, "index_register", "SwitchIngress.epoch_count_1.cs_table", 1024)
        self.count_table = REGISTER_TABLE(self.gc, self.bfrt_info, "count_register", "SwitchIngress.epoch_count_2.cs_table", 1024)

    def clear(self, args, params):
        self.index_table.clear()
        
        counter_list = self.count_table.read_whole()
        file_path = get_pcounter_path(args.sketch_name, args.mode, params["API"], params["array_size"], params["epoch"], params["pcap_name"], params["date"])
        file_write(file_path, counter_list)

        self.count_table.clear()

    def teardown(self):
        self.c._tear_down_stream()


import socket, threading, thread

# def tcp_reveice
def tcp_listen():
    LOCALHOST = "10.81.1.30" # tofino1
    # LOCALHOST = "10.81.1.32" # tofino2
    PORT = 10002
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LOCALHOST, PORT))
    print("[PYTHON] [TCP] Server started")
    print("[PYTHON] [TCP] Waiting for client request..")
    server.listen(1)
    clientsock, clientAddress = server.accept()
    msg = clientsock.recv(8192).decode()
    print("[PYTHON] [TCP] [data received] %s" % msg)
    return msg, clientsock

def parse_msg(msg):
    spliited = msg.split("/")
    params = {}
    params["mode"] = spliited[0]
    params["op"] = spliited[1]
    params["epoch"] = int(spliited[2])
    params["array_size"] = int(spliited[3])
    params["pcap_name"] = spliited[4]
    params["API"] = spliited[5]
    params["date"] = spliited[6]

    return params

def tcp_start(connection, args):
    connection.ports()
    connection.configure(args)
    connection.table_setup(args)

    while True:
        msg, clientsock = tcp_listen()
        if msg == "exit":
            break

        params = parse_msg(msg)

        if params["op"] == "readreset":
            connection.read(params)
            connection.reset(params)

        elif params["op"] == "reset": # from cpp
            connection.reset(params)
            clientsock.sendall(b'[ack from python]')

        elif params["op"] == "clear":
            connection.clear(args, params)

        clientsock.close()
