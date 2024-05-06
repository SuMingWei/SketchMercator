import os
import argparse

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

from parallel_run_script.data_plane.common.common import general_cmd

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_dat_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_test_pcap_list_count
from data_helper.data_path_helper.pcap_path_helper import get_test_dat_list_count

def get_parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sketch', help='sketch', default=None, required=False)
    parser.add_argument('--row', help='row', default=None, required=False)
    parser.add_argument('--width', help='width', default=None, required=False)
    parser.add_argument('--level', help='level', default=None, required=False)
    parser.add_argument('--flowkey', help='flowkey', default=None, required=False)
    parser.add_argument('--epoch', help='epoch', default=None, required=False)
    parser.add_argument('--is_count_packet', help='is_count_packet', default=None, required=False)
    parser.add_argument('--seed', help='seed', default=None, required=False)
    return parser.parse_args()

# /home/ming/SketchMercator/pcap_storage/online_traffic/20180816/60s/sorted_syn.pcap
def get_online_traffic_pcap_list(date, pcap_duration, pcap_count, category = "online_traffic/"):
    online_traffic_path = os.path.join(pcap_storage_path, category)
    ret_list = []

    count = 0

    folder_path = os.path.join(online_traffic_path, str(date), pcap_duration)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".pcap"):
            full_path = os.path.join(folder_path, file_name)
            ret_list.append((full_path, folder_path, file_name))
            count += 1
            if count >= pcap_count:
                break
    return ret_list
                                   
def run_online_traffic(folder_path="/home/ming/SketchMercator/pattern_detection/traffic_generator/training_pcap_file/", pcap_file=["5_5.pcap"],
                       flowkey_list=["srcIP",], width_list=[8192, 16384, 32768, 65536, 131072], epoch_list=[30], seed_list=[1, 2, 3],
                       sketch_list=["cm", "cs"], level=1, row=3, is_count_packet=1, lcount=0, cmd_list=[]):
    for pcap_file_name in pcap_file:
        pcap_full_path = os.path.join(folder_path, pcap_file_name)
        # print(pcap_full_path)
        for flowkey in flowkey_list:
            for width in width_list:
                for epoch in epoch_list:
                    for seed in seed_list:
                        for sketch_name in sketch_list:
                            # print(pcap_full_path, width, flowkey, epoch, sketch_name)
                            lcount += 1

                            stri = f"row_{row}_width_{width}_level_{level}_epoch_{epoch}_count_{is_count_packet}_seed_{seed}"
                            # print(str)
                            output_dir = os.path.join(os.getenv('pattern_detection'), "SketchPaddingOfflineNew", sketch_name, pcap_file_name, flowkey, stri)
                            # print("===output===: " + output_dir)

                            log_template = "[%d] [%s] [%s] [%s]" % (lcount, sketch_name, flowkey, stri)

                            cmd = general_cmd(pcap_full_path,
                            pcap_file_name,

                            sketch_name,

                            flowkey,

                            width,
                            row,
                            level,

                            True,
                            True,
                            True,
                            True,

                            epoch,
                            output_dir,
                            None,
                            0,
                            seed,

                            log_template,
                            is_count_packet)
                            cmd_list.append(cmd)
                            
    print(lcount)


#### common variable
# width_list = [1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288]
width_list = [1024, 2048, 4096, 8192, 16384] # cm cs
# width_list = [1024, 2048, 4096, 8192, 16384, 32768] # cm cs
# width_list = [4096, 8192, 16384, 32768, 65536]
# width_list = [4096]
# width_list = [4096, 8192, 16384, 32768, 65536] # lc ll hll mrac mrb univmon

# sketch_list = ["cm", "cs"]
sketch_list = ["cm"]
level = 1
row = 3

# sketch_list = ["univmon"]
# level = 16
# row = 3

# sketch_list = ["mrac"]
# level = 8
# row = 1

# sketch_list = ["mrb"]
# level = 8
# row = 1

# sketch_list = ["lc", "ll", "hll"]
# level = 1
# row = 1

date_list = [20180816]
epoch_list = [10]
flowkey_list = ["srcIP", ]

# seed: 1 ~ 10
# seed_list = [1, 2, 3]
seed_list = [1]
# count packet or byte
is_count_packet = 1

# ### expiration of pcaps
pcap_count = 5
# pcap_file=["5_5.pcap", "10_0.pcap", "4_6.pcap", "3_7.pcap"]

cmd_list = []

# pcap_folder = "/home/ming/SketchMercator/pattern_detection/traffic_generator/training_pcap_file/"
# pcap_folder = "/home/ming/SketchMercator/pattern_detection/traffic_generator/scaled_pcap_file/"
# pcap_folder = "/home/ming/SketchMercator/pattern_detection/traffic_generator/pcap_file/"
# pcap_file = []
# for file_name in sorted(os.listdir(pcap_folder)):
#     if file_name.split('_')[1] == '5' or file_name.split("-")[0] == "zipf4" or file_name.split("_")[2].split("-")[0] == "zipf4":
#         # print(file_name)
#         continue
#     pcap_file.append(file_name)
    
# pcap_folder = "/home/ming/SketchMercator/pattern_detection/traffic_generator/scaled_pcap_file_new/"
pcap_folder = "/home/ming/SketchMercator/pattern_detection/traffic_generator/pcap_file_new/"
pcap_file = []
for file_name in sorted(os.listdir(pcap_folder)):
    # if file_name.split('_')[0].split("-")[0] == file_name.split('_')[2].split("-")[0]:
    #     pcap_file.append(file_name)
    pcap_file.append(file_name)
    
    

# print(pcap_file)
    
run_online_traffic(folder_path=pcap_folder, pcap_file=pcap_file,
                   flowkey_list=flowkey_list, width_list=width_list, epoch_list=epoch_list, seed_list=seed_list,
                   sketch_list=sketch_list, level=level, row=row, is_count_packet=is_count_packet, lcount=0, cmd_list=cmd_list)


print(cmd_list[0])


from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 20)


