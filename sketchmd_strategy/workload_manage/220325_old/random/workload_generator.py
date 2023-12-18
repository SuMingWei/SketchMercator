from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_generator import generate_sketch
from sketch_formats.sketch_instance import *

import os
import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--filename', type=str)
argparser.add_argument('--data_count', type=int)
args = argparser.parse_args()


saver = PklSaver(args.folder, args.filename)
if saver.file_exist():
    workload_dict = saver.load()
    print("Workload already exist")
    for key, value in workload_dict.items():
        print(key, len(value))
    # print(workload_dict)
else:
    print("Workload not exist, create empty one")
    workload_dict = {}
    saver.save(workload_dict)

# input_list = list(range(5, 45, 5))

# input_list = [2,4,6,8,10,12,14,16,18,20,25,30,35,40]
input_list = [2,4,6,8,10,12,14,16,18,20,25,30]
# workload_dict = {}
# input_list = [40]

for sketch_count in input_list:
    if sketch_count not in workload_dict:
        workload_dict[sketch_count] = []
    result_list = workload_dict[sketch_count]

    for i in range(args.data_count):
        data = generate_sketch_default(sketch_count)
        result_list.append(data)


saver.save(workload_dict)
