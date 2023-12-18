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


from tofino_control_plane.python.SketchAug.SketchLib.common.ports import Ports 

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
            ports = Ports(self.gc, self.bfrt_info)
            port_list = [1, 2]
            for port in port_list:
                ports.add_port(port, 0, 100, 'rs')

    def configure(self):
        print("connection configure")
        pass

    def flowkey_start(self, params):
        print("connection flowkey start")
        pass

    def flowkey_stop(self, params):
        print("connection flowkey stop")
        pass

    def teardown(self):
        self.c._tear_down_stream()


import socket, threading, thread

# def tcp_reveice
def tcp_listen():
    LOCALHOST = "10.81.1.32"
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
    params["op"] = spliited[0]
    params["pcap_name"] = spliited[1]

    return params

def tcp_start(connection):
    params={}
    params["op"] = "flowkey_start"
    params["pcap_name"] = "small.pcap"
    connection.flowkey_start(params)

    # while True:
    #     msg, clientsock = tcp_listen()
    #     if msg == "exit":
    #         break

    #     print("msg : ", msg)
    #     params = parse_msg(msg)

    #     if params["op"] == "flowkey_start":
    #         connection.flowkey_start(params)

    #     elif params["op"] == "flowkey_stop":
    #         connection.flowkey_stop(params)

    #     clientsock.close()
