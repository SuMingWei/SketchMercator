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

# sketch_list = ["gt", "hll"]
sketch_list = ["univmon"]
# sketch_list = ["cm", "cs"]
width_list = [32768, 65536, 131072, 262144, 524288]
# width_list = [4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288]
# width_list = [512]
# width_list = [524288]
# level = 16
# row = 5

# sketch_list = ["mrb"]
# sketch_list = ["univmon"]
# sketch_list = ["mrac"]
# width_list = [1024, 2048, 4096, 8192, 16384, 32768, 65536]
# level = 1
level = 16
row = 3

### Common parameters
# date_list = [20180517, 20180621, 20180816, 20181018, 20181115, 20181220]
date_list = [20180816]
# date_list = [20181220]
# epoch_list = [10, 20, 30]
epoch_list = [30]


# flowkey_list = ["srcIP",
#                 "srcIP,srcPort",
#                 "dstPort",
#                 "dstIP,dstPort",
#                 "dstIP",
#                 "srcIP,dstIP",
#                 "srcIP,dstIP,srcPort,dstPort",
#                 "srcIP,dstIP,srcPort,dstPort,proto",
#                 ]

# flowkey_list = ["srcIP,srcPort", ]
flowkey_list = ["srcIP", ]
# flowkey_list = ["dstIP,dstPort", ]


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


# seed: 1 ~ 10
seed_list = [1, 2, 3]
# seed_list = [1, 2 ,3]
# count packet or byte
is_count_packet = 1


# pcap_count = 3

# dataset_category_list = ['caida', 'my_pcaps/fixFlowPkt/uniform-srcIP', 'my_pcaps/fixFlowPkt/zipf-1.1-srcIP', \
#                         'my_pcaps/fixFlowPkt/zipf-1.3-srcIP', 'my_pcaps/fixFlowPkt/zipf-1.5-srcIP']

### different distribution,fix number of flows & packets
# dataset_category_list = ['my_pcaps/fixFlowPkt/zipf-1.1-srcIP', \
#                         'my_pcaps/fixFlowPkt/uniform-srcIP']

### different number of flows
# dataset_category_list = ['my_pcaps/numberofFlow/zipf-1.1-srcIP', ]
## more resolutions
# dataset_category_list = ['my_pcaps/numberofFlow_2/zipf-1.1-srcIP', ]
# pcap_count = 9

# ### different number of Packets
# dataset_category_list = ['my_pcaps/numberofPkt/zipf-1.1-srcIP', ]
# pcap_count = 9


# ### expiration of pcaps
dataset_category_list = ['caida_specify_time/', ]
pcap_count = 5


lcount = 0

cmd_list = []
for dataset_category in dataset_category_list:
    for date in date_list:  # 5
        pcap_list = get_pcap_list_by_date_and_count(date, "60s", pcap_count, dataset_category)
        for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
            for flowkey in flowkey_list:
                for width in width_list:
                    for epoch in epoch_list:
                        for seed in seed_list:
                            for sketch_name in sketch_list:
                                print(pcap_full_path, width, flowkey, epoch, sketch_name)
                                lcount += 1

                                str = f"row_{row}_width_{width}_level_{level}_epoch_{epoch}_count_{is_count_packet}_seed_{seed}"
                                print(str)
                                output_dir = os.path.join(result_sw_dp_path, "QuerySketch", sketch_name, pcap_file_name, flowkey, str)
                                print("===output===: " + output_dir)

                                log_template = "[%d] [%s] [%s] [%s]" % (lcount, sketch_name, flowkey, str)

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
                                10000,
                                seed,

                                log_template,
                                is_count_packet)
                                cmd_list.append(cmd)


print(lcount)


# for cmd in cmd_list:
#     print(cmd)

# # print(len(cmd_list))
# # # print(cmd_list[:1])
print(cmd_list[0])
from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 30)

# run_cmd_list(cmd_list[0:1], 50)
# run_cmd_list(cmd_list[1:2], 50)
# run_cmd_list(cmd_list[0:1], 50)
# run_cmd_list(cmd_list[3:4], 32)

