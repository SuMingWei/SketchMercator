from sw_dp_simulator.file_io.py.read_cs import load_cs
from sketch_control_plane.SketchAug.lib.common import counter_diff, relative_error
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

def get_f2(counter, width, row):
    a = []
    for r in range(0, row):
        sum = 0
        for w in range(0, width):
            sum += counter[width*r + w] * counter[width*r + w]
        a.append(sum)
    # print(a)
    # print(a.sort())
    return int((a[1] + a[2]) / 2)

def cs_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters, sim_full_path):
    # print(sim_full_path)
    w = array_size
    l = 1
    d = 4
    bname = os.path.basename(sim_full_path)
    # print(bname)
    # if bname == "05":
    #     exit(1)

    result = load_cs(sim_full_path, w, d)
    if result['count_list'][0] == 0:
        return (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    sim_total = result["sketch_array_list"][0]

    true_f2 = result["f2"]
    # print(true_f2)

    sim_f2 = get_f2(sim_total, w, 4)
    sim_error = relative_error(true_f2, sim_f2)

    tofino_f2 = get_f2(tofino_counters, w, 4)
    tofino_error = relative_error(true_f2, tofino_f2)

    wrong, sum = counter_diff(sim_total, tofino_counters)
    
    sim_ARE_error = get_ARE(result, sim_total, d, w)
    tofino_ARE_error = get_ARE(result, tofino_counters, d, w)

    tuple = (wrong, sum, w*d, true_f2, sim_f2, sim_error, tofino_f2, tofino_error, sim_ARE_error, tofino_ARE_error)
    print("wrong_count(%d) wrong_sum(%d) total_array_size(%d) true(%d) sim(%d) sim_error(%.2f) tofino(%d) tofino_error(%.2f) sim_ARE_error(%.2f) tofino_ARE_error(%.2f)" % tuple)
    return tuple
