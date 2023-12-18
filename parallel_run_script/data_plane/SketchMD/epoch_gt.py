from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path, get_test_pcap_list_count, get_dat_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_gt_path
import os

cmd_list = []


# for caida_date in ["20140320", "20140619", "20160121", "20180517", "20180816"]:
for caida_date in ["20180517", "20180816"]:
# for caida_date in ["20180816"]:
    ret_list = get_pcap_list_by_date_and_count(caida_date, "60s", 10)

    program_name_dict = {}
    program_name_dict["workload_1"] = [
        ("p416_workload_1_06_07_before_5_hash_1_tofino1", "before"),
        ("p416_workload_1_06_07_after_5_hash_1_tofino1", "after"),
        ]

    program_name_dict["workload_2"] = [
        ("p416_workload_2_10_11_before_1_hash_1_tofino1", "before"),
        ("p416_workload_2_10_11_after_1_hash_1_tofino1", "after"),
        ]

    program_name_dict["workload_3"] = [
        # ("p416_workload_3_10_11_before_1_hash_1_tofino1", "before"),
        ("p416_workload_3_10_11_after_1_hash_1_tofino1", "after"),
        ]

    program_name_dict["workload_4"] = [
        # ("p416_workload_4_10_11_before_1_hash_1_tofino1", "before"),
        ("p416_workload_4_10_11_after_1_hash_1_tofino1", "after"),
        ]


    for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    # for (pcap_full_path, pcap_folder_path, pcap_file_name) in [ret_list[9]]:
        # for workload_name in ["workload_4"]:
        # for workload_name in ["workload_1", "workload_2", "workload_3", "workload_4"]:
        for workload_name in ["workload_2"]:
            for program_name, bf in program_name_dict[workload_name]:
                tuple1 = (workload_name, program_name, bf)
                result_path = os.path.join(os.getenv('result_tofino_dp'), "sketchMD", workload_name, program_name, pcap_file_name.replace("dat", "pcap"))

                print(result_path)
                date = sorted(os.listdir(result_path))[-1]
                epoch_txt_path = os.path.join(result_path, date, "epoch.txt")
                gt_folder = os.path.join(os.getenv('result_gt'), "sketchMD", workload_name, program_name, pcap_file_name.replace("dat", "pcap"), date)
                # print(epoch_txt_path)
                # print(gt_folder)


                # ################# this is for getting thresholds #################
                # result_path_2 = os.path.join(os.getenv('result_tofino_dp'), "sketchMD", "workload_1", "p416_workload_1_06_07_before_5_hash_1_tofino1", pcap_file_name.replace("dat", "pcap"))
                # date_2 = sorted(os.listdir(result_path_2))[-1]
                # epoch_txt_path = os.path.join(result_path_2, date_2, "epoch.txt")
                # gt_folder = os.path.join(os.getenv('result_gt'), "sketchMD", workload_name, program_name, pcap_file_name.replace("dat", "pcap"), date_2)



                if workload_name == "workload_1":
                    inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6"]
                    flowkey_list = ["srcIP", "srcIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
                    flowsize_list = [1, 0, 0, 0, 0, 1]
                    epoch_list = [40, 10, 30, 30, 20, 40]

                    # inst_name_list = ["inst6"]
                    # flowkey_list = ["srcIP,dstIP,srcPort,dstPort,proto"]
                    # flowsize_list = [1]
                    # epoch_list = [40]

                if workload_name == "workload_2":
                    # inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7", "inst8", "inst9", "inst10"]
                    # flowkey_list = ["dstIP,dstPort"] * 10
                    # flowsize_list = [1, 1, 1, 1, 1, 1, 1, 0, 0, 1]
                    # epoch_list = [10, 10, 20, 20, 30, 30, 30, 30, 30, 40]

                    inst_name_list = ["inst1", "inst7"]
                    flowkey_list = ["dstIP,dstPort"] * 3
                    flowsize_list = [1, 1]
                    epoch_list = [10, 30]

                    # inst_name_list = ["inst2", "inst8", "inst9"]
                    # flowkey_list = ["dstIP,dstPort"] * 3
                    # flowsize_list = [1, 0, 0]
                    # epoch_list = [10, 30, 30]

                if workload_name == "workload_3":
                    inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7", "inst8", "inst9", "inst10"]
                    flowkey_list = ["srcIP", "dstIP", "srcIP,dstIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
                    flowsize_list = [1] * 10
                    epoch_list = [30] * 10

                    # inst_name_list = ["inst4", "inst5"]
                    # flowkey_list = ["srcIP,dstIP", "srcIP,srcPort"]
                    # flowsize_list = [1] * 2
                    # epoch_list = [30] * 2

                if workload_name == "workload_4":
                    inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7", "inst8", "inst9", "inst10"]
                    flowkey_list = ["srcIP", "dstIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
                    flowsize_list = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                    epoch_list = [20, 30, 20, 10, 20, 30, 30, 30, 40, 30]

                    # inst_name_list = ["inst8"]
                    # flowkey_list = ["srcIP,dstIP,srcPort,dstPort"]
                    # flowsize_list = [1]
                    # epoch_list = [30]


                for inst_name, flowkey, flowsize, epoch in zip(inst_name_list, flowkey_list, flowsize_list, epoch_list):
                    gt_path = os.path.join(gt_folder, inst_name)

                    # -g option is for following epoch count
                    cmd_1 =  f"%s/main -f %s -n %s -o %s -r 'gt' -p {flowsize} -k '{flowkey}' -e {epoch} -g {epoch_txt_path} " %\
                         (sw_dp_simulator_path, pcap_full_path, pcap_file_name, gt_path)
                    log = f"[GT] {pcap_file_name} {inst_name}"

                    cmd_normal = cmd_1 + "-z '%s'" % log
                    cmd_list.append(cmd_normal)


for cmd in cmd_list:
    print(cmd)
    print()
print(len(cmd_list))

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 70)

