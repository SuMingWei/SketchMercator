import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import result_cp_path
from env_setting.env_module import sw_dp_simulator_path

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count


# pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 20)
# pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 1)

# topk = 50
topk = 100

row_list = [5]
level_list = [16]
width_list = [2048]
flag_list = [True]

sketch_name = "univmon"

date = 20140320
# folder_name_string_list = ["500k", "1M", "5M", "10M", "30M"]
# folder_name_string_list = ["500k"]
# folder_name_string_list = ["30M"]
folder_name_string_list = ["1M", "5M", "10M"]
# folder_name_string_list = ["500k", "1M", "5M", "10M"]
# folder_name_string_list = ["5M", "10M"]

from sketch_control_plane.SketchLib.univmon.main import sketch_cp
from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(30)

# for seed in [1,3,4,5,7,8,10]:
for seed in [1,2,3,4,5,6,7,8,9,10]:
    # for topk in [100]:
    for topk in [100, 200, 300, 400, 500, 600, 1000]:
        for flow in folder_name_string_list:
            pcap_list = get_pcap_list_by_date_and_count(date, flow, 1)
            for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
                for width, row, level, flag, in zip(width_list, row_list, level_list, flag_list):
                    # if flag:
                    if flag:
                        str = "optimized/row_%d_level_%d_width_%d" % (row, level, width)
                    else:
                        str = "original/row_%d_level_%d_width_%d" % (row, level, width)
                    str2 = "%02d.txt" % seed
                    output_dir = os.path.join(result_sw_dp_path, "SketchLib", sketch_name, pcap_file_name, flow, str, str2)
                    output_pkl_dir = os.path.join(result_cp_path, "SketchLib", sketch_name, pcap_file_name, flow, str, str2, "topk_%d" % topk)
                    # sketch_cp(sketch_name, pcap_file_name, width, row, level, flag, seed, topk, output_dir, output_pkl_dir)
                    helper.call(sketch_cp, (sketch_name, pcap_file_name, width, row, level, flag, seed, topk, output_dir, output_pkl_dir ))
                    # exit(1)
