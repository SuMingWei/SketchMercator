from env_setting.env_module import sw_dp_simulator_path

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_input


from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path

# ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)
# for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
#     print(pcap_full_path, pcap_folder_path, pcap_file_name)
# # # print(ret_list)

cmd_list = []
ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)


MRB_NAME = "mrb_pingpong"
# MRB_NAME = "mrb_opt"
API = "cpp"

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    if pcap_file_name == "small.pcap":
        continue
    if pcap_file_name == "4s.pcap":
        continue

    print(pcap_full_path, pcap_folder_path, pcap_file_name)
    # # break
    
    cmd_template_1 =  "%s/main -f %s -n %s -r 'mrb' -p 1 -k 'srcIP' "
    cmd_1 = cmd_template_1  % (sw_dp_simulator_path, pcap_full_path, pcap_file_name)

    cmd_template_2 =  "-w %d -d 1 -l 16 -c -e %d -b %d -a %s -z '%s' -g %s -o %s"
    log_template = "[%s] " % (MRB_NAME) + "width(%d)_epoch(%d)_P(%d)_delay(%s) " + pcap_file_name


    delays = {}
    delays[4096] = 1.722243
    delays[8192] = 3.53519
    delays[16384] = 7.345157
    delays[32768] = 14.843539
    delays[65536] = 30.30019

    msg_list = []
    # for epoch in [1, 5, 10, 20, 30]:
    #     for width in [256, 512, 1024, 2048, 4096]:
    #     # for size in [4096, 8192, 16384, 32768, 65536]:
    #         if epoch <= delays[width*16]:
    #             continue
    for epoch in [1, 5, 10, 20, 30]:
        for width in [256, 512, 1024, 2048, 4096]:
            # if epoch != 1:
            #     continue
            # if width != 512:
            #     continue
            delay_str = "0,0,0,0"

            output_dir = sw_dp_path_input(MRB_NAME, epoch, width, d=1, l=16, problem=0, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API)
            path = get_pcounter_path(MRB_NAME, API, width*16, epoch)
            log = log_template % (width, epoch, 0, delay_str)
            cmd_2 = cmd_template_2 % (width, epoch, 0, delay_str, log, path, output_dir)
            cmd_normal = cmd_1 + cmd_2
            cmd_list.append(cmd_normal)
        #     break
        # break
    break


for cmd in cmd_list:
    print(cmd)

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 70)



