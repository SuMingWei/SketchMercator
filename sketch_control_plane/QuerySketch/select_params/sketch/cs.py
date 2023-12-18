from sw_dp_simulator.file_io.py.read_cs import load_cs
from sw_dp_simulator.hash_module.py.hash import compute_hash

import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level, compact_hash = False):
    a = []

    if compact_hash == False:
        for i in range(0, d):
            index = compute_hash(key, hash, index_hash_sub_list[i], w)
            res = compute_hash(key, hash, res_hash_sub_list[i], 2)
            res = res * 2 - 1
            estimate = sketch_array[i * w + index] * res
            a.append(estimate)

    else:
        long_hash = compute_hash(key, hash, res_hash_sub_list[0], 4294967296)
        for i in range(0, d):
            index = compute_hash(key, hash, index_hash_sub_list[i], w)
            res = (long_hash>>i) & 1
            res = res * 2 - 1

            estimate = sketch_array[i * w + index] * res
            a.append(estimate)

    a.sort()

    middle = int(d/2)

    if d % 2 == 0:
        return int((a[middle] + a[middle-1]) / 2)
    else:
        return int(a[middle])

def get_ARE(result, cArray, d, w):

    gt_result = result["gt"]
    sampling_hash_list = result["sampling_hash_list"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]
    sketch_array_list = result["sketch_array_list"]

    topk = 100
    sum = 0
    for i in range(0, min(topk, len(gt_result))):
        true_flow_count = gt_result[i][1]
        flowkey = gt_result[i][2]
        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0, True)
        # print(true_flow_count, est)
        error = relative_error(true_flow_count, est)
        sum += error

    # print("ARE: ", sum / topk)
    # print()
    return sum / topk


def get_f2(result, cArray, d, w):

    f2 = result["f2"]

    a = []
    for i in range(0, d):
        sum = 0
        for j in range(0, w):
            sum += cArray[i*w + j] * cArray[i*w + j]
        a.append(sum)

    a.sort()

    middle = int(d/2)

    if d % 2 == 0:
        f2_est = int((a[middle] + a[middle-1]) / 2)
    else:
        f2_est = int(a[middle])
    
    return [f2, f2_est, relative_error(f2, f2_est)]

########################

def get_entropy(result, cArray, d, w):

    total = result["count_list"][0]
    entropy = result["entropy"]
    from sketch_control_plane.SketchAug.lib.gsum_lib import ground_truth_entropy
    # print(total, entropy)
    
    import math
    import statistics

    a = []
    for i in range(0, d):
        # total2 = 0
        # for j in range(0, w):
        #     cij = abs(cArray[i*w + j])
        #     total2 += cij
        # print(total, total2)

        entropy_est = 0
        for j in range(0, w):
            cij = abs(cArray[i*w + j])
            p = (cij/total)
            if p != 0:
                entropy_est += p * math.log2(p)
        entropy_est *= -1
        a.append(entropy_est)
        # break
    entropy_est = statistics.median(a)

    # print("use counters:", [entropy, entropy_est, relative_error(entropy, entropy_est)])
    # a = []
    # for i in range(0, d):
    #     sum = 0
    #     test_sum = 0
    #     for j in range(0, w):
    #         # print(cArray[i*w + j])
    #         cij = abs(cArray[i*w + j])
    #         test_sum += cij
    #         if cij >= 3:
    #             X = total * (cij * math.log2(cij) - (cij-1) * math.log2((cij-1)))
    #             # X = total * (cij * math.log2(cij) - cij_minus * math.log2(cij_minus))
    #             sum += X
    #     sum = sum / w
    #     a.append(sum)
    # entropy_est = statistics.median(a)
    # entropy_est = math.log2(total) - entropy_est/total

    # print("use sketch:", [entropy, entropy_est, relative_error(entropy, entropy_est)])

    return [entropy, entropy_est, relative_error(entropy, entropy_est)]

def get_true_entropy(gt_result_list):
    total = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        total += estimate

    entropy = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        p = (estimate / total)
        entropy += p * math.log2(1/p)

    return total, entropy

# def get_entropy_error(ground_truth_data_list, counter_data):
#     total, true_entropy = get_true_entropy(ground_truth_data_list)
#     print("true entropy", true_entropy)
#     print("total", total)

