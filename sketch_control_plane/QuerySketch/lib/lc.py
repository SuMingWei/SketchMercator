from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth_cardinality

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

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

def get_cardinality(M, width):
    z = bitzero(M)
    import math
    return width * math.log(width/z)

def get_lc_error(param, gt_path, data):
    width = param
    # print(width)
    true_cardinality = load_ground_truth_cardinality(gt_path)
    est = int(get_cardinality(data[0], width))
    # print(true_cardinality, est, "%.2f" % relative_error(true_cardinality, est))
    return relative_error(true_cardinality, est)
