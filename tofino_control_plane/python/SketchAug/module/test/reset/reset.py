from tofino_control_plane.python.SketchAug.module.common.connection import Connection
from tofino_control_plane.python.SketchAug.module.test.reset.table.tcam_table import TCAM
from tofino_control_plane.python.SketchAug.module.test.reset.table.register_table import REGISTER_TABLE
from tofino_control_plane.python.SketchAug.module.test.reset.table.register_index_table import REGISTER_INDEX_TABLE
from tofino_control_plane.python.SketchAug.module.test.reset.table.register_count_table import REGISTER_COUNT_TABLE

import socket, threading, thread
# from apscheduler.schedulers.background import BlockingScheduler
from python_lib.perf_timer import PerfTimer
from time import sleep


count = 0
size = 4096
# epoch = 30
epoch = 1

def tcp_receive():
    LOCALHOST = "10.81.1.32"
    PORT = 10002
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LOCALHOST, PORT))
    print("Server started")
    print("Waiting for client request..")
    server.listen(1)
    clientsock, clientAddress = server.accept()
    msg = ''
    data = clientsock.recv(8192).decode()
    print("receive - %s", data)
    return data

def timer_ready(gc, bfrt_info):
    # global size, epoch

    print("timer_ready")
    for i in range(20):
        ret = tcp_receive()

        op = ret.split("_")[0]
        epoch = int(ret.split("_")[1])
        size = int(ret.split("_")[2])
        print("[epoch] %d" % epoch)
        print("[size] %d" % size)

        if op == 'clear':

            c_table = REGISTER_COUNT_TABLE(gc, bfrt_info)
            c_table.read(size, epoch, "cpp")
            c_table.clear()

            reg_index_table = REGISTER_INDEX_TABLE(gc, bfrt_info)
            reg_index_table.clear()
            for size in [4096, 8192, 16384, 32768, 65536]:
                reg_table = REGISTER_TABLE(gc, bfrt_info, size)
                reg_table.clear()

        if op == "start":
            sleep(2)
            reg_table = REGISTER_TABLE(gc, bfrt_info, size)

            reg_index_table = REGISTER_INDEX_TABLE(gc, bfrt_info)
            c_table = REGISTER_COUNT_TABLE(gc, bfrt_info)

            loop_timer = PerfTimer('loop_timer')
            total_timer = PerfTimer('total_test')

            count = 0
            for e in range(0, 60/epoch+1):
                print("count: ", count)
                print(total_timer.lap_micro_string())
                loop_timer.start()
                reg_index_table.write(count+1)
                reg_table.read(epoch, count)
                reg_table.reset()
                delay = loop_timer.end()
                if e != 60/epoch:
                    sleep(epoch - delay - 0.0011)
                count += 1
            # break
            c_table.read(size, epoch)

            c_table.clear()
            reg_index_table.clear()
            for size in [4096, 8192, 16384, 32768, 65536]:
                reg_table = REGISTER_TABLE(gc, bfrt_info, size)
                reg_table.clear()


class RESET(Connection):

    def __init__(self, args):
        self.program_name = "p416_mrb"
        print(self.program_name)
        self.is_simulator = args.simulator
        super(RESET, self).__init__(self.program_name, self.is_simulator)


    def port_configure(self, args):
        super(RESET, self).port_configure()

    def configure(self, args):
        tcam_table = TCAM(self.gc, self.bfrt_info)
        tcam_table.setup()
        # reg_index_table = REGISTER_INDEX_TABLE(self.gc, self.bfrt_info)
        # reg_index_table.write(1)

    def test(self, args):
        global size, epoch

        print("read come")
        reg_index_table = REGISTER_INDEX_TABLE(self.gc, self.bfrt_info)

        # for size in [4096, 8192, 16384, 32768, 65536]:
        #     reg_table = REGISTER_TABLE(self.gc, self.bfrt_info, size)
        #     print("size: %d" % size)
        #     timer = PerfTimer("write test")
        #     reg_table.table.entry_del(reg_table.target)
        #     # reg_table.clear()
        #     print(timer.lap_micro_string())
        #     print(" ")

        # reg_index_table.clear()
        # reg_index_table.write(0, 100)
        # reg_index_table.bulk_read_SW()
        reg_index_table.read_SW()
        reg_index_table.read_HW()

        

        # timer = PerfTimer("write test")
        # for index in range(0, 1024):
        #     reg_index_table.write(index, 0)
        # print(timer.lap_micro_string())

        # timer = PerfTimer("write test")
        # print(timer.lap_micro_string())

        # timer = PerfTimer("write test")
        # sleep(3)
        # print(timer.lap_micro_string())
        # reg_index_table.read_SW()
        # reg_index_table.read_HW()

        # reg_index_table.bulk_read()

        # if args.str_args_1 == 'clear':
        #     reg_index_table.clear()
        # elif args.str_args_1 == 'bulk_read':
        #     reg_index_table.bulk_read()
        # elif args.str_args_1 == 'write':
        #     reg_index_table.write(args.int_args_1)


        # if args.str_args_1 == "epoch_counter":
        #     print("epoch counter come")
        #     c_table = REGISTER_COUNT_TABLE(self.gc, self.bfrt_info)
        #     c_table.read(size, epoch)

        # elif args.str_args_1 == "timer_ready":
        #     timer_ready(self.gc, self.bfrt_info)

        # elif args.str_args_1 == "clear":
        #     c_table = REGISTER_COUNT_TABLE(self.gc, self.bfrt_info)
        #     c_table.clear()
        #     reg_index_table = REGISTER_INDEX_TABLE(self.gc, self.bfrt_info)
        #     reg_index_table.clear()
        #     for size in [4096, 8192, 16384, 32768, 65536]:
        #         reg_table = REGISTER_TABLE(self.gc, self.bfrt_info, size)
        #         reg_table.clear()
        # else:
        #     pass

