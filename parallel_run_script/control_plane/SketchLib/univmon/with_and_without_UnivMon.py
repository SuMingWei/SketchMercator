import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 20)
# pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 1)

# topk = 50
topk = 100

# row_list = [1, 3, 5, 5]
# level_list = [8, 6, 5, 16]
# width_list = [131072, 32768, 32768, 2048]
# flag_list = [False, False, False, True]

level_list = [8, 6, 5]
row_list = [4, 5, 6]
width_list = [32768, 32768, 32768]
flag_list = [False, False, False]

sketch_name = "univmon"

from sketch_control_plane.SketchLib.univmon.main import sketch_cp
from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(80)

for seed in [1]:
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        for width, row, level, flag, in zip(width_list, row_list, level_list, flag_list):
            # if flag:
            helper.call(sketch_cp, (sketch_name, pcap_file_name, width, row, level, flag, seed, topk, ))
                # sketch_cp(sketch_name, pcap_file_name, width, row, level, flag, seed, topk)
