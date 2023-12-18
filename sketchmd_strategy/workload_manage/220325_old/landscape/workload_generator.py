from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_generator import *
from sketch_formats.sketch_instance import *

import os
import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--filename', type=str)
argparser.add_argument('--data_count', type=int)
args = argparser.parse_args()

FIXED_SKETCH_INSTANCE_COUNT = 25
DATA_COUNT = args.data_count


input_dict_list = []
name_list = []

# included!
# 20% worst case with no heavy storage, 8 flowkeys, 2 flowsize, etc, etc
input_dict = {}
input_dict["candidate_flowkeys"] = 8
input_dict["candidate_flowsize"] = [1, 2]
input_dict["candidate_epochs"] = [5, 10, 15, 20, 25, 30, 35]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 5
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0]
input_dict_list.append(input_dict)
name_list.append("workload1-1")

# included!
# 25% medium case with no heavy storage, 4 flowkeys, 2 flowsize, etc, etc, 
input_dict = {}
input_dict["candidate_flowkeys"] = 6
input_dict["candidate_flowsize"] = [1]
input_dict["candidate_epochs"] = [10, 20, 30]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 3
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0]
input_dict_list.append(input_dict)
name_list.append("workload1-2")

# included!
# 35% best case with no heavy storage, 4 flowkeys, 1 flowsize, etc, etc, 
input_dict = {}
input_dict["candidate_flowkeys"] = 4
input_dict["candidate_flowsize"] = [1]
input_dict["candidate_epochs"] = [10, 20]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 2
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0]
input_dict_list.append(input_dict)
name_list.append("workload1-3")

# included!
# 42% worst case with only heavy storage, 4 flowkeys, 2 flowsize, etc, etc, 
input_dict = {}
input_dict["candidate_flowkeys"] = 8
input_dict["candidate_flowsize"] = [1, 2]
input_dict["candidate_epochs"] = [5, 10, 15, 20, 25, 30, 35]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 5
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [1]
input_dict_list.append(input_dict)
name_list.append("workload2-1")

# included!
# 45% medium case with only heavy storage, 6 flowkeys, 1 flowsize, etc, etc, 
input_dict = {}
input_dict["candidate_flowkeys"] = 6
input_dict["candidate_flowsize"] = [1]
input_dict["candidate_epochs"] = [10, 20, 30]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 3
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [1]
input_dict_list.append(input_dict)
name_list.append("workload2-2")

# included!
# 46% best case with only heavy storage, 5 flowkeys, 1 flowsize, etc, etc, 
input_dict = {}
input_dict["candidate_flowkeys"] = 5
input_dict["candidate_flowsize"] = [1]
input_dict["candidate_epochs"] = [10, 20, 30]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 2
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [1]
input_dict_list.append(input_dict)
name_list.append("workload2-3")

# 33%
input_dict = {}
input_dict["candidate_flowkeys"] = 8
input_dict["candidate_flowsize"] = [1, 2]
input_dict["candidate_epochs"] = [5, 10, 15, 20, 25, 30, 35]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 5
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0,1]
input_dict_list.append(input_dict)
name_list.append("workload3-1")

# # 31%
# input_dict = {}
# input_dict["candidate_flowkeys"] = 8
# input_dict["candidate_flowsize"] = [1, 2]
# input_dict["candidate_epochs"] = [10, 20, 30]
# input_dict["candidate_rows"] = 5
# input_dict["candidate_index_type"] = [1, 2]
# input_dict["candidate_counter_update"] = 5
# input_dict["candidate_counter_value_in_dp"] = [0,1]
# input_dict["candidate_sampling_compatible"] = [0,1]
# input_dict["candidate_heavy_storage"] = [0,1]
# input_dict_list.append(input_dict)
# name_list.append("workload3-2")

# # 33%
# input_dict = {}
# input_dict["candidate_flowkeys"] = 8
# input_dict["candidate_flowsize"] = [1, 2]
# input_dict["candidate_epochs"] = [10, 20]
# input_dict["candidate_rows"] = 5
# input_dict["candidate_index_type"] = [1, 2]
# input_dict["candidate_counter_update"] = 5
# input_dict["candidate_counter_value_in_dp"] = [0,1]
# input_dict["candidate_sampling_compatible"] = [0,1]
# input_dict["candidate_heavy_storage"] = [0,1]
# input_dict_list.append(input_dict)
# name_list.append("workload3-3")

