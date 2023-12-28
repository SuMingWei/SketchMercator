import os
import argparse

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path
from env_setting.env_module import result_cp_path


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



# sketch_list = ["lc", "hll", "ll"]
sketch_list = ["mrac", "mrb"]
# sketch_list = ["cm", "cs"]
# sketch_list = ["univmon"]
width_list = [32768, 65536, 131072, 262144, 524288]
# date_list = [20180517, 20180621, 20180816, 20181018, 20181115, 20181220]
date_list = [20180816]
# date_list = [20180517]

epoch_list = [30]
# epoch_list = [10, 20, 30]

# flowkey_list = [
#                 "srcIP,srcPort",
#                 "dstIP,dstPort",
#                 ]
flowkey_list = ["srcIP", ]


# level = 16
level = 8
# level = 1
row = 1
# how many rows I really measure on sketch (calculate in control plane)
# It only works on Count-Min/Count sketch
actual_row = row
# actual_row = 1

# seed: 1 ~ 10
seed_list = [1, 2, 3]
# count packet or byte
is_count_packet = 1


# pcap_count = 3
# pcap_count = 1


# ### expiration of pcaps
dataset_category = 'online_traffic/'
pcap_count = 1


##### read arguments from the milind's solutions if needed
args = get_parse()
if args.sketch:
    sketch_list = [args.sketch]
if args.row:
    row = int(args.row)
    actual_row = args.row
if args.width:
    width_list = [int(args.width)]
if args.level:
    level = int(args.level)


lcount = 0

from python_lib.run_parallel_helper import ParallelRunHelper
# number of processes in parallel
helper = ParallelRunHelper(30)

for date in date_list:  # 5
    pcap_list = get_online_traffic_pcap_list(date, "60s", pcap_count, dataset_category)
    for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
        for flowkey in flowkey_list:
            for width in width_list:
                for epoch in epoch_list:
                    for seed in seed_list:
                        for sketch_name in sketch_list:
                            # print(pcap_full_path, width, flowkey, epoch, sketch_name)
                            str = f"row_{row}_width_{width}_level_{level}_epoch_{epoch}_count_{is_count_packet}_seed_{seed}"
                            # print(str)
                            output_dir = os.path.join(result_sw_dp_path, "QueryOnlineSketch", sketch_name, pcap_file_name, flowkey, str)
                            print(output_dir)

                            str = f"row_{actual_row}_width_{width}_level_{level}_epoch_{epoch}_count_{is_count_packet}_seed_{seed}"
                            output_pkl_dir = os.path.join(result_cp_path, "QueryOnlineSketch", sketch_name, pcap_file_name, flowkey, str)
                            print(output_pkl_dir)
                            from sketch_control_plane.QuerySketch.select_params.sketch_cp_main import sketch_cp
                            helper.call(sketch_cp, (sketch_name, output_dir, output_pkl_dir, row, width, level, actual_row, ))

                            print()

                            lcount += 1
print(lcount)