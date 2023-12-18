import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.common.common import general_cmd

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_dat_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_test_pcap_list_count
from data_helper.data_path_helper.pcap_path_helper import get_test_dat_list_count

seed_list = [1]

key = "srcIP,dstIP,srcPort,dstPort"
key_list = []

row = 5
row_list = []

width = 8192
width_list = []

level = 1
level_list = []

epoch_list = []
size_list = []

for epoch in [10, 20, 30, 40]:
    key_list.append(key)
    row_list.append(row)
    width_list.append(width)
    level_list.append(level)
    epoch_list.append(epoch)
    size_list.append(1)

for epoch in [10, 20, 30]:
    key_list.append(key)
    row_list.append(row)
    width_list.append(width)
    level_list.append(level)
    epoch_list.append(epoch)
    size_list.append(0)


sketch_name = "cm"
date = 20140320
pcap_list = get_pcap_list_by_date_and_count(date, "60s", 10)

lcount = 0

cmd_list = []

for seed in seed_list:
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        for key, epoch, row, width, level, size in zip(key_list, epoch_list, row_list, width_list, level_list, size_list):
            str = "epoch_%02d_row_%d_width_%d_level_%d_seed_%d_size_%d" % (epoch, row, width, level, seed, size)
            output_dir = os.path.join(result_sw_dp_path, "SketchMD", sketch_name, pcap_file_name, key, str)
            print(output_dir)

            lcount += 1
            log_template = "[%d] [%s] [%s] [%s]" % (lcount, sketch_name, key, str)

            cmd = general_cmd(pcap_full_path,
               pcap_file_name,

               sketch_name,

               key,

               width,
               row,
               level,

               True,
               True,
               True,
               True,

               epoch,
               output_dir,
               None,
               10000,
               seed,
               log_template,
               size)
            cmd_list.append(cmd)



for cmd in cmd_list:
    print(cmd)

print(len(cmd_list))
# # # # print(cmd_list[:1])

from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 70)
# # run_cmd_list(cmd_list[0:1], 50)
# # run_cmd_list(cmd_list[1:2], 50)
# # run_cmd_list(cmd_list[0:1], 50)
# # run_cmd_list(cmd_list[3:4], 32)