#     est_entropy = get_estimated_entropy(counter_data, total)
#     error = relative_error(true_entropy, est_entropy)
#     print(true_entropy, est_entropy, error)
#     return error

def compare_pq(item1, item2):
    if item1[0] < item2[0]:
        return 1
    elif item1[0] > item2[0]:
        return -1
    else:
        return 0

def get_change_detection(output_dir, result, cArray, row, arow, width):

    # get current epoch ground truth result
    gt_result = result["gt"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]

    epoch = output_dir.split('seed_')[1]
    epoch = int(epoch.split('/')[1])
    # epoch 1 - nothing (epoch 0)
    if epoch == 1:
        sim_ARE_error = get_ARE(result, cArray, arow, width)
        return sim_ARE_error
    else:
        output_dir_prev = output_dir[:-2]
        output_dir_prev += str(epoch - 1).zfill(2)
        result_prev = load_cs(output_dir_prev, width, row)

        # print(result_prev['gt'][0][1])
        # print(result_prev['gt'][0][2])
        gt_result_prev = result_prev['gt']
        index_hash_list_prev = result_prev["index_hash_list"]
        res_hash_list_prev = result_prev["res_hash_list"]
        cArray_prev = result_prev["sketch_array_list"][0]

        ll = []
        # Find the change in the ground truth (current epoch - previous epoch)
        for i in range(0, len(gt_result)):
            true_flow_count = gt_result[i][1]
            flowkey = gt_result[i][2]
            isMatch = False

            # find the same flow key in the previous epoch
            for j in range(0, len(gt_result_prev)):
                flowkey_prev = gt_result_prev[j][2]
                if flowkey == flowkey_prev:
                    isMatch = True
                    break
            if isMatch:
                change = abs(gt_result_prev[j][1] - true_flow_count)
            else:
                change = abs(true_flow_count)
            ll.append((change, flowkey))
        
        # sort list from big to small by flow change
        import functools
        pq = sorted(ll, key=functools.cmp_to_key(compare_pq))

        topk = 100
        sum = 0
        length = min(topk, len(gt_result))

        # Calculate the topk ARE for change detection
        for i in range(length):
            flowkey = pq[i][1]
            true_change = pq[i][0]
            est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], arow, width, "crc_hash", 0, True)
            est_prev = counter_estimate(flowkey, cArray_prev, index_hash_list_prev[0], res_hash_list_prev[0], arow, width, "crc_hash", 0, True)
            est_change = abs(est - est_prev)
            error = relative_error(true_change, est_change)
            sum += error

        return sum / topk


def get_flow_size_distribution(result, row, width):
    cArray = result["sketch_array_list"][0]
    gt_result = result["gt"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]

    true_distribution = {}
    est_distribution = {}
    for i in range(0, len(gt_result)):
        true_flow_count = gt_result[i][1]
        flowkey = gt_result[i][2]

        if true_flow_count in true_distribution:
            true_distribution[true_flow_count] += 1
        else:
            true_distribution[true_flow_count] = 1

        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], row, width, "crc_hash", 0, True)
        if est in est_distribution:
            est_distribution[est] += 1
        else:
            est_distribution[est] = 1
    
    # print(est_distribution)

    WMRD_nom = 0
    WMRD_denom = 0

    for key in true_distribution:
        true = true_distribution[key]
        if key in est_distribution:
            est = est_distribution[key]
        else:
            est = 0

        WMRD_nom += abs(true - est)
        WMRD_denom += float(true + est)/2
    WMRD = WMRD_nom/WMRD_denom    
    
    # print(f'WMRD: {WMRD}')
    
    return WMRD


def cs_main(sketch_name, output_dir, row, width, level, arow):
    result = load_cs(output_dir, width, row)
    sim_total = result["sketch_array_list"][0]

    entropy_error = get_entropy(result, sim_total, arow, width)
    print(entropy_error)
    ret = entropy_error

    sim_ARE_error = get_ARE(result, sim_total, arow, width)
    # print(sim_ARE_error)
    ret.append(sim_ARE_error)

    sim_change_detection_error = get_change_detection(output_dir, result, sim_total, row, arow, width)
    # print("sim_change_detection_error", sim_change_detection_error)
    ret.append(sim_change_detection_error)

    WMRD = get_flow_size_distribution(result, arow, width)
    ret.append(WMRD)
    
    return ret

    # f2_error = get_f2(result, sim_total, arow, width)
