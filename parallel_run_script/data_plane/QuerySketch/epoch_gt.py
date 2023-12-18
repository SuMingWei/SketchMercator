from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path, get_test_pcap_list_count, get_dat_list_by_date_and_count, get_pcap_list_by_date_and_hour_list
from env_setting.env_module import sw_dp_simulator_path, result_gt_path
import os

cmd_list = []


# for caida_date in ["20140320", "20140619", "20160121", "20180517", "20180816"]:
for caida_date in ["20180517", "20180621", "20180816"]:
    ret_list = get_pcap_list_by_date_and_hour_list(caida_date, "60s", ["130900", "131000", "131100"])
    # print(ret_list)


    for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
        print(pcap_full_path)

        inst_name = "overall"
        flowkey = "dstIP,dstPort"
        flowsize = 1
        epoch = 60

        gt_folder = os.path.join(os.getenv('result_gt'), "querysketch", caida_date, pcap_file_name.replace("dat", "pcap"))
        gt_path = gt_folder

        # -g option is for following epoch count
        cmd_1 =  f"%s/main -f %s -n %s -o %s -r 'gt' -p {flowsize} -k '{flowkey}' -e {epoch} " %\
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

