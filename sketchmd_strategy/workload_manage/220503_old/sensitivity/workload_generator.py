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

if args.filename == "workload_1.pkl":
    for i in range(1, 13): # number of sketch algos
        default_input = get_default_spec()
        default_input[F1] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(i)

if args.filename == "workload_2.pkl":
    for i in range(1, 8):
        default_input = get_default_spec()
        default_input[F2] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(i)

if args.filename == "workload_3.pkl":
    for i in [[1], [2], [1, 2]]:
        default_input = get_default_spec()
        default_input[F3] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

if args.filename == "workload_4.pkl":
    for i in range(1, 6):
        default_input = get_default_spec()
        default_input[F4] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(i)

if args.filename == "workload_5.pkl":
    for i in [[0], [0, 1], [1]]:
        default_input = get_default_spec()
        default_input[F5] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

if args.filename == "workload_6.pkl":
    for i in [[0], [0, 1], [1]]:
        default_input = get_default_spec()
        default_input[F6] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

if args.filename == "workload_7.pkl":
    for i in [[0], [0, 1], [1]]:
        default_input = get_default_spec()
        default_input[F7] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

if args.filename == "workload_8.pkl":
    for i in [5, 10, 15, 20, 25, 30]:
        default_input = get_default_spec()
        default_input[F8] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(i)

if args.filename == "workload_9.pkl":
    for i in range(1, 9):
        default_input = get_default_spec()
        default_input[F9] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(i)

if args.filename == "workload_10.pkl":
    for i in [[1], [1, 2]]:
        default_input = get_default_spec()
        default_input[F10] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

if args.filename == "workload_11.pkl":
    for i in range(1, 6):
        default_input = get_default_spec()
        default_input[F11] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

if args.filename == "workload_12.pkl":
    for i in range(1, 8):
        default_input = get_default_spec()
        default_input[F12] = i
        candidate_input_spec.append(default_input)
        candidate_input_spec_name.append(str(i))

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
