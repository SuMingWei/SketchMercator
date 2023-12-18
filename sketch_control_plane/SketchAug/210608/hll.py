from python_lib.pkl_saver import PklSaver
from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth
from sw_dp_simulator.file_io.py.read_hll import load_hll

import os

from hyperloglog import HyperLogLog

def get_cardinality(M, width):
    # hll = HyperLogLog(0.03) # 2048
    import math
    hll = HyperLogLog(1.04 / math.sqrt(width))

    new_list = []
    for item in M:
        new_list.append(item+1)
    hll.M = new_list

    return hll.card()


def relative_error(true, estimate):
    return abs(true-estimate)/true*100

def compute_cardinality(gt_result, hll_result, row, width):
    sketch_array_list = hll_result["sketch_array_list"]
 
    est_cardinality = get_cardinality(sketch_array_list[0][0:width], width)
 
    # print(sketch_array_list[0][0:width])
    # print(len(sketch_array_list[0][0:width]))
    true_cardinality = len(gt_result)
    re = relative_error(true_cardinality, int(est_cardinality))
    print(true_cardinality, int(est_cardinality), re)
    return re

def hll_main(gt_path, hll_path, hll_output_path, width, row):
    saver = PklSaver(hll_output_path, "data.pkl")
    result_list=[]
    for (a, b) in zip (sorted(os.listdir(gt_path)), sorted(os.listdir(hll_path))):
        # print(gt_path, hll_path)
        # print(a, b)
        specific_gt_path = os.path.join(gt_path, a)
        gt_result = load_ground_truth(specific_gt_path)

        specific_hll_path = os.path.join(hll_path, b)
        hll_result = load_hll(specific_hll_path, width, row)

        result = compute_cardinality(gt_result, hll_result, row, width)
        result_list.append(result)

    saver.save(result_list)
