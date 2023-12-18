from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth, load_ground_truth_threshold, load_ground_truth_topk
from copy import deepcopy
from sw_dp_simulator.file_io.py.common import Flowkey
from sw_dp_simulator.hash_module.py.hash import crc_hash


def find_miss_flowkey_before(gt_path, hf_data, counter_data):
    print(gt_path)
    ground_truth_data_list = load_ground_truth_topk(gt_path, 50)

    # for dir in range(start, end+1):
    #     print(f"[dir({dir})]")
    #     for hh_key in hf_data['1']:
    #         est = counter_estimate(hh_key, counter_data)
    #         index = crc_hash(hh_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 16384
    #         print(f"({index}) ({hh_key})")
    #         # print(f"({index}) ({hh_key}) ({est})")
    #         # print(f"({index}) ({hh_key}) ({est})")

    # # # exit(1)
    # if gt_path.endswith("03"):
    #     for i, gt_key in enumerate(ground_truth_data_list, 1):
    #         est = counter_estimate(gt_key[2], counter_data)
    #         print(i, gt_key[0], gt_key[1], est)
    #         print()

    #         # index = crc_hash(gt_key[2], [0, 0, 0x6b8cb0c5, 0x0, 0xFFFFFFFF]) % 16384
    #         # print(f"({index}) ({gt_key})")
    #     for hh_key in hf_data:
    #         index = crc_hash(hh_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 8192
    #         print(f"({index}) ({hh_key})")

    found = 0
    not_found = 0
    for i, gt_key in enumerate(ground_truth_data_list, 1):
        flag = False
        for hh_key in hf_data:
            if gt_key[2] == hh_key:
                flag = True
        if flag:
            found += 1
            pass
        else:
            not_found += 1
            est = cs_counter_estimate(gt_key[2], counter_data)
            print(f"[{i}] key missing :( ", gt_key, est)
            # index = crc_hash(gt_key[2], [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 8192
            # print(f"({index}) ({gt_key}) ({est})")

    return found, not_found



def cs_counter_estimate(key, data_list):
    res_seed = 0x5b445b31
    hash_seed_list = [0x30243f0b, 0x0f79f523, 0x6b8cb0c5, 0x00390fc3, 0x298ac673]
    row = len(data_list)
    width = len(data_list[0])
    # print(row, width)
    a = []
    res = crc_hash(key, [0, 0, res_seed, 0x0, 0xFFFFFFFF])
    # res = res >> 1
    for i in range(0, row):
        index = crc_hash(key, [0, 0, hash_seed_list[i], 0x0, 0xFFFFFFFF]) % width
        if res % 2 == 0:
            a.append(-data_list[i][index])
        else:
            a.append(data_list[i][index])
        res = res >> 1
    import statistics
    print(a)
    med = statistics.median(a)
    # print(statistics.median(a))
    # a.sort()
    return int(med)


def cm_counter_estimate(key, data_list):
    hash_seed_list = [0x30243f0b, 0x0f79f523, 0x6b8cb0c5, 0x00390fc3, 0x298ac673]
    row = len(data_list)
    width = len(data_list[0])
    print(row, width)
    a = []
    index_list = []
    for i in range(0, row):
        index = crc_hash(key, [0, 0, hash_seed_list[i], 0x0, 0xFFFFFFFF]) % width
        a.append(data_list[i][index])
        index_list.append(index)
    print(index_list)
    print(a, max(a) - min(a))
    return int(min(a))

def get_last_level(sh):
    last_level = 0
    for i in range(15,0,-1):
        if ((sh >> i) & 1) == 0:
            return last_level
        last_level += 1
    return last_level

def um_counter_estimate(key, data_list, width, selected_level):
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
    print(selected_level, a)
    import statistics
    return int(statistics.median(a))



def find_miss_flowkey_after(gt_path, hf_data, counter_data, start, end, hfkey, flowkey):
    print(gt_path)
    # for dir in range(start, end+1):
    #     print("="*50)
    #     print(f"[dir({dir})]")
    #     for hh_key in hf_data[str(dir)]:
    #         # est = counter_estimate(hh_key, counter_data)
    #         index = crc_hash(hh_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 32768
    #         print(f"({index}) ({hh_key})")
    #         # print(f"({index}) ({hh_key}) ({est})")
    #         # print(f"({index}) ({hh_key}) ({est})")
    # # exit(1)

    ground_truth_data_list = load_ground_truth_topk(gt_path, 50)

    # print("-" * 100)
    # for i, gt_key in enumerate(ground_truth_data_list, 1):
    #     hh_key = gt_key[2]
    #     est = counter_estimate(hh_key, counter_data)
    #     if gt_key[1] <= est:
    #         print(i, gt_key[1], est)
    #     else:
    #         print("what's going on?", i, gt_key[1], est)
    #     # # exit(1)
    #     # index = crc_hash(hh_key, [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 32768
    #     # print(f"({hh_key}) ({gt_key[1]}) ({est}) ({index})")

    found = 0
    not_found = 0

    for i, gt_key in enumerate(ground_truth_data_list, 1):
        flag = False
        for dir in range(start, end+1):
            for hh_key in hf_data[str(dir)]:
                # print(hh_key)
                flag2 = True
                for j in range(0, hfkey):
                    if flowkey.split(",")[j] == "srcIP" and gt_key[2].src_addr != hh_key.src_addr:
                        flag2 = False
                    if flowkey.split(",")[j] == "dstIP" and gt_key[2].dst_addr != hh_key.dst_addr:
                        flag2 = False
                    if flowkey.split(",")[j] == "srcPort" and gt_key[2].src_port != hh_key.src_port:
                        flag2 = False
                    if flowkey.split(",")[j] == "dstPort" and gt_key[2].dst_port != hh_key.dst_port:
                        flag2 = False
                    if flowkey.split(",")[j] == "proto" and gt_key[2].proto != hh_key.proto:
                        flag2 = False
                if flag2:
                    flag = True
                    break
            if flag:
                break
        if flag:
            # est = counter_estimate(gt_key[2], counter_data)
            # s_hash = crc_hash(gt_key[2], [0, 0, 0x790900f3, 0x0, 0xFFFFFFFF]) % 65536
            # est = um_counter_estimate(gt_key[2], counter_data, 2048, get_last_level(s_hash))
            # print(f"[{i}] key found ", gt_key[0], gt_key[1], est)
            # print()
            # # print()
            # print(f"[{i}] key found ", gt_key)
            found += 1
        else:
            # s_hash = crc_hash(gt_key[2], [0, 0, 0x790900f3, 0x0, 0xFFFFFFFF]) % 65536
            # est = um_counter_estimate(gt_key[2], counter_data, 2048, get_last_level(s_hash))
            est = cs_counter_estimate(gt_key[2], counter_data)
            print(f"[{i}] key missing ", gt_key, est)
            print()
            # print(f"[{i}] key missing ", gt_key[0], gt_key[1], est)
            # print()
            # index = crc_hash(gt_key[2], [0, 0, 0x60180d91, 0x0, 0xFFFFFFFF]) % 32768
            # print(index, gt_key[1], est)
            not_found += 1
            # exit(1)
    # print(found, not_found)
    # exit(1)
    return found, not_found

