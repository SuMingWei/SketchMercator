from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth_topk
from sw_dp_simulator.hash_module.py.hash import crc_hash

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def counter_estimate(key, data_list):
    hash_seed_list = [0x30243f0b, 0x0f79f523, 0x6b8cb0c5, 0x00390fc3, 0x298ac673]
    row = len(data_list)
    width = len(data_list[0])
    # print(row, width)
    a = []
    for i in range(0, row):
        index = crc_hash(key, [0, 0, hash_seed_list[i], 0x0, 0xFFFFFFFF]) % width
        a.append(data_list[i][index])
    a.sort()
    # print(a)
    return a[0]


def get_CM_ARE(gt_path, counter_data):
    ground_truth_data_list = load_ground_truth_topk(gt_path, 50)

    # sum = 0
    # for c in counter_data[0]:
    #     sum += c
    # print(sum)

    # sum = 0
    # for c in counter_data[1]:
    #     sum += c
    # print(sum)

    # sum = 0
    # for c in counter_data[2]:
    #     sum += c
    # print(sum)
    # return 0

    # exit(1)

    error_list = []
    for hh_key in ground_truth_data_list:
        key = hh_key[2]
        size = hh_key[1]
        estimate = counter_estimate(key, counter_data)
        re = relative_error(size, estimate)
        # print(size, estimate, re)
        error_list.append(re)
    return sum(error_list) / len(error_list)
