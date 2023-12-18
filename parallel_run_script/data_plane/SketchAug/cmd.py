from env_setting.env_module import sw_dp_simulator_path

from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path, read_pcounter
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_input

from parallel_run_script.data_plane.common.common import general_cmd

import os


def common_cmd(pcap_full_path,
               pcap_file_name,

               sketch_name,

               width,
               depth,
               level,

               epoch,
               pcounter_path,
               output_dir,

               mode,
               lcount):

    log_template = "[%d] [%s] [%s] " % (lcount, sketch_name, mode) + "width(%d)_depth(%d)_level(%d)_epoch(%d)_pcap(%s) " % (width, depth, level, epoch, pcap_file_name)

    cmd = general_cmd(pcap_full_path,
               pcap_file_name,

               sketch_name,

               "srcIP",

               width,
               depth,
               level,

               True,
               True,
               True,
               True,

               epoch,
               output_dir,
               pcounter_path,
               10000,
               1,

               log_template)


    # cmd =  "%s/main " % sw_dp_simulator_path
    # cmd += "-f %s " % pcap_full_path
    # cmd += "-n %s " % pcap_file_name
    # cmd += "-r '%s' " % sketch_name
    # cmd += "-c " # is_crc_hash=1
    # cmd += "-h " # is_same_level_hash=1
    # cmd += "-m " # is_compact_hash=1
    # cmd += "-u " # is_update_last_level=1
    # cmd += "-p 1 "
    # cmd += "-k 'srcIP' "
    # cmd += "-w %d " % width
    # cmd += "-d %d " % depth
    # cmd += "-l %d " % level
    # cmd += "-e %d " % epoch
    # cmd += "-z '%s' " % log_template
    # cmd += "-g %s " % pcounter_path
    # cmd += "-o %s " % output_dir

    # print(output_dir)
    # print(pcounter_path)
    # specific_folder_path = os.path.join(output_dir, "01.txt", "%02d" % (60/epoch))
    # if os.path.isdir(specific_folder_path):
    #     print("folder exist")
    #     return None
    # else:
    #     # pcount_path = os.path.join(output_dir, "01.txt", "pcounts.txt")
    #     if os.path.isfile(pcounter_path) == False:
    #         return None
    # print(specific_folder_path)
    # print(pcap_file_name)
    # exit(1)

    # counter = read_pcounter(pcounter_path)
    # # print(pcounter_path)
    # # print(counter[1])
    # if counter[1] == 0:
    #     print(pcounter_path)
    #     # print(60/epoch+5)
    #     for c in counter[0:(int(60/epoch)+5)]:
    #         print(c)
    # # exit(1)

    return cmd

def mrb_cmd(pcap_full_path, pcap_file_name, sketch_name, mode, array_size, epoch, date, lcount):

    API = "cpp"
    width = array_size/16
    depth = 1
    level = 16

    pcounter_path = get_pcounter_path(sketch_name, mode, API, array_size, epoch, pcap_file_name, date)
    output_dir = sw_dp_path_input(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount)
    return cmd

def hll_cmd(pcap_full_path, pcap_file_name, sketch_name, mode, array_size, epoch, date, lcount):

    API = "cpp"
    width = array_size
    depth = 1
    level = 1

    pcounter_path = get_pcounter_path(sketch_name, mode, API, array_size, epoch, pcap_file_name, date)
    output_dir = sw_dp_path_input(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    
    cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount)
    return cmd

def cs_cmd(pcap_full_path, pcap_file_name, sketch_name, mode, array_size, epoch, date, lcount):

    API = "cpp"
    width = array_size
    depth = 4
    level = 1

    pcounter_path = get_pcounter_path(sketch_name, mode, API, array_size, epoch, pcap_file_name, date)
    output_dir = sw_dp_path_input(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    
    cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount)
    return cmd

def cm_cmd(pcap_full_path, pcap_file_name, sketch_name, mode, array_size, epoch, date, lcount):

    API = "cpp"
    width = array_size
    depth = 4
    level = 1

    pcounter_path = get_pcounter_path(sketch_name, mode, API, array_size, epoch, pcap_file_name, date)
    output_dir = sw_dp_path_input(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    
    cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount)
    return cmd

def univmon_cmd(pcap_full_path, pcap_file_name, sketch_name, mode, array_size, epoch, date, lcount):

    API = "cpp"
    width = array_size/16
    depth = 4
    level = 16

    pcounter_path = get_pcounter_path(sketch_name, mode, API, array_size, epoch, pcap_file_name, date)
    output_dir = sw_dp_path_input(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    
    cmd = common_cmd(pcap_full_path, pcap_file_name, sketch_name, width, depth, level, epoch, pcounter_path, output_dir, mode, lcount)
    return cmd

