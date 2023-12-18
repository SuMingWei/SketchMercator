from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_generator import *
from sketch_formats.sketch_instance import *

import os
import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--out', type=str)
argparser.add_argument('--filename', type=str)
args = argparser.parse_args()


print("[load input]")
input_saver = PklSaver(args.folder, args.filename)
if input_saver.file_exist():
    input_workload_dict = input_saver.load()
    print("[success]")
    for key, value in input_workload_dict.items():
        print("-" * 10 + "["+ key + "]" + "-" * 10)
        print(len(value))
        for i, inst_list in enumerate(value, 1):
            # print(len(inst_list))
            print_inst_list(inst_list)
            if i == 2:
                break
else:
    print("Workload not exist, exit")
    exit(1)

# print("[load output]")
# out_saver = PklSaver(args.out, args.filename)
# if out_saver.file_exist():
#     output_dict = out_saver.load()
#     print("[success]")
#     # print(output_dict)
#     # print(output_dict["bruteforce"])
#     for key, value in output_dict["bruteforce"].items():
#         # print(key, len(value))
#         print(key, value)
# else:
#     print("No output file, create one")
