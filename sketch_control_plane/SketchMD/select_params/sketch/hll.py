from sw_dp_simulator.file_io.py.read_hll import load_hll
from hyperloglog import HyperLogLog

def relative_error(true, estimate):
    return abs(true-estimate)/true

import os

def get_cardinality(M, width):
    import math
    hll = HyperLogLog(1.04 / math.sqrt(width))
    new_list = []
    for item in M:
        new_list.append(item+1)
    hll.M = new_list
    return hll.card()

    # # hll = HyperLogLog(0.03) # 2048
    # p = 0.7213/(1+1.079/width)
    # print(p)
    # # hll = HyperLogLog(0.7213/(1+1.079/width))
    # # hll = HyperLogLog(0.01)
    # # exit(1)
    # Z = 0
    # for item in M:
    #     Z += 2**(-1*item)
    # Z = 1/Z
    # return p * width * width * Z


def hll_main(sketch_name, output_dir, row, width, level):
    result = load_hll(output_dir, width, 1)
    true_cardinality = result["cardinality"]
    sim_cardinality = get_cardinality(result["sketch_array_list"][0], width)
    sim_error = relative_error(true_cardinality, sim_cardinality)*100
    # print(true_cardinality, int(sim_cardinality), sim_error)
    print("true(%d) est(%d) error(%.2f%%)" % (true_cardinality, sim_cardinality, sim_error))
    return [true_cardinality, sim_cardinality, sim_error]
