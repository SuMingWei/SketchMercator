
from python_lib.perf_timer import PerfTimer
from tofino_control_plane.python.SketchAug.module.common.connection import Connection
import socket, threading, thread
from tofino_control_plane.python.SketchAug.module.test.hw_behave.table.register_table import REGISTER_TABLE

def tcp_receive(gc, bfrt_info):
    # for size in [4096, 8192, 16384, 32768, 65536]:
    
    reg_table_4096 = REGISTER_TABLE(gc, bfrt_info, 4096)
    reg_table_8192 = REGISTER_TABLE(gc, bfrt_info, 8192)
    reg_table_16384 = REGISTER_TABLE(gc, bfrt_info, 16384)
    reg_table_32768 = REGISTER_TABLE(gc, bfrt_info, 32768)
    reg_table_65536 = REGISTER_TABLE(gc, bfrt_info, 65536)

    LOCALHOST = "10.81.1.32"
    PORT = 10002
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LOCALHOST, PORT))
    print("Server started")
    print("Waiting for client request..")
    server.listen(1)
    clientsock, clientAddress = server.accept()
    data = clientsock.recv(8192).decode()
    array_size = int(data)
    print("receive - %d" % array_size)
    if array_size == 4096:
        reg_table_4096.reset()
    elif array_size == 8192:
        reg_table_8192.reset()
    elif array_size == 16384:
        reg_table_16384.reset()
    elif array_size == 32768:
        reg_table_32768.reset()
    elif array_size == 65536:
        reg_table_65536.reset()
        
    clientsock.sendall(b'[ack from python]')

class HwBehave(Connection):

    def __init__(self, args):
        self.program_name = "p416_hw_behave_test"
        print(self.program_name)
        self.is_simulator = args.simulator
        super(HwBehave, self).__init__(self.program_name, self.is_simulator)

    def port_configure(self, args):
        super(HwBehave, self).port_configure()

    def test(self, args):
        while True:
            ret = tcp_receive(self.gc, self.bfrt_info)
        # print("hw behave test")
