from sw_dp_simulator.file_io.py.read_cs import load_cs
from sw_dp_simulator.hash_module.py.hash import compute_hash

import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

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

def get_ARE(result, cArray, d, w):

    gt_result = result["gt"]
    sampling_hash_list = result["sampling_hash_list"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]
    sketch_array_list = result["sketch_array_list"]

    topk = 100
    sum = 0
    for i in range(0, min(topk, len(gt_result))):
        true_flow_count = gt_result[i][1]
        flowkey = gt_result[i][2]
        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0, True)
        # print(true_flow_count, est)
        error = relative_error(true_flow_count, est)
        sum += error

    # print("ARE: ", sum / topk)
    # print()
    return sum / topk


def get_f2(result, cArray, d, w):

    f2 = result["f2"]

    a = []
    for i in range(0, d):
        sum = 0
        for j in range(0, w):
            sum += cArray[i*w + j] * cArray[i*w + j]
        a.append(sum)

    a.sort()

    middle = int(d/2)

    if d % 2 == 0:
        f2_est = int((a[middle] + a[middle-1]) / 2)
    else:
        f2_est = int(a[middle])
    
    return [f2, f2_est, relative_error(f2, f2_est)]


def cs_main(sketch_name, output_dir, row, width, level):
    result = load_cs(output_dir, width, row)
    sim_total = result["sketch_array_list"][0]
    sim_ARE_error = get_ARE(result, sim_total, row, width)
    f2_error = get_f2(result, sim_total, row, width)
    # return [sim_ARE_error]
    return sim_ARE_error
