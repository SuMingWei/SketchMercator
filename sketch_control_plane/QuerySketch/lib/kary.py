from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth, load_ground_truth_topk
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


def get_kary_ARE(gt_path_1, counter_data_1, gt_path_2, counter_data_2, threshold):
    gt_result_1 = load_ground_truth(gt_path_1)
    gt_result_2 = load_ground_truth_topk(gt_path_2, 50)

    error_list = []
    for hh_key_2 in gt_result_2:
        key2 = hh_key_2[2]
        size2 = hh_key_2[1]

        prev_key = 0
        prev_size = 0
        for hh_key_1 in gt_result_1:
            key1 = hh_key_1[2]
            size1 = hh_key_1[1]
            if key2 == key1:
                prev_key = key1
                prev_size = size1

        if size2 - prev_size > threshold:
            # print(prev_key)
            # print(key2)
            # print(prev_size, size2, size2 - prev_size)
            diff = size2 - prev_size
            estimate = counter_estimate(key2, counter_data_2) - counter_estimate(key2, counter_data_1)
            re = relative_error(diff, estimate)
            # print(diff, estimate, re)
            error_list.append(re)

    if len(error_list) == 0:
        return 0
    else:
        return sum(error_list) / len(error_list)
