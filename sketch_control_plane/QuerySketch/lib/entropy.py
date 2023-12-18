from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth
from sw_dp_simulator.hash_module.py.hash import crc_hash
import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

# def get_estimated_entropy(data_list):
#     # print("width:", len(data_list[0]))
#     b = []
#     for counter_array in data_list:
#         a = []
#         total = 0
#         for cij in counter_array:
#             # print(cij)
#             if cij >= 2:
#                 a.append((cij * math.log2(cij) - (cij-1) * math.log2(cij-1)))
#             else:
#                 a.append(0)
#         avg = sum(a) / len(a)
#         b.append(avg)
#     import statistics
#     return statistics.median(b)


def get_estimated_entropy(data_list, total):
    # width = len(data_list[0])
    a = []
    for counter_array in data_list:
        width = len(counter_array)
        # print(width)
        sum = 0
        for cij in counter_array:
            # print(cij)
            if cij >= 3:
                X = total * (cij * math.log2(cij) - (cij-1) * math.log2(cij-1))
                sum += X
        sum = sum / width
        a.append(sum)
    d = len(data_list)
    a.sort()
    middle = int(d/2)
    if d % 2 == 0:
        xlogx = int((a[middle] + a[middle-1]) / 2)
    else:
        xlogx = int(a[middle])
    entropy_est = math.log2(total) - xlogx/total
    return entropy_est

def get_true_entropy(gt_result_list):
    total = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        total += estimate

    entropy = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        p = (estimate / total)
        entropy += p * math.log2(1/p)

    return total, entropy

def get_entropy_error(gt_path, counter_data):
    ground_truth_data_list = load_ground_truth(gt_path)
    total, true_entropy = get_true_entropy(ground_truth_data_list)
    # print("true entropy", true_entropy)
    # print("total", total)

    est_entropy = get_estimated_entropy(counter_data, total)
    error = relative_error(true_entropy, est_entropy)
    # print(true_entropy, est_entropy, error)
    return error

