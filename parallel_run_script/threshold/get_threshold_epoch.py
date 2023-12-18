from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count, get_dat_list_by_date_and_count
from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth, load_ground_truth_topk
from env_setting.env_module import sw_dp_simulator_path, result_gt_path
import os

from parallel_run_script.threshold.univmon_lib import get_univmon_threshold
# ret_list = get_pcap_list_by_date_and_count("20140320", "60s", 10)
# ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)


cmd_list = []





for caida_date in ["20140320", "20140619", "20160121", "20180517", "20180816"]:
# for caida_date in ["20160121", "20180517", "20180816"]:
    ret_list = get_pcap_list_by_date_and_count(caida_date, "60s", 10)

    program_name_dict = {}
    program_name_dict["workload_1"] = [
        ("p416_workload_1_06_07_before_5_hash_1_tofino1", "before"),
        ]

    program_name_dict["workload_2"] = [
        ("p416_workload_2_10_11_before_1_hash_1_tofino1", "before"),
        ]

    program_name_dict["workload_3"] = [
        ("p416_workload_3_10_11_before_1_hash_1_tofino1", "before"),
        ]

    program_name_dict["workload_4"] = [
        ("p416_workload_4_10_11_before_1_hash_1_tofino1", "before"),
        ]

    # for workload_name in ["workload_1", "workload_2", "workload_3", "workload_4"]:
    for workload_name in ["workload_4"]:
        print("-" * 100)
        if workload_name == "workload_1":
            inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6"]
            flowkey_list = ["srcIP", "srcIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
            flowsize_list = [1, 0, 0, 0, 0, 1]
            epoch_list = [40, 10, 30, 30, 20, 40]

        if workload_name == "workload_2":
            inst_name_list = ["inst2", "inst8", "inst9"]
            flowkey_list = ["dstIP,dstPort"] * 3
            flowsize_list = [1, 0, 0]
            epoch_list = [10, 30, 30]


        if workload_name == "workload_3":
            inst_name_list = ["inst4", "inst5"]
            flowkey_list = ["srcIP,dstIP", "srcIP,srcPort"]
            flowsize_list = [1, 1]
            epoch_list = [30, 30]


        if workload_name == "workload_4":
            inst_name_list = ["inst8"]
            flowkey_list = ["srcIP,dstIP,srcPort,dstPort"]
            flowsize_list = [1]
            epoch_list = [30]




        result_list = [0]
        for inst_name, flowkey, flowsize, epoch in zip(inst_name_list, flowkey_list, flowsize_list, epoch_list):
            size_list = []
            for program_name, bf in program_name_dict[workload_name]:
                for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
                    
                    tuple1 = (workload_name, program_name, bf)

                    # result_path = os.path.join(os.getenv('result_tofino_dp'), "sketchMD", workload_name, program_name, pcap_file_name.replace("dat", "pcap"))
                    # date = sorted(os.listdir(result_path))[-1]
                    # gt_folder = os.path.join(os.getenv('result_gt'), "sketchMD", workload_name, program_name, pcap_file_name.replace("dat", "pcap"), date)

                    result_path_2 = os.path.join(os.getenv('result_tofino_dp'), "sketchMD", "workload_1", "p416_workload_1_06_07_before_5_hash_1_tofino1", pcap_file_name.replace("dat", "pcap"))
                    date_2 = sorted(os.listdir(result_path_2))[-1]
                    gt_folder = os.path.join(os.getenv('result_gt'), "sketchMD", workload_name, program_name, pcap_file_name.replace("dat", "pcap"), date_2)


                    gt_path = os.path.join(gt_folder, inst_name)
                    for dir in sorted(os.listdir(gt_path)):
                        if 1 <= int(dir) and int(dir) <= 6:
                            # print(dir)
                            gt_full_path = os.path.join(gt_path, dir)

                            ### for normal threshold ###
                            # print(gt_full_path)
                            gt = load_ground_truth_topk(gt_full_path, 70)
                            size = gt[-1][1]
                            size_list.append(size)
                            # print(dir, size)
                            # print(size_list)
                            # print()

                            # ### for univmon threshold ###
                            # gt = load_ground_truth(gt_full_path)
                            # threshold_list = get_univmon_threshold(gt)
                            # print(threshold_list)
                            # size_list.append(threshold_list)


            # ### for normal threshold ###
            # print()
            print(size_list)
            print(inst_name, program_name, len(size_list), min(size_list))
            result_list.append(min(size_list))
            print()
            # print(min(size_list))

            # ### for univmon threshold ###
            # min_threshold_list = []
            # for i in range(0, 16):
            #     temp_array = []
            #     for threshold_list in size_list:
            #         temp_array.append(threshold_list[i])
            #     min_threshold_list.append(min(temp_array))
            # print("min_threshold_list: ", min_threshold_list)
        print(result_list)
                




