from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.hash_module.py.hash import compute_hash

import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level):
    a = []

    for i in range(0, d):
        index = compute_hash(key, hash, index_hash_sub_list[i], w)
        estimate = sketch_array[i * w + index]
        a.append(estimate)

    return min(a)

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
        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0)
        # print(true_flow_count, est)
        error = relative_error(true_flow_count, est)
        sum += error

    # print("ARE: ", sum / topk)
    # print()
    return sum / topk

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
        result_prev = load_cm(output_dir_prev, width, row)

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
            est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], arow, width, "crc_hash", 0)
            est_prev = counter_estimate(flowkey, cArray_prev, index_hash_list_prev[0], res_hash_list_prev[0], arow, width, "crc_hash", 0)
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

        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], row, width, "crc_hash", 0)
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


def cm_main(sketch_name, output_dir, row, width, level, arow):
    result = load_cm(output_dir, width, row)
    sim_total = result["sketch_array_list"][0]
    from sketch_control_plane.QuerySketch.select_params.sketch.cs import get_entropy
    entropy_error = get_entropy(result, sim_total, arow, width)
    # print(entropy_error)
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