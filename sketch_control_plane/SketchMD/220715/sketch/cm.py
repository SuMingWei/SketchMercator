from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.hash_module.py.hash import compute_hash

import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def compute_hash_high_level_two(key1, key2, hash, index_hash_sub_list, i, w):
    crc1 = compute_hash(key1, hash, index_hash_sub_list[i], w)
    crc2 = compute_hash(key2, hash, index_hash_sub_list[2+i], w)
    return crc1 ^ crc2

def compute_hash_high_level_three(key1, key2, key3, hash, index_hash_sub_list, i, w):
    crc1 = compute_hash(key1, hash, index_hash_sub_list[i], w)
    crc2 = compute_hash(key2, hash, index_hash_sub_list[2+i], w)
    crc3 = compute_hash(key3, hash, index_hash_sub_list[4+i], w)
    return crc1 ^ crc2 ^ crc3

def compute_hash_high_level_four(key1, key2, key3, key4, hash, index_hash_sub_list, i, w):
    crc1 = compute_hash(key1, hash, index_hash_sub_list[i], w)
    crc2 = compute_hash(key2, hash, index_hash_sub_list[2+i], w)
    crc3 = compute_hash(key3, hash, index_hash_sub_list[4+i], w)
    crc4 = compute_hash(key4, hash, index_hash_sub_list[6+i], w)
    return crc1 ^ crc2 ^ crc3 ^ crc4