# # 34%
# input_dict = {}
# input_dict["candidate_flowkeys"] = 6
# input_dict["candidate_flowsize"] = [1, 2]
# input_dict["candidate_epochs"] = [10, 20]
# input_dict["candidate_rows"] = 5
# input_dict["candidate_index_type"] = [1, 2]
# input_dict["candidate_counter_update"] = 5
# input_dict["candidate_counter_value_in_dp"] = [0,1]
# input_dict["candidate_sampling_compatible"] = [0,1]
# input_dict["candidate_heavy_storage"] = [0,1]
# input_dict_list.append(input_dict)
# name_list.append("workload3-4")

# 38%
input_dict = {}
input_dict["candidate_flowkeys"] = 4
input_dict["candidate_flowsize"] = [1, 2]
input_dict["candidate_epochs"] = [10, 20]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 5
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0,1]
input_dict_list.append(input_dict)
name_list.append("workload3-5")


# # 38%
# input_dict = {}
# input_dict["candidate_flowkeys"] = 4
# input_dict["candidate_flowsize"] = [1, 2]
# input_dict["candidate_epochs"] = [10, 20]
# input_dict["candidate_rows"] = 5
# input_dict["candidate_index_type"] = [1, 2]
# input_dict["candidate_counter_update"] = 3
# input_dict["candidate_counter_value_in_dp"] = [0,1]
# input_dict["candidate_sampling_compatible"] = [0,1]
# input_dict["candidate_heavy_storage"] = [0,1]
# input_dict_list.append(input_dict)
# name_list.append("workload3-6")

# 48%
input_dict = {}
input_dict["candidate_flowkeys"] = 4
input_dict["candidate_flowsize"] = [1, 2]
input_dict["candidate_epochs"] = [10, 20]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1, 2]
input_dict["candidate_counter_update"] = 1
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0,1]
input_dict_list.append(input_dict)
name_list.append("workload3-7")

# 54%
input_dict = {}
input_dict["candidate_flowkeys"] = 4
input_dict["candidate_flowsize"] = [1, 2]
input_dict["candidate_epochs"] = [10, 20]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1]
input_dict["candidate_counter_update"] = 1
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0,1]
input_dict_list.append(input_dict)
name_list.append("workload3-8")

# 63%
input_dict = {}
input_dict["candidate_flowkeys"] = 4
input_dict["candidate_flowsize"] = [1]
input_dict["candidate_epochs"] = [10, 20]
input_dict["candidate_rows"] = 5
input_dict["candidate_index_type"] = [1]
input_dict["candidate_counter_update"] = 1
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0,1]
input_dict_list.append(input_dict)
name_list.append("workload3-9")

# 72%
input_dict = {}
input_dict["candidate_flowkeys"] = 4
input_dict["candidate_flowsize"] = [1]
input_dict["candidate_epochs"] = [10, 20]
input_dict["candidate_rows"] = 1
input_dict["candidate_index_type"] = [1]
input_dict["candidate_counter_update"] = 1
input_dict["candidate_counter_value_in_dp"] = [0,1]
input_dict["candidate_sampling_compatible"] = [0,1]
input_dict["candidate_heavy_storage"] = [0,1]
input_dict_list.append(input_dict)
name_list.append("workload3-10")

saver = PklSaver(args.folder, args.filename)
if saver.file_exist():
    workload_dict = saver.load()
    print("Workload already exist")
    # for key, value in workload_dict.items():
    #     print(key, len(value))
    # print(workload_dict)
else:
    print("Workload not exist, create empty one")
    workload_dict = {}
    saver.save(workload_dict)

print("always over write")
workload_dict = {}
saver.save(workload_dict)

for name, input_dict in zip(name_list, input_dict_list):

    print("name", name)
    if name not in workload_dict:
        workload_dict[name] = []
    result_list = workload_dict[name]

    for i in range(DATA_COUNT):
        while True:
            data = generate_sketch_landscape(FIXED_SKETCH_INSTANCE_COUNT, input_dict)
            if len(data) >= FIXED_SKETCH_INSTANCE_COUNT:
                break
            print(len(data), "retry")
        # print(len(data))
        result_list.append(data)
        # print_inst_list(data)
    print("data count:", i+1)


saver.save(workload_dict)
