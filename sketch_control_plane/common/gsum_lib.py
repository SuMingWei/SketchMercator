import math

def g_0(x):
    return 1

def g_xlogx(x):
    if x <= 0:
        return 0
    return x * math.log2(1 / x)


def inference(hh_dict_list, g_sum, denom):

    l = len(hh_dict_list)

    y2 = 0
    for level in reversed(range(0, l)):
        w = hh_dict_list[level]
        if level == l-1:
            for i, (k, v) in enumerate(w.items()):
                y2 += g_sum(v[0]/denom)

        else:
            y1 = 0
            for i, (k, v) in enumerate(w.items()):
                if v[0] > 0:
                    y1 += (1 - 2 * v[1]) * g_sum(v[0]/denom)
            y1 = 2 * y2 + y1
            y2 = y1
    return y2

def estimate_cardinality_gsum(univmon_dict_list):
    estimated_cardinality = inference(univmon_dict_list, g_0, 1)
    return estimated_cardinality

def estimate_entropy_gsum(univmon_dict_list, total):
    estimated_entropy = inference(univmon_dict_list, g_xlogx, total)
    return estimated_entropy

def ground_truth_entropy(gt_result_list):
    total = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        total += estimate

    # new_flow = 1 000 000
    # total += new_flow

    entropy = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        p = (estimate / total)
        entropy += p * math.log2(1/p)

    # for i in range(0, new_flow):
    #     p = (1 / total)
    #     entropy += p * math.log2(1/p)

    return total, entropy

def ground_truth_cardinality(gt_result_list):
    total = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        total += estimate

    return total, len(gt_result_list)
