from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from env_setting.env_module import sw_dp_simulator_path, result_sw_dp_path

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)

delay={}
delay[512] = 3
delay[1024] = 7
delay[2048] = 13
delay[4096] = 26
delay[8192] = 52

cmd_list = []

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:

    cmd_template_1 =  "%s/main -f %s -n %s -o %s -r 'hll' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name, result_sw_dp_path)

    cmd_template_2 =  "-w %d -d 1 -l 1 -c -e %d "

    log_template = "[HLL] width(%d)_epoch(%d)_delay(%d) " + pcap_file_name

    for epoch in [1, 3, 5, 10]:
        for width in [512, 1024, 2048, 4096, 8192]:
            log = log_template % (width, epoch, 0)
            cmd_2 = cmd_template_2 % (width, epoch)
            cmd_normal = cmd_1 + cmd_2 + "-z '%s'" % log
            # print(cmd_normal)
            cmd_list.append(cmd_normal)

            log = log_template % (width, epoch, delay[width])
            cmd_sketch_aug = cmd_1 + cmd_2 + "-a %d " % delay[width] + "-z '%s'" % log
            # print(cmd_sketch_aug)
            cmd_list.append(cmd_sketch_aug)


from python_lib.run_parallel_helper import run_cmd_list

run_cmd_list(cmd_list, 70)

# for cmd in cmd_list:
#     print(cmd)


