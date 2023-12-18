import sys
import os

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
# ret_list = get_pcap_list_by_date_and_count(20160121, "60s", 10)
# ret_list = get_pcap_list_by_date_and_count(20140320, "60s", 10)
for caida_date in [20140619, 20180517, 20180816]:
    ret_list = get_pcap_list_by_date_and_count(caida_date, "60s", 10)

    for (full_path, folder_path, file_name) in ret_list:
        # print(full_path, folder_path, file_name)
        (e_full_path, e_folder_path, e_file_name) = convert_to_ether_path(full_path)
        # print((e_full_path, e_folder_path, e_file_name))
        if not os.path.exists(e_folder_path):
            os.makedirs(e_folder_path)

        cmd = "tcprewrite --dlt=enet --enet-dmac=00:11:22:33:44:55 --enet-smac=66:77:88:99:AA:BB --infile=%s --outfile=%s" % (full_path, e_full_path)
        print(cmd)
        os.system(cmd)

        # break
