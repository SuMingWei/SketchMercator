import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.SketchLib.univmon.common import common_cmd

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

sketch_name = "univmon"

date = 20140320
# folder_name_string_list = ["500k", "1M", "5M", "10M", "30M"]
# folder_name_string_list = ["500k", "1M", "5M"]
# , "10M"]
# folder_name_string_list = ["10M"]
folder_name_string_list = ["30M"]

# # date = 100
# # pcap_list = get_test_pcap_list_count("small.pcap")

lcount = 0
epoch = 3600

row_list = [5]
level_list = [16]
width_list = [2048]
flag_list = [True]

cmd_list = []
seed = 1

# for seed in [1,3,4,5,7,8,10]:
for seed in [1,2,3,4,5,6,7,8,9,10]:
    for flow in folder_name_string_list:
        pcap_list = get_pcap_list_by_date_and_count(date, flow, 1)
        for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
            for width, row, level, flag, in zip(width_list, row_list, level_list, flag_list):
                lcount += 1
                if flag:
                    str = "optimized/row_%d_level_%d_width_%d" % (row, level, width)
                else:
                    str = "original/row_%d_level_%d_width_%d" % (row, level, width)
                str2 = "%02d.txt" % seed
                print(str)
                output_dir = os.path.join(result_sw_dp_path, "SketchLib", sketch_name, pcap_file_name, flow, str, str2)
                cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, row, level, epoch, output_dir, date, lcount, flag, seed)
                cmd_list.append(cmd)


for cmd in cmd_list:
    print(cmd)
# # print(len(cmd_list))
# # # print(cmd_list[:1])

from python_lib.run_parallel_helper import run_cmd_list
# run_cmd_list(cmd_list, 30)
run_cmd_list(cmd_list, 2)
# run_cmd_list(cmd_list[3:4], 32)

