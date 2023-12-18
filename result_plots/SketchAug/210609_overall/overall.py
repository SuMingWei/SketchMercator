from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
from python_lib.hun_timer import hun_timer

from parallel_run_script.data_plane.cmd import mrb_cmd, hll_cmd, cs_cmd, cm_cmd, univmon_cmd

from sketch_control_plane.main import sketch_cp
import importlib

from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path
from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path, get_tofino_path
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_with_hash_name
from python_lib.pkl_saver import PklSaver
from statistics import median
from pcap_sender.SketchAug.configs.load import load_param_list


from time import sleep
API="cpp"


def get_path(pcap_file_name, sketch_name, mode, array_size, epoch):
    API = "cpp"
    if sketch_name == "mrb":
        width = array_size/16
        depth = 1
        level = 16
    if sketch_name == "hll":
        width = array_size
        depth = 1
        level = 1
    if sketch_name == "cs":
        width = array_size
        depth = 4
        level = 1
    if sketch_name == "cm":
        width = array_size
        depth = 4
        level = 1
    if sketch_name == "univmon":
        width = array_size/16
        depth = 4
        level = 16
    
    pkl_path = sketch_cp_path(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, hash_set_num=1)
    
    return pkl_path

def sketch_cp(file_name, sketch_name, mode, array_size, epoch):
    API = "cpp"
    pkl_path = get_path(file_name, sketch_name, mode, array_size, epoch)
    # print(pkl_path)
    saver = PklSaver(pkl_path, "data.pkl")
    load_data = saver.load()
    # print(len(load_data))
    data = []
    if sketch_name == "cm":
        sim_error_list = []
        tofino_error_list = []
        for (wrong, sum, sim_error, tofino_error, diff_percent) in load_data:
            sim_error_list.append(sim_error)
            tofino_error_list.append(tofino_error)
            data.append(sum)

        sim_error = median(sim_error_list)
        tofino_error = median(tofino_error_list)

        error_increase = (tofino_error - sim_error) / sim_error * 100

        print("wrong(%d) sim_error(%.2f) tofino_error(%.2f) error_increase(%.2f)" % 
            (int(median(data)), sim_error, tofino_error, error_increase))
    else:
        sim_error_list = []
        tofino_error_list = []
        for (wrong, sum, true_cardinality, sim_cardinality, sim_error, tofino_cardinality, tofino_error, diff_percent) in load_data:
            sim_error_list.append(sim_error)
            tofino_error_list.append(tofino_error)
            data.append(sum)

        sim_error = median(sim_error_list)
        tofino_error = median(tofino_error_list)

        error_increase = (tofino_error - sim_error) / sim_error * 100

        print("wrong(%d) sim_error(%.2f) tofino_error(%.2f) error_increase(%.2f)" % 
            (int(median(data)), sim_error, tofino_error, error_increase))

    # new_array_size = array_size
    # if sketch_name == "cs" 

    # print(array_size)
    # print()

    # if 

    return data

pcap_file_name_list = ["equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"]

def cp_main_start(sketch_name, mode, epoch, array_size):
    pcap_list = get_pcap_list_by_date_and_count(20160121, "60s", 1)
    for file_name in pcap_file_name_list:
        print("sketch_name(%s) mode(%s) epoch(%d) array_size(%d) pcap(%s)" % (sketch_name, mode, epoch, array_size, file_name))

        sketch_cp(file_name, sketch_name, mode, array_size, epoch)
        # sketch_cp(file_name, sketch_name, mode, array_size, epoch)

sketch_list = ["mrb", "hll", "cs", "cm", "univmon"]
mode_list = ["baseline", "pingpong", "noreset", "sol3"]

def main():
    cmd_list = []
    for sketch_name in sketch_list:
        for mode in mode_list:
            epoch_list, array_size_list = load_param_list(sketch_name, mode)
            for epoch in epoch_list:
                for array_size in array_size_list:
                    if sketch_name == "mrb":
                        if epoch != 1:
                            continue
                        if array_size != 65536:
                            continue
                    # print("sketch_name(%s) mode(%s) epoch(%d) array_size(%d)" % (sketch_name, mode, epoch, array_size))
                    cp_main_start(sketch_name, mode, epoch, array_size)
        print()


if __name__=="__main__":
   main()
