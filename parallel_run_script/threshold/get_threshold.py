from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count
from env_setting.env_module import sw_dp_simulator_path, result_gt_path
from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth_topk
import os

ret_list = get_pcap_list_by_date_and_count("20140320", "60s", 10)
# ret_list = get_test_pcap_list_count("8s.pcap")
# ret_list = get_test_pcap_list_count("small.pcap")

cmd_list = []

inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6"]
flowkey_list = ["srcIP", "srcIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
flowsize_list = [1, 0, 0, 0, 0, 1]
epoch_list = [40, 10, 30, 30, 20, 40]
# epoch_list = [2, 2, 4, 4, 6, 6]
# epoch_list = [4, 4, 4, 8, 8, 8]
# epoch_list = [10, 10, 10, 10, 10, 10]


for inst_name, flowkey, flowsize, epoch in zip(inst_name_list, flowkey_list, flowsize_list, epoch_list):
    flowsize_list = []
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
        if flowsize == 1:
            flowsize_path = "counts"
        else:
            flowsize_path = "bytes"
        gt_path = os.path.join(result_gt_path, "workload_1", pcap_file_name, inst_name, flowsize_path)
        # gt_path = os.path.join(result_gt_path, pcap_file_name, inst_name, flowsize_path)
        for folder_name in sorted(os.listdir(gt_path)):
            full_path = os.path.join(gt_path, folder_name)
            if epoch == 40 and os.path.basename(full_path) == "02":
                continue
            # print(full_path)
            gt = load_ground_truth_topk(full_path, 50)
            flowsize = gt[-1][1]
            flowsize_list.append(flowsize)
            print(epoch, full_path, flowsize)
            if epoch == 40:
                break
    # print(min(flowsize_list))