def compute_hash_high_level(key, hash, index_hash_sub_list, i, w, xor_hash_type):
    # print("key")
    # print(key)
    # print(key.key)
    # print(type(key))
    # print(index_hash_sub_list)
    import copy
    key1 = copy.deepcopy(key)
    key2 = copy.deepcopy(key)
    key3 = copy.deepcopy(key)
    key4 = copy.deepcopy(key)

    if xor_hash_type == 1:
        return compute_hash(key, hash, index_hash_sub_list[i], w)

    if xor_hash_type == 2:
        key1.key = "srcIP"
        key2.key = "dstIP,srcPort,dstPort"
        return compute_hash_high_level_two(key1, key2, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 3:
        key1.key = "srcIP,srcPort"
        key2.key = "dstIP,dstPort"
        return compute_hash_high_level_two(key1, key2, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 4:
        key1.key = "srcIP,srcPort,dstIP"
        key2.key = "dstPort"
        return compute_hash_high_level_two(key1, key2, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 5:
        key1.key = "srcIP"
        key2.key = "srcPort"
        key3.key = "dstIP,dstPort"
        return compute_hash_high_level_three(key1, key2, key3, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 6:
        key1.key = "srcIP"
        key2.key = "srcPort,dstIP"
        key3.key = "dstPort"
        return compute_hash_high_level_three(key1, key2, key3, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 7:
        key1.key = "srcIP"
        key2.key = "srcPort"
        key3.key = "dstIP"
        key4.key = "dstPort"
        return compute_hash_high_level_four(key1, key2, key3, key4, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 8:
        key1.key = "srcIP,srcPort"
        key2.key = "srcPort,dstIP,dstPort"
        return compute_hash_high_level_two(key1, key2, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 9:
        key1.key = "srcIP,srcPort,dstIP"
        key2.key = "dstIP,dstPort"
        return compute_hash_high_level_two(key1, key2, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 10:
        key1.key = "srcIP,srcPort"
        key2.key = "srcPort,dstIP"
        key3.key = "dstPort"
        return compute_hash_high_level_three(key1, key2, key3, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 11:
        key1.key = "srcIP,srcPort"
        key2.key = "srcIP,dstIP"
        key3.key = "srcPort,dstPort"
        return compute_hash_high_level_three(key1, key2, key3, hash, index_hash_sub_list, i, w)

    if xor_hash_type == 12:
        key1.key = "srcIP,srcPort"
        key2.key = "dstIP,dstPort"
        if i == 0:
            A = 0
            B = 1
        else:
            A = 2
            B = 3
        crc1 = compute_hash(key1, hash, index_hash_sub_list[A], w)
        crc2 = compute_hash(key2, hash, index_hash_sub_list[B], w)
        return crc1 ^ crc2

    if xor_hash_type == 13:
        key1.key = "srcIP,srcPort"
        key2.key = "dstIP,dstPort"
        if i == 0:
            A = 0
            B = 1
        else:
            A = 0
            B = 1
        crc1 = compute_hash(key1, hash, index_hash_sub_list[A], w)
        crc2 = compute_hash(key2, hash, index_hash_sub_list[B], w)
        return crc1 ^ crc2

    if xor_hash_type == 14:
        key1.key = "srcIP,srcPort"
        key2.key = "dstIP,dstPort"
        if i == 0:
            A = 0
            B = 1
        else:
            A = 0
            B = 3
        crc1 = compute_hash(key1, hash, index_hash_sub_list[A], w)
        crc2 = compute_hash(key2, hash, index_hash_sub_list[B], w)
        return crc1 ^ crc2

    if xor_hash_type == 15:
        key1.key = "srcIP,srcPort,dstIP"
        key2.key = "dstPort"
        if i == 0:
            A = 0
            B = 1
        else:
            A = 0
            B = 3
        crc1 = compute_hash(key1, hash, index_hash_sub_list[A], w)
        crc2 = compute_hash(key2, hash, index_hash_sub_list[B], w)
        return crc1 ^ crc2

    if xor_hash_type == 16:
        if i == 0:
            key1.key = "srcIP,srcPort,dstIP"
            key2.key = "dstPort"
            A = 0
            B = 1
        else:
            key1.key = "srcIP,srcPort,dstIP"
            key2.key = "dstIP,dstPort"
            A = 0
            B = 3
        crc1 = compute_hash(key1, hash, index_hash_sub_list[A], w)
        crc2 = compute_hash(key2, hash, index_hash_sub_list[B], w)
        return crc1 ^ crc2

    if xor_hash_type == 17:
        if i == 0:
            key1.key = "srcIP,srcPort,dstIP"
            key2.key = "srcPort,dstPort"
            A = 0
            B = 1
        else:
            key1.key = "srcIP,srcPort,dstIP"
            key2.key = "dstIP, dstPort"
            A = 0
            B = 3
        crc1 = compute_hash(key1, hash, index_hash_sub_list[A], w)
        crc2 = compute_hash(key2, hash, index_hash_sub_list[B], w)
        return crc1 ^ crc2

    # print(key, key.key)
    # print(key1, key1.key)
    # print(key2, key2.key)
    # print(crc1)
    # print(crc2)
    # exit(1)

    # exit(1)

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level, xor_hash_type, compact_hash = False):
    a = []
    for i in range(0, d):
        index = compute_hash_high_level(key, hash, index_hash_sub_list, i, w, xor_hash_type)
        estimate = sketch_array[i * w + index]
        a.append(estimate)

    a.sort()

    return a[0]

def get_ARE(result, cArray, d, w, xor_hash_type):

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
        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], d, w, "crc_hash", 0, xor_hash_type, True)
        # print(true_flow_count, est)
        error = relative_error(true_flow_count, est)
        sum += error

    print("ARE: ", sum / topk)
    print()
    return sum / topk

def get_entropy(result, cArray, d, w):

    total = result["count_list"][0]
    entropy = result["entropy"]
    from sketch_control_plane.SketchAug.lib.gsum_lib import ground_truth_entropy
    print(total, entropy)

    a = []
    for i in range(0, d):
        sum = 0
        for j in range(0, w):
            cij = cArray[i*w + j]
            cij_minus = cArray[i*w + j]-1
            if cij >= 3:
                # print(cij_minus)
                X = total * (cij * math.log2(cij) - cij_minus * math.log2(cij_minus))
                sum += X
        sum = sum / w
        a.append(sum)
    a.sort()
    middle = int(d/2)
    if d % 2 == 0:
        xlogx = int((a[middle] + a[middle-1]) / 2)
    else:
        xlogx = int(a[middle])
    entropy_est = math.log2(total) - xlogx/total
    # print(entropy, entropy_est, relative_error(entropy, entropy_est))
    # exit(1)
    return [entropy, entropy_est, relative_error(entropy, entropy_est)]

def cm_main(sketch_name, output_dir, row, width, level, xor_hash_type):
    result = load_cm(output_dir, width, row)
    sim_total = result["sketch_array_list"][0]
    sim_ARE_error = get_ARE(result, sim_total, row, width, xor_hash_type)
    entropy_error = get_entropy(result, sim_total, row, width)
    # print(sim_ARE_error, entropy_error)
    print(sim_ARE_error)
    return (sim_ARE_error, entropy_error)
