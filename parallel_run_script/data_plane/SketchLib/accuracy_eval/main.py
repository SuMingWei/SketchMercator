import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.SketchLib.fcm_eval.common import common_cmd

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

sketch_list = ["gt", "pcsa", "mrb", "hll", "rhhh", "cs", "univmon"]

# sketch_list = ["gt"]
# sketch_list = ["cm"]
# sketch_list = ["fcm"]

threshold = 5000
pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 20)

# threshold = 100
# pcap_list = get_test_pcap_list_count("small.pcap")


lcount = 0
epoch = 30


cmd_list = []

for sketch_name in sketch_list:
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        lcount += 1

        if sketch_name == "cm":
            width = 65536
            depth = 6
            level = 1

        if sketch_name == "gt":
            width = 0
            depth = 0
            level = 0

        if sketch_name == "fcm":
            width = 524288
            depth = 6
            level = 1

        output_dir = os.path.join(result_sw_dp_path, "SketchLib", "fcm_eval", sketch_name, pcap_file_name)

        cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, output_dir, threshold, lcount)
        cmd_list.append(cmd)


for cmd in cmd_list:
    print(cmd)
print(len(cmd_list))
# print(cmd_list[:1])

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 32)

