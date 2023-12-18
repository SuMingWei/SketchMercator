from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_sw_dp_path

delay={}
delay[1] = 26
delay[2] = 26*2
delay[3] = 26*3
delay[4] = 26*4
delay[5] = 26*5

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)

cmd_list = []

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    # print(pcap_full_path)
    # print(pcap_file_name)
    # print(sw_dp_simulator_path)

    cmd_template_1 =  "%s/main -f %s -n %s -o %s -r 'cs' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, result_sw_dp_path)

    cmd_template_2 =  "-w %d -d %d -l 1 -c -e %d "


    log_template = "[CS] width(%d)_row(%d)_epoch(%d)_delay(%d) " + pcap_file_name
    width=4096

    for epoch in [1, 3, 5, 10]:
        for row in [1, 2, 3, 4, 5]:
            log = log_template % (width, row, epoch, 0)
            cmd_2 = cmd_template_2 % (width, row, epoch)
            cmd_normal = cmd_1 + cmd_2 + "-z '%s'" % log
            cmd_list.append(cmd_normal)

            log = log_template % (width, row, epoch, delay[row])
            cmd_sketch_aug = cmd_1 + cmd_2 + "-a %d " % delay[row] + "-z '%s'" % log
            cmd_list.append(cmd_sketch_aug)

from python_lib.run_parallel_helper import run_cmd_list

# for cmd in cmd_list:
#     print(cmd)

run_cmd_list(cmd_list, 70)
