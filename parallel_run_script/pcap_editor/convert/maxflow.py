import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.SketchLib.fcm_eval.common import common_cmd

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

cmd_list = []
date = 20140320
# folder_name_string_list = ["500k", "1M", "5M", "10M"]
folder_name_string_list = ["30M"]
for flow in folder_name_string_list:
    pcap_list = get_pcap_list_by_date_and_count(date, flow, 1)

    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:

        # print(pcap_full_path, pcap_folder_path, pcap_file_name)
        # print(pcap_full_path)
        # print(pcap_storage_path)
        output_pcap_path = os.path.join(pcap_storage_path, "compact", pcap_full_path.split(pcap_storage_path+"/")[1])
        output_pcap_path = output_pcap_path.replace(".pcap", ".dat")

        cmd =  "%s/bin/convert " % pcap_editor_path
        cmd += "%s " % pcap_full_path
        cmd += "%s " % os.path.dirname(output_pcap_path)
        cmd += "%s " % os.path.basename(output_pcap_path)
        cmd_list.append(cmd)

for cmd in cmd_list:
    print(cmd)
# print(len(cmd_list))

# print(cmd_list[:1])

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 40)

