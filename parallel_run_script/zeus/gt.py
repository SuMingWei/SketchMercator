from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

import os

def common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount):

    log_template = "[%d] [%s] [%s] " % (lcount, sketch_name, mode) + "width(%d)_depth(%d)_level(%d)_epoch(%d)_pcap(%s) " % (width, depth, level, epoch, pcap_file_name)

    cmd =  "%s/main " % sw_dp_simulator_path
    cmd += "-f %s " % pcap_full_path
    cmd += "-n %s " % pcap_file_name
    cmd += "-r '%s' " % sketch_name
    cmd += "-c " # is_crc_hash=1
    cmd += "-h " # is_same_level_hash=1
    cmd += "-m " # is_compact_hash=1
    cmd += "-u " # is_update_last_level=1
    cmd += "-p 1 "
    cmd += "-k 'srcIP' "
    cmd += "-w %d " % width
    cmd += "-d %d " % depth
    cmd += "-l %d " % level
    cmd += "-e %d " % epoch
    cmd += "-b 0 "
    cmd += "-a 0,0,0,0 "
    cmd += "-z '%s' " % log_template
    # cmd += "-g %s " % pcounter_path
    cmd += "-o %s " % output_dir
    return cmd

# sketch_name = "univmon"

pcap_input_folder = os.path.join(pcap_storage_path, "zeus", "syn")
print(pcap_input_folder) # /data1/hun/sketch_home/pcap_storage/zeus/syn

file_list = []
for file_name in sorted(os.listdir(pcap_input_folder)):
    if file_name.endswith(".pcap"):
        if file_name != "small.pcap":
            file_list.append(file_name)
print(file_list)

for file_name in file_list[1:]:
    pcap_full_path = os.path.join(pcap_input_folder, file_name)
    pcap_file_name = file_name
    sketch_name = "gt"
    width = 2048
    depth = 5
    level = 16
    epoch = 1
    pcounter_path = ""
    output_dir = os.path.join(result_gt_path, "zeus", "syn", pcap_file_name)
    mode = "normal"
    lcount = 0
    cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount)
    print(cmd)
    os.system(cmd)





# file_name = "small.pcap"
# pcap_full_path
# pcap_full_path
# cmd = common_cmd()
