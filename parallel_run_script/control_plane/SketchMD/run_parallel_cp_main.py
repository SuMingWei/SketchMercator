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

# sketch_name = "univmon"
# sketch_name = "hll"
# sketch_name = "cs"
sketch_name = "cm"

# date = 20140320

# date = 20140619
date = 20180816
# pcap_list = get_dat_list_by_date_and_count(date, "60s", 60)
pcap_list = get_dat_list_by_date_and_count(date, "60s", 1)


# date = 100
# pcap_list = get_test_pcap_list_count("small.pcap")
# pcap_list = get_test_dat_list_count("small.dat")

lcount = 0

# epoch = 15
epoch = 60

from parallel_run_script.data_plane.SketchMD.configs.load import load_param_list

ret = load_param_list(sketch_name)
epoch_list = ret["epoch_list"]
key_list = ret["key_list"]
width_list = ret["width_list"]
row_list = ret["row_list"]
level_list = ret["level_list"]
seed_list = ret["seed_list"]
xor_hash_type_list = ret["xor_hash_type_list"]

cmd_list = []

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(60)

print(seed_list)
# for seed in [1]:
for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
    for key, epoch, row, width, level, xor_hash_type in zip(key_list, epoch_list, row_list, width_list, level_list, xor_hash_type_list):

        # result_list = []
        for seed in seed_list:
            
            str = "epoch_%02d_row_%d_width_%d_level_%d_seed_%d_hashtype_%02d" % (epoch, row, width, level, seed, xor_hash_type)
            output_dir = os.path.join(result_sw_dp_path, "SketchMD", sketch_name, pcap_file_name, key, str)
            # print(output_dir)
            output_pkl_dir = os.path.join(result_cp_path, "SketchMD", sketch_name, pcap_file_name, key, str)
            print(output_pkl_dir)
            lcount += 1
            from sketch_control_plane.SketchMD.sketch_cp_main import sketch_cp
            sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level, xor_hash_type)
            # if lcount == 1:
            #     exit(1)
            # helper.call(sketch_cp, (sketch_name, output_dir, output_pkl_dir, row, width, level, ))
            # exit(1)
