import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.SketchLib.fcm_eval.common import common_cmd

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 60)
# pcap_list = get_test_pcap_list_count("small.pcap")

cmd_list = []

for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
    pass

# starting_index = 1
# folder_name_string = "5k"
# max_flow_count = 5000

starting_index = 1
folder_name_string_list = ["500k", "1M", "5M", "10M", "30M"]
max_flow_count_list = [500000, 1000000, 5000000, 10000000, 30000000]

for folder_name_string, max_flow_count in zip(folder_name_string_list, max_flow_count_list):
    print(pcap_folder_path)
    input_folder = pcap_folder_path
    output_folder = pcap_folder_path.replace("60s", folder_name_string)
    pcap_file_name = pcap_list[starting_index-1][2]

    cmd =  "%s/bin/maxflow " % pcap_editor_path
    cmd += "%s " % input_folder
    cmd += "%s " % output_folder
    cmd += "%s " % pcap_file_name
    cmd += "%s " % os.path.join(pcap_editor_path, "dummy.pcap")
    cmd += "%d " % starting_index
    cmd += "%d " % max_flow_count
    cmd_list.append(cmd)

#     input_folder = pcap_folder_path
#     output_folder = input_folder.replace("60s", "30s")

for cmd in cmd_list:
    print(cmd)
# print(len(cmd_list))

# # print(cmd_list[:1])

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 40)

