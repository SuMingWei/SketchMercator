from sketch_cp.sketch import Sketch
from perf_timer import PerfTimer

class CountSketch(Sketch):

    def __init__(self, args):
        super(CountSketch, self).__init__(args)

        from module.countsketch.flowkey_learn import FLOWKEY_LEARN
        self.flowkey_learn = FLOWKEY_LEARN(self.gc, self.bfrt_info, args.is_simulator, is_print=True)

    def configure(self, args):
        super(CountSketch, self).configure()

        # threshold insert
        from module.countsketch.table.threshold_insert_table import THRESHOLD_INSERT
        threshold_insert = THRESHOLD_INSERT(self.gc, self.bfrt_info)
        threshold_insert.setup(args.int_date)

        # flowkey threshold table
        from module.countsketch.table.threshold_table import THRESHOLD
        threshold = THRESHOLD(self.gc, self.bfrt_info)
        threshold.setup()

    def read(self, args):
        from module.countsketch.table.register_table import REGISTER_TABLE
        # timer = PerfTimer('Total')
        for cs_index in range(1, 6):
            reg_table = REGISTER_TABLE(self.gc, self.bfrt_info, cs_index, args.is_simulator)

            # reg_table.load_registers()
            # reg_table.tableClear()
            # reg_table.save_to_file(args.foldername, "cs_%d.txt" % cs_index)
            for i in range(0, 1):
                print("[[[%d]]]" % (i+1))
                reg_table.delay_test()
            # size = 2048
            size = 4096
            # size = 8192
            # size = 12288
            # size = 16384
            # size = 20480
            # size = 32768
            # size = 36864
            # size = 65536
            print("delta_1_%d = %s" % (size, str(reg_table.result1)))
            print("delta_2_%d = %s" % (size, str(reg_table.result2)))
            print("delta_3_%d = %s" % (size, str(reg_table.result3)))
            # # for i in range(0, 5):
            # timer.lap_10_milli()
            break

    def flowkey_sniff(self, args):
        print("come to flowkey")
        self.flowkey_learn.sniff()
        # flowkey_learn.sniff()
        # while run:
        #     flowkey_learn.sniff()
        # pass

    def flowkey_test(self):
        print("come to flowkey")
        print(self.flowkey_learn.from_hash_table)
