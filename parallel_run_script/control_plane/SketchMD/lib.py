from sw_dp_simulator.file_io.py.common import Flowkey

import os

RESULT_TOFINO_DP = os.getenv('result_tofino_dp')
RESULT_GT = os.getenv('result_gt')

NORMAL_TYPE = 0
O2B_TYPE_FIRST = 1
O2B_TYPE_SECOND = 2


def get_overall_flowkey(workload_name):
    if workload_name == "workload_1":
        return "srcIP,dstIP,srcPort,dstPort,proto", 5
    if workload_name == "workload_2":
        return "dstIP,dstPort", 2
    if workload_name == "workload_3":
        return "srcIP,dstIP,srcPort", 3
    if workload_name == "workload_4":
        return "srcIP,dstIP,srcPort,dstPort", 4

def get_params(workload_name, bf):
    if workload_name == "workload_1":
        inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6"]
        sketch_name_list = ["CountMin"] * 6
        flowkey_list = ["srcIP", "srcIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
        flowsize_list = [1, 0, 0, 0, 0, 1]

        id_list = [1, 2, 3, 4, 5, 6]
        row_list = [1, 5, 2, 5, 2, 5]

        width_list = [4096, 16384, 16384, 8192, 4096, 8192]
        level_list = [1, 1, 1, 1, 1, 1]
        epoch_list = [40, 10, 30, 30, 20, 40]

        hfkey_list = [1, 1, 2, 2, 2, 5]
        threshold_list = [17018, 4599628, 8050832, 12764416, 5462468, 8351]

        type_list = [0, 0, 0, 0, 0, 0]
        limit_row_list = row_list

    elif workload_name == "workload_2":
        inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7", "inst8", "inst9", "inst10"]
        # sketch_name_list = ["BloomFilter", "MRB", "MRB", "Entropy", "Entropy", "CountMin", "CountSketch", "Kary", "MRAC", "MRAC"]
        sketch_name_list = ["Entropy", "CountSketch", "MRB", "MRAC", "BloomFilter", "MRB", "Entropy", "CountMin", "Kary", "MRAC"]
        flowkey_list = ["dstIP,dstPort"] * 10
        flowsize_list = [1, 1, 1, 1, 1, 1, 1, 0, 0, 1]

        if bf == "before":
            id_list =  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            row_list = [3, 3, 1, 1, 3, 1, 4, 3, 1, 1]
        else:
            id_list =  [1, 1, 3, 4, 5, 6, 7, 7, 7, 10]
            row_list = [3, 3, 1, 1, 3, 1, 4, 3, 3, 1]

        width_list = [16384, 16384, 16384, 2048, 128 * 1024, 16384, 4096, 4096, 4096, 2048]
        level_list = [1, 1, 8, 8, 1, 16, 1, 1, 1, 8]
        epoch_list = [10, 10, 20, 20, 30, 30, 30, 30, 30, 40]

        hfkey_list =     [0, 2, 0, 0, 0, 0, 0, 2, 2, 0]
        threshold_list = [0, 3396, 0, 0, 0, 0, 0, 7294114, 7294114, 0]
        if bf == "before":
            type_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            limit_row_list = row_list
        else:
            type_list =      [O2B_TYPE_SECOND, O2B_TYPE_FIRST, 0, 0, 0, 0, O2B_TYPE_SECOND, O2B_TYPE_FIRST, O2B_TYPE_FIRST, 0]
            limit_row_list = [3, 3, 0, 0, 0, 0, 3, 3, 3, 0]

    elif workload_name == "workload_3":
        inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7", "inst8", "inst9", "inst10"]
        sketch_name_list = ["HLL", "HLL", "MRAC", "UnivMon", "UnivMon", "PCSA", "Entropy", "BloomFilter", "LinearCounting", "Entropy"]
        flowkey_list = ["srcIP", "dstIP", "srcIP,dstIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
        flowsize_list = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

        row_list = [1, 1, 1, 3, 4, 1, 2, 3, 1, 5]
        if bf == "before":
            id_list =  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            width_list = [16384, 4096, 2048, 2048, 2048, 8192, 16384, 128*1024, 128*1024, 4096]
            level_list = [    1,    1,    8,   16,   16,    1,     1,        1,        1,    1]
        else:
            id_list =    [    1,    2,    4,    4,    5,     7,     7,        8,        8,   10]
            width_list = [16384, 4096, 2048, 2048, 2048, 16384, 16384, 128*1024, 128*1024, 4096]
            level_list = [    1,    1,   16,   16,   16,     1,     1,         1,       1,    1]

        # epoch_list = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20]
        epoch_list = [30] * 10

        hfkey_list = [0, 0, 0, 2, 2, 0, 0, 0, 0, 0]
        threshold_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

        if bf == "before":
            type_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            limit_row_list = row_list
        else:
            type_list =      [0, 0, O2B_TYPE_SECOND, O2B_TYPE_FIRST, 0, O2B_TYPE_SECOND, O2B_TYPE_FIRST, 0, 0, 0]
            limit_row_list = [0, 0, 1, 1, 0, 1, 1, 0, 0, 0]

    elif workload_name == "workload_4":
        inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7", "inst8", "inst9", "inst10"]
        sketch_name_list = ["MRAC", "MRB", "MRB", "HLL", "PCSA", "Entropy", "Entropy", "CountSketch", "PCSA", "HLL"]
        flowkey_list = ["srcIP", "dstIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
        flowsize_list = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

        row_list = [1, 1, 1, 1, 1, 3, 5, 3, 1, 1]
        if bf == "before":
            id_list =    [     1,     2,     3,    4,     5,    6,    7,    8,     9,   10]
            width_list = [  2048, 16384, 32768, 4096, 16384, 8192, 4096, 8192, 16384, 8192]
            level_list = [    16,     8,     8,    1,     1,    1,    1,    1,     1,    1]

        else:
            id_list =    [     1,     2,     3,    4,     5,    6,    7,    7,     9,   10]
            width_list = [  2048, 16384, 32768, 4096, 16384, 8192, 8192, 8192, 16384, 8192]
            level_list = [    16,     8,     8,    1,     1,    1,    1,    1,     1,    1]

        # width_list = [262144, 65536, 2048, 524288, 8192, 2048, 2048, 65536, 8192, 16384]
        epoch_list = [20, 30, 20, 10, 20, 30, 30, 30, 40, 30]

        hfkey_list = [0, 0, 0, 0, 0, 0, 0, 4, 0, 0]
        threshold_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

        if bf == "before":
            type_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            limit_row_list = row_list
        else:
            type_list =      [0, 0, 0, 0, 0, 0, O2B_TYPE_SECOND, O2B_TYPE_FIRST, 0, 0]
            limit_row_list = [0, 0, 0, 0, 0, 0, 3, 3, 0, 0]

    return (inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list)


def counter_read(metadata):
    workload_name, bf, program_name, pcap_file_name = metadata

    result_path = os.path.join(RESULT_TOFINO_DP, "sketchMD", workload_name, program_name, pcap_file_name)
    date = sorted(os.listdir(result_path))[-1]
    # date = sorted(os.listdir(result_path))[-3]
    result_folder = os.path.join(result_path, date)

    gt_folder = os.path.join(RESULT_GT, "sketchMD", workload_name, program_name, pcap_file_name, date)

    inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list = get_params(workload_name, bf)


    total_data_dict = {}
    gt_path_dict = {}

    for inst_name, sketch_name, flowkey, flowsize, id, row, width, level, epoch, hfkey, threshold, type, limit_row in zip(inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list):
        if bf == "before":
            path = os.path.join(result_folder, "update_%d_1" % id)
        else: # after
            path = os.path.join(result_folder, "update_%d_1" % id, "type_%d" % type)

        gt_path = os.path.join(gt_folder, inst_name)

        total_data_dict[inst_name] = {}
        gt_path_dict[inst_name] = {}

        for dir, dir2 in zip(sorted(os.listdir(path)), sorted(os.listdir(gt_path))): # epoch
            if dir == "0":
                continue

            total_data_dict[inst_name][dir] = []
            gt_path_dict[inst_name][dir] = os.path.join(gt_path, dir2)

            for i in range(1, row+1):
                counter_list = []
                if bf == "before":
                    counter_path = os.path.join(result_folder, "update_%d_%d" % (id, i), dir, "result.txt")
                else:
                    if i <= limit_row:
                        counter_path = os.path.join(result_folder, "update_%d_%d" % (id, i), "type_%d" % type, dir, "result.txt")
                    else:
                        counter_path = os.path.join(result_folder, "update_%d_%d" % (id, i), "type_0", dir, "result.txt")
                f = open(counter_path, "r")
                for line in f:
                    counter_list.append(int(line))
                total_data_dict[inst_name][dir].append(counter_list)

    return total_data_dict, gt_path_dict


def get_overall_flowkey_list(result_folder, folder_template, dir, flowkey, hfkey):
    overall_flowkey_list = []
    for i in range(1, hfkey+1):
        path2 = os.path.join(result_folder, folder_template % i, dir, "result.txt")

        f = open(path2, "r")
        hflowkey_list = []
        for a in f:
            hflowkey_list.append(int(a))

        if i == 1:
            for key in hflowkey_list:
                overall_flowkey_list.append(Flowkey(flowkey, 0, 0, 0, 0, 0))
        
        for flowkey_inst, header in zip(overall_flowkey_list, hflowkey_list):
            if header < 0:
                header = header + 2**32
            if flowkey.split(",")[i-1] == "srcIP":
                flowkey_inst.src_addr = header
            elif flowkey.split(",")[i-1] == "dstIP":
                flowkey_inst.dst_addr = header
            elif flowkey.split(",")[i-1] == "srcPort":
                flowkey_inst.src_port = header
            elif flowkey.split(",")[i-1] == "dstPort":
                flowkey_inst.dst_port = header
            elif flowkey.split(",")[i-1] == "proto":
                flowkey_inst.proto = header
    return overall_flowkey_list


def get_additional_flowkey_list(path, flowkey, hfkey):
    flowkey_list = []
    f = open(path, "r")
    for a in f:
        import ast
        res = ast.literal_eval(a)
        flowkey_inst = Flowkey(flowkey, 0, 0, 0, 0, 0)
        for i in range(0, hfkey):
            if flowkey.split(",")[i] == "srcIP":
                flowkey_inst.src_addr = res[i]
            elif flowkey.split(",")[i] == "dstIP":
                flowkey_inst.dst_addr = res[i]
            elif flowkey.split(",")[i] == "srcPort":
                flowkey_inst.src_port = res[i]
            elif flowkey.split(",")[i] == "dstPort":
                flowkey_inst.dst_port = res[i]
            elif flowkey.split(",")[i] == "proto":
                flowkey_inst.proto = res[i]
        flowkey_list.append(flowkey_inst)
    return flowkey_list


def hf_read(metadata):
    workload_name, bf, program_name, pcap_file_name = metadata

    result_path = os.path.join(RESULT_TOFINO_DP, "sketchMD", workload_name, program_name, pcap_file_name)
    date = sorted(os.listdir(result_path))[-1]
    result_folder = os.path.join(result_path, date)


    dupcheck_folder = os.path.join(result_folder, "dupcheck")

    inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list = get_params(workload_name, bf)

    flowkey_data_dict = {}

    if bf == "before":
        for inst_name, sketch_name, flowkey, flowsize, id, row, width, level, epoch, hfkey, threshold, type, limit_row in zip(inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list):
            if hfkey != 0:
                path = os.path.join(result_folder, "flowkey_%d_key1" % id)
                dup_path = os.path.join(dupcheck_folder, inst_name)
                flowkey_data_dict[inst_name] = {}

                for dir, dir2 in zip(sorted(os.listdir(path)), sorted(os.listdir(dup_path))): # epoch
                    if dir == "0":
                        continue

                    flowkey_data_dict[inst_name][dir] = []
                    overall_flowkey_list = get_overall_flowkey_list(result_folder, "flowkey_%d_key" % id + "%d", dir, flowkey, hfkey)
                    for i, flowkey_inst in enumerate(overall_flowkey_list):
                        if flowkey_inst.null() == False:
                            flowkey_data_dict[inst_name][dir].append(flowkey_inst)
                            # if inst_name == "inst5" and dir == "6":
                            #     print(i, flowkey_inst)
                    # if inst_name == "inst3":
                    #     print(len(flowkey_data_dict[inst_name][dir]))
                    dup_file_path = os.path.join(dup_path, dir2)
                    additional = get_additional_flowkey_list(dup_file_path, flowkey, hfkey)
                    flowkey_data_dict[inst_name][dir] += additional
                    # if inst_name == "inst5" and dir == "6":
                    #     for flowkey in additional:
                    #         print("additional", flowkey)

    else:
        path = os.path.join(result_folder, "flowkey_key1", "type_0")
        dup_path = dupcheck_folder
        # print(sorted(os.listdir(path)))
        # print(sorted(os.listdir(dup_path)))
        for dir, dir2 in zip(sorted(os.listdir(path)), sorted(os.listdir(dup_path))): # epoch
            if dir == "0":
                continue
            # print(f"[{dir}]")
            dup_file_path = os.path.join(dup_path, dir2)
            flowkey_data_dict[dir] = []

            flowkey, hfkey = get_overall_flowkey(workload_name)

            overall_flowkey_list = get_overall_flowkey_list(result_folder, "flowkey_key%d", os.path.join("type_0", dir), flowkey, hfkey)

            for i, flowkey_inst in enumerate(overall_flowkey_list):
                if flowkey_inst.null() == False:
                    flowkey_data_dict[dir].append(flowkey_inst)
                    # if dir == "1":
                    #     print(i, flowkey_inst)

            additional = get_additional_flowkey_list(dup_file_path, flowkey, hfkey)
            flowkey_data_dict[dir] += additional
            # if dir == "1":
            #     for flowkey in additional:
            #         print("additional", flowkey)

    return flowkey_data_dict
