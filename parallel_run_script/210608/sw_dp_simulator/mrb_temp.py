from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_sw_dp_path
from python_lib.sketch_aug.delay_calculator import total_delay

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)
# print(ret_list)

cmd_list = []

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:

    cmd_template_1 =  "%s/main -f %s -n %s -o %s -r 'mrb' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, result_sw_dp_path)

    cmd_template_2 =  "-w %d -d 1 -l 16 -c -e %d "

    log_template = "[MRB] width(%d)_epoch(%d)_delay(%d) " + pcap_file_name

    for epoch in [1, 3, 5, 10]:
        for width in [256, 512, 1024, 2048, 4096]:
            log = log_template % (width, epoch, 0)
            cmd_2 = cmd_template_2 % (width, epoch)
            cmd_normal = cmd_1 + cmd_2 + "-z '%s'" % log
            # print(cmd_normal)
            cmd_list.append(cmd_normal)

            delay = total_delay(16 * width, 1)

            log = log_template % (width, epoch, delay)
            cmd_sketch_aug = cmd_1 + cmd_2 + "-a %d " % delay + "-z '%s'" % log
            # print(cmd_sketch_aug)
            cmd_list.append(cmd_sketch_aug)
    #         break
    #     break
    # break

# for cmd in cmd_list:
#     print(cmd)

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 70)



