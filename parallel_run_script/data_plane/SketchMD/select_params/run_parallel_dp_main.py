import os

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

# sketch_name = "univmon"
# sketch_name = "cs"
# sketch_name = "hll"
# sketch_name = "cm"

# Key1 = [SRCIP]
# Key2 = [SRCIP, SRCPORT]
# Key3 = [DSTPORT]
# Key4 = [DSTIP, DSTPORT]
# Key5 = [DSTIP]
# Key6 = [SRCIP, DSTIP]
# Key7 = [SRCIP, DSTIP, SRCPORT, DSTPORT]
# Key8 = [SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO]


sketch_list = ["gt", "cm", "hll", "pcsa"]
# sketch_list = ["gt", "cm", "hll"]
# sketch_list = ["hll"]

# date_list = [20140320, 20140619, 20160121, 20180517, 20180816]
date_list = [20140320, 20160121, 20180816]

# width_list = [1024, 2048, 4096, 8192, 16384]
width_list = [32768, 65536]

# epoch_list = [10, 20, 30, 40]
epoch_list = [10, 30]

# flowkey_list = ["srcIP",
#                 "srcIP,srcPort",
#                 "dstPort",
#                 "dstIP,dstPort",
#                 "dstIP",
#                 "srcIP,dstIP",
#                 "srcIP,dstIP,srcPort,dstPort",
#                 "srcIP,dstIP,srcPort,dstPort,proto",
#                 ]

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
                        print(pcap_full_path, width, flowkey, epoch, sketch_name)
                        lcount += 1

                        str = f"width_{width}_epoch_{epoch}"
                        print(str)
                        output_dir = os.path.join(result_sw_dp_path, "SketchMD", sketch_name, pcap_file_name, flowkey, str)
                        print(output_dir)

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

                        log_template)
                        cmd_list.append(cmd)


print(lcount)


for cmd in cmd_list:
    print(cmd)
    print()
print(len(cmd_list))

# # print(len(cmd_list))
# # # print(cmd_list[:1])

# from python_lib.run_parallel_helper import run_cmd_list
# run_cmd_list(cmd_list, 70)

# run_cmd_list(cmd_list[0:1], 50)
# run_cmd_list(cmd_list[1:2], 50)
# run_cmd_list(cmd_list[0:1], 50)
# run_cmd_list(cmd_list[3:4], 32)

