from sw_dp_simulator.file_io.py.read_mrb import load_mrb
from sketch_control_plane.SketchAug.lib.common import counter_diff, relative_error

import os

def bitset(M):
    count = 0
    for item in M:
        if item == 1:
            count+=1
    return count

def bitzero(M):
    count = 0
    for item in M:
        if item == 0:
            count+=1
    return count

def get_cardinality(M, level, width):
    for base in reversed(range(0, level-1)):
        level_counter = M[base*width:(base+1)*width]
        if bitset(level_counter) > width/4:
            break

    base = base + 1
    # print(base)
    m = 0
    for i in range(base, level):
        level_counter = M[i*width:(i+1)*width]
        z = bitzero(level_counter)
        import math
        m = m + width * (math.log(width/z))
    card = m*2**(base)
    return int(card)



def mrb_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters, sim_full_path):
    # print(sim_full_path)
    w = int(array_size/16)
    l = 16
    d = 1
    # bname = os.path.basename(sim_full_path)
    # print(bname)
    # # if bname != "03":
    # #     return

    result = load_mrb(sim_full_path, w, d, l)
    if result['count_list'][0] == 0:
        return (0, 0, 0, 0, 0, 0, 0, 0)
    sim_total = []
    for i in range(0, l):
        sim_total += result["sketch_array_list"][i]

    true_cardinality = result["cardinality"]
    # print(true_cardinality)
    sim_cardinality = get_cardinality(sim_total, l, w)
    sim_error = relative_error(true_cardinality, sim_cardinality)

    tofino_cardinality = get_cardinality(tofino_counters, l, w)
    tofino_error = relative_error(true_cardinality, tofino_cardinality)

    wrong, sum = counter_diff(sim_total, tofino_counters)

    tuple = (wrong, sum, array_size, true_cardinality, sim_cardinality, sim_error, tofino_cardinality, tofino_error)
    print("wrong_count(%d) wrong_sum(%d) total_array_size(%d) true(%d) sim(%d) sim_error(%.2f) tofino(%d) tofino_error(%.2f)" % tuple)
    return tuple
