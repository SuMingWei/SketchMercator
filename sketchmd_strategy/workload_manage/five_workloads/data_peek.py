from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_instance import *
from lib.inst_list import *

import os
import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--filename', type=str)
args = argparser.parse_args()


print("[load input]")
input_saver = PklSaver(args.folder, args.filename)
if input_saver.file_exist():
    input_workload_dict = input_saver.load()


    # print("[success]")
    # for key, value in input_workload_dict.items():
    #     print("-" * 10 + "["+ key + "]" + "-" * 10)
    #     print(len(value))
    #     for i, inst_list in enumerate(value, 1):
    #         print_inst_list(sort_inst_list(inst_list))
    #         if i == 1:
    #             break

    # value = input_workload_dict['14']
    # print(value)
    for key, value in input_workload_dict.items():
        sketch_dict = {}
        for inst_list in value:
            for inst in inst_list:
                if inst.sketch.name not in sketch_dict.keys():
                    sketch_dict[inst.sketch.name] = 1
                else:
                    sketch_dict[inst.sketch.name] += 1
        print(args.filename, key)
        sketch_list = ['Entropy'] + ['Kary'] + ['MRAC'] + ['UnivMon']  + ['CountMin', 'CountSketch'] + ['BloomFilter', 'CountingBloomFilter'] + ['LinearCounting', 'HLL', 'MRB', 'PCSA']
        for k in sketch_list:
            print("%30s %5d" % (k, int(sketch_dict[k]/int(key))))
            # print
        print()
        print()
    # print(sketch_dict)

    # for key, value in input_workload_dict.items():

else:
    print("Workload not exist, exit")
    exit(1)
