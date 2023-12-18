import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

# date = 20140320
date = 20140619
pcap_list = get_pcap_list_by_date_and_count(date, "60s", 60)

topk = 100

row_list = [5, 5]
level_list = [16, 16]
width_list = [2048, 2048]
flag_list = [False, True]

sketch_name = "univmon"

from sketch_control_plane.SketchLib.univmon.main import sketch_cp
from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(100)

# for seed in [1,2,3,4,5]:
for seed in [6,7,8,9,10]:
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        for width, row, level, flag, in zip(width_list, row_list, level_list, flag_list):
            # if not flag:
            helper.call(sketch_cp, (sketch_name, pcap_file_name, width, row, level, flag, seed, topk, ))
            # sketch_cp(sketch_name, pcap_file_name, width, row, level, flag, seed, topk)
