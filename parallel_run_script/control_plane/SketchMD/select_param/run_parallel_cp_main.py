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

# sketch_list = ["cm", "hll"]
# sketch_list = ["cm"]
sketch_list = ["hll"]
date_list = [20140320, 20160121, 20180816]
# width_list = [1024, 2048, 4096, 8192, 16384]
width_list = [1024, 2048, 4096, 8192, 16384, 32768, 65536]
epoch_list = [10, 30]
flowkey_list = ["srcIP",
                "srcIP,srcPort",
                "srcIP,dstIP,srcPort,dstPort,proto",
                ]
lcount = 0
row = 1
level = 1
seed = 1


cmd_list = []
for date in date_list:  # 5
    pcap_list = get_pcap_list_by_date_and_count(date, "60s", 1)
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        for flowkey in flowkey_list:
            for width in width_list:
                for epoch in epoch_list:
                    for sketch_name in sketch_list:
                        # print(pcap_full_path, width, flowkey, epoch, sketch_name)
                        str = f"width_{width}_epoch_{epoch}"
                        # print(str)
                        output_dir = os.path.join(result_sw_dp_path, "SketchMD", sketch_name, pcap_file_name, flowkey, str)
                        print(output_dir)

                        output_pkl_dir = os.path.join(result_cp_path, "SketchMD", sketch_name, pcap_file_name, flowkey, str)
                        print(output_pkl_dir)
                        from sketch_control_plane.SketchMD.select_params.sketch_cp_main import sketch_cp
                        sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level)

                        # exit(1)

                        print()

                        lcount += 1
print(lcount)