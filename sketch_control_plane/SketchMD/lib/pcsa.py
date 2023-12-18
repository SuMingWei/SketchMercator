from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth_cardinality

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def get_cardinality(M, width):
    # print(len(M), width)
    S = 0
    for counter in M:
        temp = counter
        R = 0
        for i in range(0, 32):
            if temp & 1 == 1:
                R += 1
            else:
                break
            temp = temp >> 1
        S += R

    card = (width / (0.77351)) * 2 ** (S / width)
    return card


def get_pcsa_error(param, gt_path, data):
    width = param
    true_cardinality = load_ground_truth_cardinality(gt_path)
    # print(len(data[0]))
    est = int(get_cardinality(data[0], width))
    re = relative_error(true_cardinality, est)
    print(true_cardinality, est, "%.2f" % re)
    return re
