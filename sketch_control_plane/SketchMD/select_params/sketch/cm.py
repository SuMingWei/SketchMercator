from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.hash_module.py.hash import compute_hash

import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level, compact_hash = False):
    a = []
    for i in range(0, d):
        index = compute_hash(key, hash, index_hash_sub_list[i], w)
        estimate = sketch_array[i * w + index]
        a.append(estimate)
    # print(a)
    return min(a)

def get_ARE(result, cArray, d, w):

    gt_result = result["gt"]
    sampling_hash_list = result["sampling_hash_list"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]
    sketch_array_list = result["sketch_array_list"]

    topk = 50
    sum = 0
    for i in range(0, min(topk, len(gt_result))):
        true_flow_count = gt_result[i][1]
        flowkey = gt_result[i][2]
        # print(flowkey)
        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0)
        # print(true_flow_count, est)
        # exit(1)
        error = relative_error(true_flow_count, est)
        sum += error

    print("ARE: ", sum / topk)
    print()
    # exit(1)
    return sum / topk

def get_entropy(result, cArray, d, w):

    total = result["count_list"][0]
    entropy = result["entropy"]
    from sketch_control_plane.SketchAug.lib.gsum_lib import ground_truth_entropy
    # print(total, entropy)

    a = []
    for i in range(0, d):
        sum = 0
        for j in range(0, w):
            cij = cArray[i*w + j]
            cij_minus = cArray[i*w + j]-1
            if cij >= 3:
                # print(cij_minus)
                # X = total * (cij * math.log2(cij) - cij_minus * math.log2(cij_minus))
                X = (cij * math.log2(cij) - cij_minus * math.log2(cij_minus))
                sum += X
        sum = sum / w
        a.append(sum)

    import statistics
    entropy_est = statistics.median(a)
    return [entropy, entropy_est, relative_error(entropy, entropy_est)]
    # return entropy_est

    # # return

    # xlogx = statistics.median(a)
    # entropy_est = math.log2(total) - xlogx/total

    # # a.sort()
    # # middle = int(d/2)
    # # if d % 2 == 0:
    # #     xlogx = int((a[middle] + a[middle-1]) / 2)
    # # else:
    # #     xlogx = int(a[middle])
    # # entropy_est = xlogx
    # # entropy_est = math.log2(total) - xlogx/total
    # # print(entropy, entropy_est, relative_error(entropy, entropy_est))

    a.sort()
    middle = int(d/2)
    if d % 2 == 0:
        xlogx = int((a[middle] + a[middle-1]) / 2)
    else:
        xlogx = int(a[middle])
    entropy_est = math.log2(total) - xlogx/total

    return [entropy, entropy_est, relative_error(entropy, entropy_est)]

# def get_entropy(result, cArray, d, w):

#     total = result["count_list"][0]
#     entropy = result["entropy"]
#     from sketch_control_plane.SketchAug.lib.gsum_lib import ground_truth_entropy
#     print(total, entropy)

#     a = []
#     for i in range(0, d):
#         sum = 0
#         for j in range(0, w):
#             cij = cArray[i*w + j]
#             cij_minus = cArray[i*w + j]-1
#             if cij >= 3:
#                 # print(cij_minus)
#                 X = total * (cij * math.log2(cij) - cij_minus * math.log2(cij_minus))
#                 sum += X
#         sum = sum / w
#         a.append(sum)
#     a.sort()
#     middle = int(d/2)
#     if d % 2 == 0:
#         xlogx = int((a[middle] + a[middle-1]) / 2)
#     else:
#         xlogx = int(a[middle])
#     entropy_est = math.log2(total) - xlogx/total
#     # print(entropy, entropy_est, relative_error(entropy, entropy_est))
#     # exit(1)
#     return [entropy, entropy_est, relative_error(entropy, entropy_est)]

def cm_main(sketch_name, output_dir, row, width, level, arow):
    result = load_cm(output_dir, width, row)
    sim_total = result["sketch_array_list"][0]
    # entropy_error = get_entropy(result, sim_total, row, width)
    are = get_ARE(result, sim_total, arow, width)
    # print(are)
    return are
