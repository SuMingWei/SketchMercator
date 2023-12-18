from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth_cardinality
from hyperloglog import HyperLogLog

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def get_cardinality(M, width):
    import math
    hll = HyperLogLog(1.04 / math.sqrt(width))
    new_list = []
    for item in M:
        new_list.append(item+1)
    hll.M = new_list
    return hll.card()


def get_hll_error(param, gt_path, data):
    width = param
    true_cardinality = load_ground_truth_cardinality(gt_path)
    est = int(get_cardinality(data[0], width))
    re = relative_error(true_cardinality, est)
    print(true_cardinality, est, "%.2f" % re)
    return re
