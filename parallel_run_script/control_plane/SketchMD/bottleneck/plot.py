import os

from python_lib.pkl_saver import PklSaver
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
for sketch_name in sketch_list:
    for width in width_list:
        print(f"width ({width})")
        result_list = []
        for epoch in epoch_list:
            print(f"\tepoch ({epoch})")
            for flowkey in flowkey_list:
                print(f"\t\tflowkey ({flowkey})")
                for date in date_list:  # 5
                    print(f"\t\t\tdate ({date})")
                    pcap_list = get_pcap_list_by_date_and_count(date, "60s", 1)
                    result_list_2 = []
                    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
                        # print(pcap_full_path, width, flowkey, epoch, sketch_name)
                        str = f"width_{width}_epoch_{epoch}"
                        # print(str)
                        output_dir = os.path.join(result_sw_dp_path, "SketchMD", sketch_name, pcap_file_name, flowkey, str)
                        # print(output_dir)

                        output_pkl_dir = os.path.join(result_cp_path, "SketchMD", sketch_name, pcap_file_name, flowkey, str)
                        # print(output_pkl_dir)

                        saver = PklSaver(output_pkl_dir, "data.pkl")
                        result = saver.load()
                        for ent in result:
                            result_list.append(ent[2])
                            result_list_2.append(ent[2])
                        print("\t\t\t\t\t", sum(result_list_2)/len(result_list_2), result_list_2)
                        
                    # print(result_list)
        print("width total ", sum(result_list)/len(result_list))
                    # print("\t\t\t", sum(result_list)/len(result_list), result_list)
