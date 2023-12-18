from python_lib.pkl_saver import PklSaver
from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth
from sw_dp_simulator.file_io.py.read_cs import load_cs

from sw_dp_simulator.hash_module.py.hash import compute_hash

import os

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level, compact_hash = False):
    a = []

    if compact_hash == False:
        for i in range(0, d):
            index = compute_hash(key, hash, index_hash_sub_list[i], w)
            res = compute_hash(key, hash, res_hash_sub_list[i], 2)
            res = res * 2 - 1
            estimate = sketch_array[i * w + index] * res
            a.append(estimate)

    else:
        long_hash = compute_hash(key, hash, res_hash_sub_list[0], 4294967296)
        for i in range(0, d):
            index = compute_hash(key, hash, index_hash_sub_list[i], w)
            res = (long_hash>>i) & 1
            res = res * 2 - 1

            estimate = sketch_array[i * w + index] * res
            a.append(estimate)

    a.sort()

    middle = int(d/2)

    if d % 2 == 0:
        return int((a[middle] + a[middle-1]) / 2)
    else:
        return int(a[middle])

def relative_error(true, estimate):
    return abs(true-estimate)/true*100

def compute_ARE(gt_result, cs_result, d, w):
    sampling_hash_list = cs_result["sampling_hash_list"]
    index_hash_list = cs_result["index_hash_list"]
    res_hash_list = cs_result["res_hash_list"]
    sketch_array_list = cs_result["sketch_array_list"]
    sum = 0

    # topk = 10
    topk = 50

    for i in range(0, topk):
        true_flow_count = gt_result[i][1]
        flowkey = gt_result[i][2]
        i = 0
        est = counter_estimate(flowkey, sketch_array_list[0], index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0, False)
        # print(true_flow_count, est)
        error = relative_error(true_flow_count, est)

        # print(true_flow_count, est, error)
        sum += error
    print("ARE: ", sum / topk)
    return sum / topk

def cs_main(gt_path, cs_path, cp_output_path, width, row):
    saver = PklSaver(cp_output_path, "data.pkl")
    result_list=[]
    print(gt_path)
    print(cs_path)
    for (a, b) in zip (sorted(os.listdir(gt_path)), sorted(os.listdir(cs_path))):
        print(a, b)
        specific_gt_path = os.path.join(gt_path, a)
        gt_result = load_ground_truth(specific_gt_path)

        specific_cs_path = os.path.join(cs_path, b)
        cs_result = load_cs(specific_cs_path, width, row)

        result = compute_ARE(gt_result, cs_result, row, width)
        result_list.append(result)

    saver.save(result_list)
