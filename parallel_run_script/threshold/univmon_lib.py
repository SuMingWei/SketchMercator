from sw_dp_simulator.hash_module.py.hash import crc_hash

import math


def g_0(x):
    return 1


def g_xlogx(x):
    if x == 0:
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

def inference_entropy(hh_dict_list, total):
    return inference(hh_dict_list, g_xlogx, total)


def get_last_level(sh):
    last_level = 0
    for i in range(15,0,-1):
        # print(i)
        if ((sh >> i) & 1) == 0:
            return last_level
        last_level += 1
    return last_level

def hh_dict_list_sort(hh_dict_list):
    l = len(hh_dict_list)

    new_dict_list = []

    for i in range(0, l):
        wi = hh_dict_list[i]

        sorted_list = sorted(wi.items(), key=lambda kv: kv[1][0])
        sorted_list.reverse()

        new_dict = {}
        for e in sorted_list:
            new_dict[e[0]] = e[1]
        new_dict_list.append(new_dict)

    return new_dict_list


def get_threshold_list(dict_list, topk):
    threshold_list = []
    level = len(dict_list)
    # print(level)

    for i in range(0, level):
        # print(f" level ({i})")
        wi = dict_list[i]
        if len(wi) <= topk:
            threshold_list.append(0)

        else:
            for z, (k, v) in enumerate(wi.items()):
                # print(k, v)
                if z+1 == topk:
                    threshold_list.append(v[0])
                    # print(k, v)
                    # ret.append(v[0])
                    break
    return threshold_list



def get_univmon_threshold(gt_list):
    l = 16
    hh_dict_list = []
    for i in range(0, l):
        hh_dict_list.append({})
    for (string_key, estimate, flowkey) in gt_list:
        s_hash = crc_hash(flowkey, [0, 0, 0x790900f3, 0x0, 0xFFFFFFFF]) % 65536
        i = get_last_level(s_hash)
        # print(i)
        hh_dict = hh_dict_list[i]
        hh_dict[string_key] = (estimate, 0)

    sorted_hh_dict_list = hh_dict_list_sort(hh_dict_list)
    return get_threshold_list(sorted_hh_dict_list, 60)



def trim_by_topk(hh_dict_list, t):
    l = len(hh_dict_list)

    topk_hh_dict_list = []
    for i in range(0, l):
        wi = hh_dict_list[i]

        topk_hh_dict = {}

        for z, (k, v) in enumerate(wi.items()):
            if z < t:
                topk_hh_dict[k] = v
            else:
                break

        topk_hh_dict_list.append(topk_hh_dict)

    return topk_hh_dict_list



def get_ground_truth_dict(gt_list):
    l = 16
    hh_dict_list = []
    for i in range(0, l):
        hh_dict_list.append({})
    for (string_key, estimate, flowkey) in gt_list:
        s_hash = crc_hash(flowkey, [0, 0, 0x790900f3, 0x0, 0xFFFFFFFF]) % 65536
        i = get_last_level(s_hash)

        hh_dict = hh_dict_list[i]
        hh_dict[string_key] = (estimate, 0, flowkey)

    sorted_hh_dict_list = hh_dict_list_sort(hh_dict_list)
    return trim_by_topk(sorted_hh_dict_list, 50)


def get_ground_truth_cheating_dict(gt_list):
    l = 16
    hh_dict_list = []
    for i in range(0, l):
        hh_dict_list.append({})
    for (string_key, estimate, flowkey) in gt_list:
        s_hash = crc_hash(flowkey, [0, 0, 0x790900f3, 0x0, 0xFFFFFFFF]) % 65536
        i = get_last_level(s_hash)
        hh_dict = hh_dict_list[i]
        hh_dict[string_key] = (estimate, 0, flowkey)
        for j in range(0, i):
            hh_dict_j = hh_dict_list[j]
            hh_dict_j[string_key] = (estimate, 1, flowkey)

    sorted_hh_dict_list = hh_dict_list_sort(hh_dict_list)
    return trim_by_topk(sorted_hh_dict_list, 50)


def create_adv_estimate_hh_dict_list_from_hw(flowkey_list, return_dict, d, w, l, hash, compact_hash):

    sampling_hash_list = return_dict["sampling_hash_list"]
    index_hash_list = return_dict["index_hash_list"]
    res_hash_list = return_dict["res_hash_list"]
    sketch_array_list = return_dict["sketch_array_list"]

    hh_dict_list = []
    for i in range(0, l):
        hh_dict_list.append({})

    # for z, (k, v) in enumerate(ground_truth_dict.items()):
    for z, v in enumerate(flowkey_list):

        last_level = last_level_lib(compact_hash, (0, v), hash, sampling_hash_list)

        if last_level >= 16:
            continue
        i = last_level
        hh_dict = hh_dict_list[i]
        # print(v, i)
        # print(v, sketch_array_list[i], index_hash_list[i], res_hash_list[i], d, w, hash, i, compact_hash)
        estimate = counter_estimate(v, sketch_array_list[i], index_hash_list[i], res_hash_list[i], d, w, hash, i, compact_hash)
        hh_dict[v] = (estimate, 0)
        for j in range(0, i):
            hh_dict_j = hh_dict_list[j]
            hh_dict_j[v] = (estimate, 1)
        # if hash == "basic_hash":
        #     if z % 50000 == 0:
        #         print(z, k, v, estimate)
        # if hash == "crc_hash":
        #     if z % 50000 == 0:
        #         print(z, k, v, estimate)

    sorted_hh_dict_list = hh_lib.hh_dict_list_sort(hh_dict_list)
    # sorted_hh_dict_list = hh_lib.hh_dict_list_cheating(ground_truth_dict, sorted_hh_dict_list)

    return sorted_hh_dict_list
