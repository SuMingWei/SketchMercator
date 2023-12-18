from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

import os

def common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, output_dir, threshold, lcount, seed):

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
    cmd += "-j %d " % seed
    cmd += "-o %s " % output_dir
    cmd += "-i %d " % threshold

    log_template = "[%d] [%s row_%d_level_%d_width_%d] " % (lcount, sketch_name, depth, level, width) + "pcap(%s) " % (pcap_file_name)
    cmd += "-z '%s' " % log_template


    return cmd