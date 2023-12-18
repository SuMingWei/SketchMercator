# PCAP_NAME=equinix-chicago.dirA.20160121-130000.UTC.anon.pcap
# PCAP_PATH=$pcap_storage/caida/20160121/60s/$PCAP_NAME

# RESULT_GT=$result_gt
# RESULT_SW_DP=$result_sw_dp

# # # run gt
# # ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_GT -z "20160121-130000" -r "gt" -p 1 -k "srcIP" -e 1

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_gt_path

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)

cmd_list = []

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    cmd_template_1 =  "%s/main -f %s -n %s -o %s -r 'gt' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, result_gt_path)

    cmd_template_2 =  "-e %d "
    log_template = "[GT] epoch(%d) " + pcap_file_name

    for epoch in [1, 3, 5, 10]:
        log = log_template % (epoch)
        cmd_2 = cmd_template_2 % (epoch)
        cmd_normal = cmd_1 + cmd_2 + "-z '%s'" % log
        cmd_list.append(cmd_normal)

from python_lib.run_parallel_helper import run_cmd_list

for cmd in cmd_list:
    print(cmd)
    break

run_cmd_list(cmd_list, 70)
