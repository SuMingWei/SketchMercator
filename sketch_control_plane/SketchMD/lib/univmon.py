from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth
from sw_dp_simulator.hash_module.py.hash import crc_hash
from parallel_run_script.threshold.univmon_lib import hh_dict_list_sort, trim_by_topk, inference_entropy
from parallel_run_script.threshold.univmon_lib import get_ground_truth_dict, get_ground_truth_cheating_dict
from sw_dp_simulator.file_io.py.common import Flowkey

import math

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100


def get_last_level(sh):
    last_level = 0
    for i in range(15,0,-1):
        if ((sh >> i) & 1) == 0:
            return last_level
        last_level += 1
    return last_level


def counter_estimate(key, data_list, width, selected_level):
    res_seed = 0x5b445b31
    hash_seed_list = [0x30243f0b, 0x0f79f523, 0x6b8cb0c5, 0x00390fc3, 0x298ac673]
    row = len(data_list)
    a = []
    res = crc_hash(key, [0, 0, res_seed, 0x0, 0xFFFFFFFF])
    # res = res >> 1
    for i in range(0, row):
        index = width * selected_level + crc_hash(key, [0, 0, hash_seed_list[i], 0x0, 0xFFFFFFFF]) % width
        if res % 2 == 0:
            a.append(-data_list[i][index])
        else:
            a.append(data_list[i][index])
        res = res >> 1
    # print(a)
    import statistics
    return int(statistics.median(a))


def print_dict_list_with_est(dict_list, counter_data, width):
    level = len(dict_list)
    for i in range(0, level):
        print("***")
        print("level: ", i)
        print("***")
        wi = dict_list[i]
        for z, (k, v) in enumerate(wi.items(), 1):
            # print(z, k, v)
            if v[1] == 0:
                print(z, k, v, counter_estimate(v[2], counter_data, width, i))
            else:
                print(z, k, v)
            # string_key = k
            # estimate = v[0]
            # is_last_level = v[1]
            # print(z+1, string_key, estimate, is_last_level)


def print_dict_list(dict_list):
    level = len(dict_list)
    for i in range(0, level):
        print("***")
        print("level: ", i)
        print("***")
        wi = dict_list[i]
        for z, (k, v) in enumerate(wi.items(), 1):
            print(z, k, v)


def get_true_entropy(gt_result_list):
    total = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        total += estimate

    entropy = 0
    for (string_key, estimate, flowkey) in gt_result_list:
        p = (estimate / total)
        entropy += p * math.log2(1/p)

    return total, entropy

def get_univmon_error(bf, param, gt_path, counter_data, hf_data, start, end, hfkey, flowkey):
    (width, level) = param

    ground_truth_data_list = load_ground_truth(gt_path)
    total, true_entropy = get_true_entropy(ground_truth_data_list)

    if bf == "after":
        flowkey_list = []
        for dir in range(start, end+1):
            # print(len(hf_data[str(dir)]))
            for hh_key in hf_data[str(dir)]:
                # print(hh_key)
                fkey = Flowkey(flowkey, 0, 0, 0, 0, 0)
                for j in range(0, hfkey):
                    if flowkey.split(",")[j] == "srcIP":
                        fkey.src_addr = hh_key.src_addr
                    if flowkey.split(",")[j] == "dstIP":
                        fkey.dst_addr = hh_key.dst_addr
                    if flowkey.split(",")[j] == "srcPort":
                        fkey.src_port = hh_key.src_port
                    if flowkey.split(",")[j] == "dstPort":
                        fkey.dst_port = hh_key.dst_port
                    if flowkey.split(",")[j] == "proto":
                        fkey.proto = hh_key.proto
                flag = True
                for old_fkey in flowkey_list:
                    if old_fkey == fkey:
                        flag = False
                if flag:
                    flowkey_list.append(fkey)

        hf_data = flowkey_list

        # print(len(flowkey_list))
        # exit(1)



    # find_miss_univmon_flowkey_before(gt_path, hf_data)
    # exit(1)


    # hh_dict_list = get_ground_truth_cheating_dict(ground_truth_data_list)
    # est_entropy = inference_entropy(hh_dict_list, total)
    # re = relative_error(true_entropy, est_entropy)
    # print("cheating")
    # # print_dict_list_with_est(hh_dict_list, counter_data, width)
    # print_dict_list(hh_dict_list)

    # print(true_entropy, est_entropy, re)

    hh_dict_list = []
    for i in range(0, level):
        hh_dict_list.append({})
    for flowkey in hf_data:
        s_hash = crc_hash(flowkey, [0, 0, 0x790900f3, 0x0, 0xFFFFFFFF]) % 65536
        i = get_last_level(s_hash)
        hh_dict = hh_dict_list[i]
        estimate = counter_estimate(flowkey, counter_data, width, i)
        if estimate > 0:
            # print(flowkey, estimate)
            key = str(flowkey)
            hh_dict[key] = (estimate, 0)
            for j in range(0, i):
                hh_dict_j = hh_dict_list[j]
                hh_dict_j[key] = (estimate, 1)
    sorted_hh_dict_list = hh_dict_list_sort(hh_dict_list)
    topk_list = trim_by_topk(sorted_hh_dict_list, 50)
    est_entropy = inference_entropy(topk_list, total)
    re = relative_error(true_entropy, est_entropy)
    # print("original")
    # print_dict_list(topk_list)
    print(true_entropy, est_entropy, re)

    return re




def find_miss_univmon_flowkey_before(gt_path, hf_data):
    ground_truth_data_list = load_ground_truth(gt_path)
    hh_dict_list = get_ground_truth_dict(ground_truth_data_list)
    l = len(hh_dict_list)
    found = 0
    not_found = 0


    # for hh_key in hf_data:
    #     index = crc_hash(hh_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 16384
    #     print(f"({index}) ({hh_key})")
    # exit(1)

    # for i, gt_key in enumerate(ground_truth_data_list, 1):
    #     # print(gt_key)
    #     # exit(1)
    #     hh_key = gt_key[2]
    #     index = crc_hash(hh_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 16384
    #     est = counter_estimate(hh_key, counter_data)
    #     print(f"({hh_key}) ({gt_key[1]}) ({est}) ({index})")


    for i in range(0, l):
        wi = hh_dict_list[i]
        print(f" level ({i}) len ({len(wi)})")
        for z, (k, v) in enumerate(wi.items()):
            # print(z, k, v)
            size = v[0]
            gt_key = v[2]

            flag = False
            for hh_key in hf_data:
                if gt_key == hh_key:
                    flag = True
            index = crc_hash(gt_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 16384
            if flag:
                found += 1
                # print(f"[{i}, {z}] key found   size ({size}) index ({index})", gt_key)
                pass
            else:
                not_found += 1
                print(f"[{i}, {z}] key missing size ({size}) index ({index})", gt_key)
        print()

    return found, not_found

def find_miss_univmon_flowkey_after(gt_path, hf_data, counter_data, start, end, hfkey, flowkey):
    pass
