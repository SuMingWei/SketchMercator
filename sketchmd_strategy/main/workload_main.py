import os
import sys
import argparse

from python_lib.pkl_saver import PklSaver
from python_lib.perf_timer import PerfTimer

from lib.logging import print_msg
from o1.bruteforce import *
from o1.greedy import *
from o2.bruteforce import *
from o2.greedy import *
from o3.o3_main import *

from time import sleep

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--input', type=str)
argparser.add_argument('--output', type=str)
argparser.add_argument('--filename', type=str)
argparser.add_argument('--run', type=str)
argparser.add_argument('--timeout_O1', type=int)
argparser.add_argument('--timeout_O2', type=int)

args = argparser.parse_args()

def read_workload(args):
    print_msg("|" * 50, 1, "green")
    print_msg(args.filename, 1, "green")
    print_msg("[load input]", 1, "green")
    input_saver = PklSaver(args.input, args.filename)
    if input_saver.file_exist():
        print_msg("[load input success]", 1, "green")
        input_workload_dict = input_saver.load()
        for key, value in input_workload_dict.items():
            # print_msg(f"{key} {len(value)}", 1, "green")
            pass
        # print(workload_dict)
    else:
        print_msg("Workload not exist, exit", 1, "red")
        exit(1)
    print_msg("|" * 50, 1, "green")
    # print_msg("", 1, "green")
    return input_workload_dict


def check_progress(args, key):

    log_level = 3
    print_msg("|" * 50, log_level, "green")
    print_msg("[load output]", log_level, "green")
    output_path = os.path.join(args.output, args.filename.split(".pkl")[0])
    if args.run == "bf":
        return_path = "bf"
        output_path = os.path.join(output_path, return_path)
    else:
        return_path = os.path.join("gd", f"{args.timeout_O1}_{args.timeout_O2}")
        output_path = os.path.join(output_path, return_path)
    filename = f"{key}.pkl"
    return_path = os.path.join(return_path, filename)

    out_saver = PklSaver(output_path, filename)
    if out_saver.file_exist():
        output_list = out_saver.load()
        print_msg("[load output success]", log_level, "green")
    else:
        print_msg("no output file, create one", log_level, "yellow")
        output_list = []
        out_saver.save(output_list)

    print_msg("|" * 50, log_level, "green")
    print_msg("", log_level, "green")

    return return_path, output_list, out_saver


def run_data_set(args, key, data_set, total_size):

    pkl_path, output_list, out_saver = check_progress(args, key)
    total_dataset_size = len(data_set)

    for data_sample_count, data_sample in enumerate(data_set, 1):
        msg = f"[{pkl_path}] [{key}] {j}/{total_size} (data sample - {data_sample_count}/{total_dataset_size})"
        print_msg(msg, 3, "white")


        if data_sample_count > len(output_list):
            timer = PerfTimer('o2')
            if args.run == "bf":
                o2_result = o2_bruteforce_main(data_sample)
            else:
                o2_result = o2_greedy_main(data_sample, args.timeout_O2)
            o2_time = timer.end()
            o2_data = (o2_result, o2_time)

            timer = PerfTimer('o1')
            # o1_result = o1_bruteforce_main(data_sample, o2_result)
            if args.run == "bf":
                o1_result = o1_bruteforce_main(data_sample, o2_result)
            else:
                o1_result = o1_greedy_main(data_sample, args.timeout_O1, o2_result)
            o1_time = timer.end()
            o1_data = (o1_result, o1_time)
            # o1_data = ("A", "A")

            timer = PerfTimer('o3')
            o3_result = o3_main(data_sample)
            o3_time = timer.end()
            o3_data = (o3_result, o3_time)

            output_list.append((data_sample, o1_data, o2_data, o3_data))
            out_saver.save(output_list)
        else:
            print_msg("   => skip", 3, "cyan")
    # exit(1)

    # out_saver.save(output_dict)

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

data_dict = {}
for workload_name in sorted(os.listdir(args.input)):
    args.filename = workload_name
    data_dict[workload_name] = read_workload(args)

from sketchmd_strategy.lib.logging import SELECT_MODE, NORMAL_MODE, TESTCASE_MODE
if SELECT_MODE == NORMAL_MODE:
    # key_list = [str(i) for i in range(2, 11, 2)]
    key_list = [str(i) for i in range(2, 25, 2)]
    total_size = len(key_list)
    for j, key in enumerate(key_list, 1):
        for workload_name in sorted(os.listdir(args.input)):
            args.filename = workload_name
            data_set = data_dict[workload_name][key]
            msg = f"[{workload_name}] [{key}] {j}/{total_size}"
            print_msg(msg, 2, "white")

            # if j == 2:
            #     run_data_set(args, key, data_set, total_size)
            # run_data_set(args, key, data_set, total_size)
            # exit(1)
            # break
            helper.call(run_data_set, (args, key, data_set, total_size, ))

else:
    for workload_name in sorted(os.listdir(args.input)):
        args.filename = workload_name
        print(workload_name)
        # if workload_name != "workload_testcase.pkl":
        #     continue

        input_workload_dict = read_workload(args)


        j = 0
        total_size = len(input_workload_dict.keys())
        print(input_workload_dict.keys())

        for key, data_set in input_workload_dict.items():
            run_data_set(args, key, data_set, total_size)


            # j += 1
            # print(key)
            # if key == 1:
            #     print("int?")
            # if key == "1":
            #     print("str?")
            # msg = f"[{args.filename}] [{key}] {j}/{total_size}"
            # print_msg(msg, 2, "white")
            # # if j == 2:
            # #     run_data_set(args, key, data_set, total_size)
            # # exit(1)
            # # break
            # # helper.call(run_data_set, (args, key, data_set, total_size, ))




# sketch_count_check = {}
# if args.filename != "workload_1.pkl":
#     if data_sample_count > 3:
#         break
# else:
#     if len(sketch_count_check.keys()) == 12:
#         break
#     sketch_name = data_sample[0].sketch.name
#     if sketch_name not in sketch_count_check:
#         sketch_count_check[sketch_name] = 0
#     if sketch_count_check[sketch_name] >= 1:
#         continue
#     sketch_count_check[sketch_name]+=1
