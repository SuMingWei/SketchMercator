from sw_dp_simulator.file_io.py.read_cm import load_cm
from sketch_control_plane.SketchAug.lib.common import counter_diff, relative_error
from sw_dp_simulator.hash_module.py.hash import compute_hash
import os

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level):
    a = []

    for i in range(0, d):
        index = compute_hash(key, hash, index_hash_sub_list[i], w)
        estimate = sketch_array[i * w + index]
        a.append(estimate)

    a.sort()
    return a[0]

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
        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0)
        # print(i, true_flow_count, est)
        error = relative_error(true_flow_count, est)
        sum += error

    # print("ARE: ", sum / topk)
    # print()
    return sum / topk

def cm_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters, sim_full_path):
    # print(sim_full_path)
    w = array_size
    l = 1
    d = 4
    bname = os.path.basename(sim_full_path)
    # print(bname)
    # if bname == "05":
    #     exit(1)

    result = load_cm(sim_full_path, w, d)
    if result['count_list'][0] == 0:
        return (0, 0, 0, 0, 0)
    sim_total = result["sketch_array_list"][0]

    # print("Sim error")
    sim_error = get_ARE(result, sim_total, d, w)

    # print("Tofino error")
    tofino_error = get_ARE(result, tofino_counters, d, w)

    wrong, sum = counter_diff(sim_total, tofino_counters)

    tuple = (wrong, sum, w*d, sim_error, tofino_error)
    print("wrong_count(%d) wrong_sum(%d) total_array_size(%d) sim_error(%.2f) tofino_error(%.2f)" % tuple)
    # exit(1)
    return tuple
