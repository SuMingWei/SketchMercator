import sys
import os
env_setting_path = os.getenv('env_setting')
sys.path.append(env_setting_path)
from env_module import py_env_setup
py_env_setup()

from env_module import pcap_storage_path

from data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
ret_list = get_pcap_list_by_date_and_count(20140320, "60s", 1)


for (full_path, folder_path, file_name) in ret_list:
    # print(full_path)
    # print(folder_path)
    # print(file_name)

    input_folder = folder_path


    # output_folder = os.path.join(pcap_storage_path, "extension", "20140320", "60s", "4x")

    output_folder = os.path.join(pcap_storage_path, "extension", "20140320", "1s", "4x")
    # output_folder = os.path.join(pcap_storage_path, "extension", "20140320", "2s", "4x")


    pcap_file_name = file_name
    extension_rate = 4
    dummy_location = "dummy.pcap"

    os.makedirs(output_folder, exist_ok=True)

    cmd = "./bin/extension %s %s %s %d %s" % (input_folder, output_folder, pcap_file_name, extension_rate, dummy_location)
    print(cmd)
    os.system(cmd)

    original_pcap = os.path.join(output_folder, pcap_file_name)
    temp_pcap = "temp.pcap"

    cmd = "editcap -T rawip %s %s" % (original_pcap, temp_pcap)
    print(cmd)
    os.system(cmd)

    cmd = "tcprewrite --dlt=enet --enet-dmac=00:11:22:33:44:55 --enet-smac=66:77:88:99:AA:BB --infile=%s --outfile=%s" % (temp_pcap, original_pcap)
    print(cmd)
    os.system(cmd)

