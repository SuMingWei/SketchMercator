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

# I1. Flowkey
# I2. Flowsize
# I3. Epoch
# I4. Sketch Parameters (# of Rows)

if args.filename == "workload_varing_flowkey.pkl":
    WORKLOAD_TYPE = FLOWKEY_TYPE
    INPUT = [1, 2, 3, 4, 5, 6, 7, 8]

if args.filename == "workload_varing_flowsize.pkl":
    WORKLOAD_TYPE = FLOWSIZE_TYPE
    INPUT = [1, 2]

if args.filename == "workload_varing_epoch.pkl":
    WORKLOAD_TYPE = EPOCH_TYPE
    INPUT = [1, 2, 3, 4, 5, 6, 7]

if args.filename == "workload_varing_sketch_parameter.pkl":
    WORKLOAD_TYPE = SKETCH_PARAMETER_TYPE
    INPUT = [1, 2, 3, 4, 5]

# B1. Index Computing Type
# B2. Counter Update Type
# B3. Counter Value in DP
# B4. Sampling Compatible
# B5. Heavy Flowkey Storage

if args.filename == "workload_varing_counter_update_type.pkl":
    WORKLOAD_TYPE = COUNTER_UPDATE_TYPE
    INPUT = [1, 2, 3, 4, 5]

if args.filename == "workload_varing_index_couputing_type.pkl":
    WORKLOAD_TYPE = INDEX_COMPUTING_TYPE
    INPUT = [[1], [2], [1, 2]]

if args.filename == "workload_varing_counter_value_in_dp.pkl":
    WORKLOAD_TYPE = COUNTER_VALUE_IN_DP_TYPE
    INPUT = [[0], [0, 1]] # [[0], [1], [0, 1]] [1] takes too long time for current greedy

if args.filename == "workload_varing_sampling_compatible.pkl":
    WORKLOAD_TYPE = SAMPLING_COMPATIBLE_TYPE
    INPUT = [[0], [0, 1]] # [[0], [1], [0, 1]] [1] takes too long time for current greedy

if args.filename == "workload_varing_heavy_flowkey.pkl":
    WORKLOAD_TYPE = HEAVY_FLOWKEY_TYPE
    INPUT = [[0], [0, 1]] # [[0], [1], [0, 1]] [1] takes too long time for current greedy


saver = PklSaver(args.folder, args.filename)
if saver.file_exist():
    workload_dict = saver.load()
    print("Workload already exist")
    for key, value in workload_dict.items():
        print(key, len(value))
    print(workload_dict)
else:
    print("Workload not exist, create empty one")
    workload_dict = {}
    saver.save(workload_dict)

for input in INPUT:
    print("input:", input)
    if str(input) not in workload_dict:
        workload_dict[str(input)] = []
    result_list = workload_dict[str(input)]

    for i in range(DATA_COUNT):
        # print("data count:", i+1)
        # pass
        data = generate_sketch_sensitivity(FIXED_SKETCH_INSTANCE_COUNT, WORKLOAD_TYPE, input)
        # print_inst_list(data)
        result_list.append(data)
    print("data count:", i+1)


saver.save(workload_dict)
