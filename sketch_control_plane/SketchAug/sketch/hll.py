from sw_dp_simulator.file_io.py.read_hll import load_hll
from sketch_control_plane.SketchAug.lib.common import counter_diff, relative_error
from hyperloglog import HyperLogLog

import os

def get_cardinality(M, width):
    hll = HyperLogLog(0.03) # 2048
    import math
    # hll = HyperLogLog(1.04 / math.sqrt(width))

    new_list = []
    for item in M:
        new_list.append(item+1)
    hll.M = new_list

    return hll.card()

def hll_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters, sim_full_path):
    # print(sim_full_path)
    w = array_size
    l = 1
    d = 1
    bname = os.path.basename(sim_full_path)
    # print(bname)
    # if bname == "05":
    #     exit(1)

    result = load_hll(sim_full_path, w, d)
    if result['count_list'][0] == 0:
        return (0, 0, 0, 0, 0, 0, 0, 0)
    sim_total = result["sketch_array_list"][0]

    true_cardinality = result["cardinality"]
    # print(true_cardinality)

    sim_cardinality = get_cardinality(sim_total, w)
    sim_error = relative_error(true_cardinality, sim_cardinality)

    tofino_cardinality = get_cardinality(tofino_counters, w)
    tofino_error = relative_error(true_cardinality, tofino_cardinality)

    wrong, sum = counter_diff(sim_total, tofino_counters)

    tuple = (wrong, sum, w, true_cardinality, sim_cardinality, sim_error, tofino_cardinality, tofino_error)
    print("wrong_count(%d) wrong_sum(%d) total_array_size(%d) true(%d) sim(%d) sim_error(%.2f) tofino(%d) tofino_error(%.2f)" % tuple)
    return tuple
