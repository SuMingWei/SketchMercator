from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_sw_dp_path
from python_lib.sketch_aug.delay_calculator import total_delay

from python_lib.sketch_aug.delay_calculator import read_before_delay
from python_lib.sketch_aug.delay_calculator import read_during_delay
from python_lib.sketch_aug.delay_calculator import reset_before_delay
from python_lib.sketch_aug.delay_calculator import reset_during_delay

# for size in [4096, 8192, 16384, 32768, 65536]:
#     read_before_delay(size)
#     read_during_delay(size)
#     reset_before_delay(size)
#     reset_during_delay(size)
#     print()

# exit(1)

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)

cmd_list = []

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    print(pcap_full_path)
    print(pcap_file_name)

    cmd_template_1 =  "%s/main -f %s -n %s -o %s -r 'cs' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, result_sw_dp_path)

    cmd_template_2 =  "-w %d -d %d -l 1 -c -e %d -b %d -a %s -z '%s'"

    log_template = "[CS] width(%d)_row(%d)_epoch(%d)_P(%d)_delay(%s) " + pcap_file_name

    row = 1
    # epoch = 1

    for epoch in [1, 3, 5]:
        for width in [4096, 8192, 16384, 32768, 65536]:
            delay0_str = "0,0,0,0"

            delay1 = str(read_before_delay(width))
            delay1_str = "%s,0,0,0" % delay1

            delay2 = str(reset_before_delay(width))
            delay2_str = "0,%s,0,0" % delay2

            delay3 = str(read_during_delay(width))
            delay3_str = "0,0,%s,0" % delay3

            delay4 = str(reset_during_delay(width))
            delay4_str = "0,0,0,%s" % delay4

            for b, delay in zip([0, 1, 2, 3, 4], [delay0_str, delay1_str, delay2_str, delay3_str, delay4_str]):
                log = log_template % (width, row, epoch, b, delay)
                cmd_2 = cmd_template_2 % (width, row, epoch, b, delay, log)
                cmd_normal = cmd_1 + cmd_2
                cmd_list.append(cmd_normal)

            b = 6
            delay_str = "%s,%s,%s,%s" % (delay1, delay2, delay3, delay4)
            log = log_template % (width, row, epoch, b, delay_str)
            cmd_2 = cmd_template_2 % (width, row, epoch, b, delay_str, log)
            cmd_normal = cmd_1 + cmd_2
            cmd_list.append(cmd_normal)
        #     break
        # break
    break

from python_lib.run_parallel_helper import run_cmd_list

# for cmd in cmd_list:
#     print(cmd)

run_cmd_list(cmd_list, 70)
