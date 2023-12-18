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

def get_cardinality(M, level, width):
    # for base in range(0, level):
    #     level_counter = M[base*width:(base+1)*width]
    #     print(base, bitset(level_counter), bitzero(level_counter))
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


def get_mrb_error(param, gt_path, data):
    width, level = param
    true_cardinality = load_ground_truth_cardinality(gt_path)
    # print(width, level)
    # print(true_cardinality)
    # print(len(data[0]))
    # print()
    est = get_cardinality(data[0], level, width)
    # print(true_cardinality, est, "%.2f" % relative_error(true_cardinality, est))
    return relative_error(true_cardinality, est)
