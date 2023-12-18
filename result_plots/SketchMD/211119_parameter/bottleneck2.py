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

for epoch in [10, 20, 30, 40]:
    key_list.append(key)
    row_list.append(row)
    width_list.append(width)
    level_list.append(level)
    epoch_list.append(epoch)
    size_list.append(1)

for epoch in [10]:
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

from python_lib.pkl_saver import PklSaver
result = []
for seed in seed_list:
    for key, epoch, row, width, level, size in zip(key_list, epoch_list, row_list, width_list, level_list, size_list):
        inst_list = []
        for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
            str = "epoch_%02d_row_%d_width_%d_level_%d_seed_%d_size_%d" % (epoch, row, width, level, seed, size)
            output_pkl_dir = os.path.join(result_cp_path, "SketchMD", sketch_name, pcap_file_name, key, str)
            print(output_pkl_dir)
            saver = PklSaver(output_pkl_dir, "data.pkl")
            list = saver.load()
            if epoch == 40:
                inst_list += list[:-1]
            else:
                inst_list += list
            print(list)
        result.append(inst_list)
        print()

from statistics import mean

# print(len(result[0]))
# print(len(result[1]))
# print(len(result[2]))
# print(len(result[3]))

# print(mean(result[0]))
# print(mean(result[0]+result[1]))
# print(mean(result[0]+result[1]+result[2]))
# print(mean(result[0]+result[1]+result[2]+result[3]))

# 3.8595813307897333
# 4.155485358025488
# 4.356077262296361
# 4.463960443080588
