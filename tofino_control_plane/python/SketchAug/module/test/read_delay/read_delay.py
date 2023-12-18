
from python_lib.perf_timer import PerfTimer
from tofino_control_plane.python.SketchAug.module.common.connection import Connection

class ReadDelay(Connection):

    def __init__(self, args):
        self.program_name = "p416_read_delay_test_%s" % args.str_args_1
        print(self.program_name)
        self.is_simulator = args.simulator
        super(ReadDelay, self).__init__(self.program_name, self.is_simulator)

    def port_configure(self, args):
        super(ReadDelay, self).port_configure()

    def test(self, args):
        from module.test.read_delay.table.register_table import REGISTER_TABLE
        timer = PerfTimer('Total')
        # array_size_list = [4096, 8192, 12288, 16384, 20480, 32768, 36864, 65536, 131072]
        array_size_list = [4096, 8192, 12288, 16384, 20480, 32768, 36864, 65536]
        # array_size_list = [4096, 8192, 12288, 16384, 20480, 32768, 36864, 65536, 131072]
        # array_size_list = [4096, 65536]
        # array_size_list = [65536]

        if args.str_args_1 == "small":
            counter_size_list = [1, 32]
            # counter_size_list = [1]
        if args.str_args_1 == "large":
            counter_size_list = [64]

        # print("[Delay test 1]")
        # for counter_size in counter_size_list:
        #     for array_size in array_size_list:
        #         reg_table = REGISTER_TABLE(self.gc, self.bfrt_info, array_size, counter_size, args.str_args_1)
        #         reg_table.delay_test_1()
        #         reg_table.delay_test_2()



        # print("\n[Delay test 2]")
        # reg_table.delay_test_2(4096)

        # print("\n[Delay test 3]")
        # reg_table.delay_test_3(self.array_size)

        # print("\n[Delay test 4]")
        # reg_table.delay_test_4(self.array_size)

        for counter_size in counter_size_list:
            for array_size in array_size_list:
                print("%d %d" % (counter_size, array_size))
                reg_table = REGISTER_TABLE(self.gc, self.bfrt_info, array_size, counter_size, args.str_args_1)
                reg_table.reset_test()
