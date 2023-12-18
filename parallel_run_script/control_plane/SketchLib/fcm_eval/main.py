import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.SketchLib.fcm_eval.common import common_cmd

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, get_test_pcap_list_count

sketch_list = ["cm", "fcm"]
# sketch_list = ["cm"]
# sketch_list = ["fcm"]

pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 20)
# pcap_list = get_pcap_list_by_date_and_count(20140320, "60s", 1)

topk = 50

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(80)

for sketch_name in sketch_list:
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        from sketch_control_plane.SketchLib.fcm_eval.main import sketch_cp
        # sketch_cp(sketch_name, pcap_file_name, topk)
        helper.call(sketch_cp, (sketch_name, pcap_file_name, topk, ))
