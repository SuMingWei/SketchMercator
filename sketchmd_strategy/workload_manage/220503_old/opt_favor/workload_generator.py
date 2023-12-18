from python_lib.pkl_saver import PklSaver
from workload_manage.generator import *
from workload_manage.spec import *
from lib.inst_list import print_inst_list

# import os
# import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--filename', type=str)
argparser.add_argument('--data_count', type=int)
args = argparser.parse_args()

DATA_COUNT = args.data_count

candidate_input_spec = []
candidate_input_spec_name = []

if args.filename == "workload_O2.pkl":
    F3_list = [[1, 2], [1, 2], [1, 2], [1], [1], [1], [1]]
    F4_list = [5, 5, 4, 3, 2, 1, 1]
    F9_list = [8, 7, 6, 5, 4, 3, 3]
    F10_list = [[1, 2], [1, 2], [1, 2], [1], [1], [1], [1]]
    F10_list = [[1, 2], [1, 2], [1, 2], [1], [1], [1], [1]]
    F11_list = [5, 5, 5, 5, 5, 5, 1]
    F12_list = [7, 6, 5, 4, 3, 2, 2]
    i = 0
    for f3, f4, f9, f10, f11, f12 in zip(F3_list, F4_list, F9_list, F10_list, F11_list, F12_list):
        default_input = get_default_spec()
        default_input[F3] = f3
        default_input[F4] = f4
        default_input[F9] = f9
        default_input[F10] = f10
        default_input[F11] = f11
        default_input[F12] = f12
        candidate_input_spec.append(default_input)
        i += 1
        candidate_input_spec_name.append(i)


if args.filename == "workload_O3.pkl":
    F3_list = [[1, 2], [1, 2], [1, 2], [1], [1], [1], [1]]
    F5_list = [[0, 1], [0, 1], [0, 1], [0], [0], [0], [0]]
    F9_list = [8, 6, 4, 3, 2, 1, 1]
    F11_list = [5, 5, 5, 5, 5, 5, 1]
    i = 0
    for f3, f5, f9, f11 in zip(F3_list, F5_list, F9_list, F11_list):
        default_input = get_default_spec()
        default_input[F3] = f3
        default_input[F5] = f5
        default_input[F9] = f9
        default_input[F11] = f11
        candidate_input_spec.append(default_input)
        i += 1
        candidate_input_spec_name.append(i)

if args.filename == "workload_O4.pkl":
    F4_list = [5, 4, 3, 2, 1, 1]
    F6_list = [[0, 1], [0, 1], [1], [1], [1], [1]]
    F11_list = [5, 5, 5, 5, 5, 5, 1]
    i = 0
    for f4, f6, f11 in zip(F4_list, F6_list, F11_list):
        default_input = get_default_spec()
        default_input[F4] = f4
        default_input[F6] = f6
        default_input[F11] = f11
        candidate_input_spec.append(default_input)
        i += 1
        candidate_input_spec_name.append(i)


print(candidate_input_spec_name)

saver = PklSaver(args.folder, args.filename)

workload_dict = {}
for input_spec, name in zip(candidate_input_spec, candidate_input_spec_name):
    print("name", name)

    workload_dict[str(name)] = []
    result_list = workload_dict[str(name)]

    for i in range(DATA_COUNT):
        generator = WorkloadGenerator(input_spec)
        while True:
            if generator.generate():
                break
        data = generator.result_inst_list
        result_list.append(data)

        # print_inst_list(data)
        # break
    # exit(1)
    print("data count:", i+1)

saver.save(workload_dict)
