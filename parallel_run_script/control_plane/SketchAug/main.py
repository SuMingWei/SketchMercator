from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
from data_helper.data_path_helper.tofino_dp_path_helper import get_date_list
from python_lib.hun_timer import hun_timer

from parallel_run_script.data_plane.cmd import mrb_cmd, hll_cmd, cs_cmd, cm_cmd, univmon_cmd

from sketch_control_plane.main import sketch_cp
import importlib

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(32)
from pcap_sender.SketchAug.configs.load import load_param_list

from time import sleep
API="cpp"
import traceback
gcount = 0

def cp_main_start(sketch_name, mode, epoch, array_size):
    global gcount
    pcap_list = get_pcap_list_by_date_and_count(20160121, "60s", 100)
    for (full_path, folder_path, file_name) in pcap_list:
        # if (("univ" in file_name)) == False:
        #     continue
        # if (("ccdc" in file_name)) == False:
        #     continue
        if (("univ" in file_name) or ("ccdc" in file_name)) == True:
            continue
        try:
            date_list = get_date_list(sketch_name, mode, API, array_size, epoch, file_name)
            for date in date_list:
                gcount+=1
                print("gcount(%d) sketch_name(%s) mode(%s) epoch(%d) array_size(%d) pcap(%s) date(%s)" % (gcount, sketch_name, mode, epoch, array_size, file_name, date))
                # sketch_cp(file_name, sketch_name, mode, array_size, epoch, date)
                # exit(1)

                helper.call(sketch_cp, (file_name, sketch_name, mode, array_size, epoch, date, ))
                # exit(1)

                break
        except Exception as e:
            print("except")
            traceback.print_exc()
            exit(1)
            

sketch_list = ["mrb", "hll", "cs", "cm", "univmon"]
# sketch_list = ["hll", "cs", "cm", "univmon"]
# sketch_list = ["hll"]
# sketch_list = ["cm"]
# sketch_list = ["univmon"]

# mode_list = ["baseline", "pingpong", "noreset", "sol3cpp"]
# mode_list = ["baseline", "noreset", "sol3cpp"]
# mode_list = ["pingpong", "sol3"]
# mode_list = ["baseline"]
mode_list = ["pingpong"]
# mode_list = ["sol3cpp"]

def main():
    count = 0
    for sketch_name in sketch_list:
        for mode in mode_list:
            epoch_list, array_size_dict = load_param_list(sketch_name, mode)
            if len(epoch_list) == 0:
                continue
            for epoch in epoch_list:
                for array_size in array_size_dict[epoch]:
                    count += 1
                    print("count(%d) sketch_name(%s) mode(%s) epoch(%d) array_size(%d)" % (count, sketch_name, mode, epoch, array_size))
                    cp_main_start(sketch_name, mode, epoch, array_size)
    # print(count)

if __name__=="__main__":
   main()
