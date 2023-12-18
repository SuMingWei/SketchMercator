import os
import sys
import argparse

from python_lib.pkl_saver import PklSaver
from python_lib.perf_timer import PerfTimer
from python_lib.timeout import TimeoutManager

from o1o2o3o4.bruteforce.bruteforce import *
from o1o2o3o4.greedy.greedy import *
from o5.o5_main import *

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--out', type=str)
argparser.add_argument('--filename', type=str)
argparser.add_argument('--run', type=str)
argparser.add_argument('--type1', type=str)
argparser.add_argument('--type2', type=str)
args = argparser.parse_args()

# # print(args.run)

print("|" * 50)
print(args.filename)
print("[load input]")
input_saver = PklSaver(args.folder, args.filename)
if input_saver.file_exist():
    input_workload_dict = input_saver.load()
    print("[success]")
    for key, value in input_workload_dict.items():
        print(key, len(value))
    # print(workload_dict)
else:
    print("Workload not exist, exit")
    exit(1)
print("|" * 50)
print("")

print("|" * 50)
print("[load output]")
out_saver = PklSaver(args.out, args.filename)
if out_saver.file_exist():
    output_dict = out_saver.load()
    print("[success]")
else:
    print("no output file, create one")
    output_dict = {}
    output_dict["o5"] = {}

    output_dict["bf"] = {}

    output_dict["gd"] = {}
    output_dict["gd"]["bf"] = {}
    output_dict["gd"]["bf"]["bf"] = {}
    output_dict["gd"]["bf"]["gd"] = {}

    output_dict["gd"]["gd"] = {}
    output_dict["gd"]["gd"]["bf"] = {}
    output_dict["gd"]["gd"]["gd"] = {}

    out_saver.save(output_dict)
print("|" * 50)
print("")

if args.run == "bf":
    data_dict = output_dict["bf"]
else:
    data_dict = output_dict["gd"][args.type1][args.type2]

o5_data_dict = output_dict["o5"]


def run_func(data_sample, args, return_dict):
    result = greedy_main(data_sample, args.type1, args.type2, False)
    return_dict["result"] = result

j = 0
for key, value in input_workload_dict.items():
    j += 1
    if args.run == "bf" and j > 6:
        break
    if key not in data_dict:
        data_dict[key] = []
    if key not in o5_data_dict:
        o5_data_dict[key] = []

    print(key)
    if key == "workload1-1":
        data_sample = value[2]
        timer = PerfTimer('run')

        if args.run == "bf":
            result = bruteforce_main(data_sample)
        else:
            timeout_manager = TimeoutManager(3, run_func, [data_sample, args])
            if timeout_manager.start():
                # print("success")
                return_dict = timeout_manager.get_return_dict()
                result = return_dict["result"]
                # print(result)
            else:
                # print("timeout, try gdgd")
            result = greedy_main(data_sample, "gd", "gd", True)
                # print(result)
        time = timer.end()
        print("time:", time)
        print_answer_list(result)
        exit(1)
        # data_dict[key].append((time, data_sample, result))
        # out_saver.save(output_dict)
        # exit(1)

#         else:
#             print("   => run skip")

#         if count > len(o5_data_dict[key]):
#             timer = PerfTimer('o5')
#             result = o5_main(data_sample)
#             time = timer.end()

#             o5_data_dict[key].append((time, data_sample, result))
#             # out_saver.save(output_dict)
#         else:
#             print("   => o5 skip")

# out_saver.save(output_dict)
