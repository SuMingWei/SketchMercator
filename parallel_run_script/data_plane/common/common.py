from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

import os

def general_cmd(pcap_full_path,
                pcap_file_name,

                sketch_name,

                key,

                width,
                depth,
                level,

                is_crc_hash,
                is_same_level_hash,
                is_compact_hash,
                is_update_last_level,

                epoch,
                output_dir,
                pcounter_path,
                threshold,
                seed,

                log_template,

                p=1,
                hash_type=1):

    cmd =  "%s/main " % sw_dp_simulator_path

    cmd += "-f %s " % pcap_full_path
    cmd += "-n %s " % pcap_file_name
    cmd += "-r '%s' " % sketch_name

    cmd += "-w %d " % width
    cmd += "-d %d " % depth
    cmd += "-l %d " % level

    if is_crc_hash:
        cmd += "-c " # is_crc_hash=1
    if is_same_level_hash:
        cmd += "-h " # is_same_level_hash=1
    if is_compact_hash:
        cmd += "-m " # is_compact_hash=1
    if is_update_last_level:
        cmd += "-u " # is_update_last_level=1

    cmd += "-e %d " % epoch
    cmd += "-o %s " % output_dir
    if pcounter_path != None:
        cmd += "-g %s " % pcounter_path
    cmd += "-i %d " % threshold
    cmd += "-j %d " % seed

    cmd += "-p %d " % p
    cmd += "-k '%s' " % key

    cmd += "-z '%s' " % log_template

    cmd += "-a %d " % hash_type

    return cmd
