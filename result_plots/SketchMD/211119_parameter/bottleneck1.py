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

    if epoch != 40:
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
            # print(list)
        result.append(inst_list)
        print()

from statistics import mean

print(len(result[0]))
print(len(result[1]))
print(len(result[2]))
print(len(result[3]))
print(len(result[4]))
print(len(result[5]))
print(len(result[6]))

print(mean(result[0]))
print(mean(result[0]+result[1]))
print(mean(result[0]+result[1]+result[2]))
print(mean(result[0]+result[1]+result[2]+result[3]))
print(mean(result[0]+result[1]+result[2]+result[3]+result[4]))
print(mean(result[0]+result[1]+result[2]+result[3]+result[4]+result[5]))
print(mean(result[0]+result[1]+result[2]+result[3]+result[4]+result[5]+result[6]))

# sketchlib
# 3.8595813307897333
# 2.328644451748649
# 2.8123742438983186
# 2.5321091988276776
# 2.804772362096439
# 2.671337295453499
# 2.800873736160177


# p4all 
# actual_row = [3, 3, 3, 3, 4, 4, 4]
# 4.774772736398096
# 3.0048807005746148
# 3.5392744618667265
# 3.2202334694981585
# 3.4630867213489522 (*)
# 3.2889713186215634
# 3.4077830733158034


# actual_row = [2, 2, 2, 2, 2, 2, 2]
# 5.938647037578469
# 3.924269692160937
# 4.505911698261405
# 4.170221026229225
# 4.493808876064867
# 4.344224085732716 (*)
# 4.490739667834136

# actual_row = [1, 1, 1, 1, 1, 1, 2]
# 10.291179634293428
# 8.12394532166008
# 8.73788122905528
# 8.446327472131951
# 8.771676146487776
# 8.656186628560288
# 8.615225578364857 (*)