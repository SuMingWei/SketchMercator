from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_sw_dp_path
from python_lib.sketch_aug.delay_calculator import total_delay

from python_lib.sketch_aug.delay_calculator import read_before_delay
from python_lib.sketch_aug.delay_calculator import read_during_delay
from python_lib.sketch_aug.delay_calculator import reset_before_delay
from python_lib.sketch_aug.delay_calculator import reset_during_delay

# ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)
# for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
#     print(pcap_full_path, pcap_folder_path, pcap_file_name)
# # # print(ret_list)

cmd_list = []
ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    if pcap_file_name == "small.pcap":
        continue
    if pcap_file_name == "4s.pcap":
        continue
    print(pcap_full_path, pcap_folder_path, pcap_file_name)

    cmd_template_1 =  "%s/main -f %s -n %s -o %s -r 'mrb' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, result_sw_dp_path)
    # cmd_template_2 =  "-w %d -d 1 -l 16 -c -e %d "
    cmd_template_2 =  "-w %d -d 1 -l 16 -c -e %d -b %d -a %s -z '%s'"

    log_template = "[MRB] width(%d)_epoch(%d)_P(%d)_delay(%s) " + pcap_file_name

    for epoch in [10]:
        for width in [256, 512, 1024, 2048, 4096]:
            delay_str = "0,0,0,0"

            log = log_template % (width, epoch, 0, delay_str)
            cmd_2 = cmd_template_2 % (width, epoch, 0, delay_str, log)
            cmd_normal = cmd_1 + cmd_2
            cmd_list.append(cmd_normal)

            # delay1 = str(read_before_delay(width*16))
            # delay1_str = "%s,0,0,0" % delay1

            # delay2 = str(reset_before_delay(width*16))
            # delay2_str = "0,%s,0,0" % delay2

            # delay3 = str(read_during_delay(width*16))
            # delay3_str = "0,0,%s,0" % delay3

            # delay4 = str(reset_during_delay(width*16))
            # delay4_str = "0,0,0,%s" % delay4

            # for b, delay_str in zip([0, 1, 2, 3, 4], [delay0_str, delay1_str, delay2_str, delay3_str, delay4_str]):
            #     log = log_template % (width, epoch, b, delay_str)
            #     cmd_2 = cmd_template_2 % (width, epoch, b, delay_str, log)
            #     cmd_normal = cmd_1 + cmd_2
            #     cmd_list.append(cmd_normal)

            # b = 6
            # delay_str = "%s,%s,%s,%s" % (delay1, delay2, delay3, delay4)
            # log = log_template % (width, epoch, b, delay_str)
            # cmd_2 = cmd_template_2 % (width, epoch, b, delay_str, log)
            # cmd_normal = cmd_1 + cmd_2
            # cmd_list.append(cmd_normal)
    break


# for cmd in cmd_list:
#     print(cmd)

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 70)



