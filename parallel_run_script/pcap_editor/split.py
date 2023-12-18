import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.SketchLib.fcm_eval.common import common_cmd

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 20)
# pcap_list = get_test_pcap_list_count("small.pcap")

cmd_list = []
for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
    input_folder = pcap_folder_path
    output_folder = input_folder.replace("60s", "30s")

    cmd =  "%s/bin/split " % pcap_editor_path
    cmd += "%s " % input_folder
    cmd += "%s " % output_folder
    cmd += "%s " % pcap_file_name
    cmd += "30 "
    cmd += "%s " % os.path.join(pcap_editor_path, "dummy.pcap")
    cmd_list.append(cmd)

for cmd in cmd_list:
    print(cmd)
print(len(cmd_list))

# print(cmd_list[:1])

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 40)

