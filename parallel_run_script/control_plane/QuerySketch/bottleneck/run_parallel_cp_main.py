import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path
from env_setting.env_module import result_cp_path

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_dat_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_test_pcap_list_count
from data_helper.data_path_helper.pcap_path_helper import get_test_dat_list_count

sketch_list = ["cm"]
date_list = [20140320]

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
actual_row = []

for epoch in [10, 20, 30, 40]:
    key_list.append(key)
    row_list.append(row)
    width_list.append(width)
    level_list.append(level)
    epoch_list.append(epoch)
    size_list.append(1)

    if epoch != 40:
        key_list.append(key)
        row_list.append(row)
        width_list.append(width)
        level_list.append(level)
        epoch_list.append(epoch)
        size_list.append(0)

actual_row = row_list

# actual_row = [3, 3, 3, 3, 4, 4, 4]
# actual_row = [2, 2, 2, 2, 2, 2, 2]
actual_row = [1, 1, 1, 1, 1, 1, 2]


sketch_name = "cm"
date = 20140320
pcap_list = get_pcap_list_by_date_and_count(date, "60s", 10)

lcount = 0

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(60)


for seed in seed_list:
    for key, epoch, row, width, level, size, arow in zip(key_list, epoch_list, row_list, width_list, level_list, size_list, actual_row):
        for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
            str = "epoch_%02d_row_%d_width_%d_level_%d_seed_%d_size_%d" % (epoch, row, width, level, seed, size)
            output_dir = os.path.join(result_sw_dp_path, "QuerySketch", sketch_name, pcap_file_name, key, str)
            print(output_dir)

            output_pkl_dir = os.path.join(result_cp_path, "QuerySketch", sketch_name, pcap_file_name, key, str)
            print(output_pkl_dir)
            from sketch_control_plane.QuerySketch.select_params.sketch_cp_main import sketch_cp
            # sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level, arow)
            helper.call(sketch_cp, (sketch_name, output_dir, output_pkl_dir, row, width, level, arow, ))
        print()
