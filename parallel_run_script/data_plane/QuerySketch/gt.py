from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count
from env_setting.env_module import sw_dp_simulator_path, result_gt_path
import os

ret_list = get_pcap_list_by_date_and_count("20180816", "60s", 10)
# ret_list = get_test_pcap_list_count("8s.pcap")
# ret_list = get_test_pcap_list_count("small.pcap")
cmd_list = []

inst_name_list = ["inst1", "inst2", "inst3", "inst4", "inst5", "inst6", "inst7"]
flowkey_list = ["srcIP", "srcIP", "srcIP,dstIP", "srcIP,srcPort", "dstIP,dstPort", "srcIP,dstIP,srcPort,dstPort,proto"]
flowsize_list = [1, 0, 0, 0, 0, 1]
epoch_list = [40, 10, 30, 30, 20, 40]
# epoch_list = [2, 2, 4, 4, 6, 6]
# epoch_list = [10, 10, 10, 10, 10, 10]
# epoch_list = [4, 4, 4, 8, 8, 8]


for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    for inst_name, flowkey, flowsize, epoch in zip(inst_name_list, flowkey_list, flowsize_list, epoch_list):
        if flowsize == 1:
            flowsize_path = "counts"
        else:
            flowsize_path = "bytes"

        # gt_path = os.path.join(result_gt_path, "workload_1", pcap_file_name, inst_name, flowsize_path)
        gt_path = os.path.join(result_gt_path, pcap_file_name, inst_name, flowsize_path)
        cmd_template_1 =  f"%s/main -f %s -n %s -o %s -r 'gt' -p {flowsize} -k '{flowkey}' "
        cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, gt_path)
        cmd_2 =  f"-e {epoch} "
        log = f"[GT] epoch({epoch}) " + pcap_file_name

        cmd_normal = cmd_1 + cmd_2 + "-z '%s'" % log
        cmd_list.append(cmd_normal)
    #     break
    # break

from python_lib.run_parallel_helper import run_cmd_list

for cmd in cmd_list:
    print(cmd)
print(len(cmd_list))
    # break

# run_cmd_list(cmd_list, 60)
