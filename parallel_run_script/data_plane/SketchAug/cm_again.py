from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
from data_helper.data_path_helper.tofino_dp_path_helper import get_date_list
from python_lib.hun_timer import hun_timer

from parallel_run_script.data_plane.SketchAug.cmd import mrb_cmd, hll_cmd, cs_cmd, cm_cmd, univmon_cmd

import importlib

from pcap_sender.SketchAug.configs.load import load_param_list

from time import sleep
API="cpp"
import traceback

def dp_main(sketch_name, mode, epoch, array_size, lcount):
    ret_list = []
    pcount = 0
    pcap_list = get_pcap_list_by_date_and_count(20160121, "60s", 100)
    # print(len(pcap_list))
    for (full_path, folder_path, file_name) in pcap_list:
        # if (("univ" in file_name) or ("ccdc" in file_name)) == False:
        #     continue
        if (("univ" in file_name) or ("ccdc" in file_name)) == True:
            continue
        # print(file_name)
        pcount += 1
        if pcount > 10:
            continue
        try:
            date_list = get_date_list(sketch_name, mode, API, array_size, epoch, file_name)
            for date in date_list:
                if sketch_name == "mrb":
                    cmd = mrb_cmd(full_path, file_name, sketch_name, mode, array_size, epoch, date, lcount)
                if sketch_name == "hll":
                    cmd = hll_cmd(full_path, file_name, sketch_name, mode, array_size, epoch, date, lcount)
                if sketch_name == "cs":
                    cmd = cs_cmd(full_path, file_name, sketch_name, mode, array_size, epoch, date, lcount)
                if sketch_name == "cm":
                    cmd = cm_cmd(full_path, file_name, sketch_name, mode, array_size, epoch, date, lcount)
                if sketch_name == "univmon":
                    cmd = univmon_cmd(full_path, file_name, sketch_name, mode, array_size, epoch, date, lcount)
                if cmd != None:
                    # print("sketch_name(%s) mode(%s) epoch(%d) array_size(%d) pcap(%s) date(%s)" % (sketch_name, mode, epoch, array_size, file_name, date))
                    ret_list.append(cmd)
                break
            # break
        except Exception as e:
            print("except")
            traceback.print_exc()

    return ret_list

# sketch_list = ["mrb", "hll", "cs", "cm"]
# sketch_list = ["univmon"]
# sketch_list = ["mrb"]
# sketch_list = ["hll"]
# sketch_list = ["cs"]
sketch_list = ["cm"]

# mode_list = ["baseline", "pingpong", "noreset", "sol3cpp"]
# mode_list = ["baseline", "pingpong", "noreset", "sol3cpp"]
# mode_list = ["pingpong"]
# mode_list = ["sol3cpp"]
mode_list = ["baseline"]

def main():
    lcount = 0
    cmd_list = []
    for sketch_name in sketch_list:
        for mode in mode_list:
            epoch_list, array_size_dict = load_param_list(sketch_name, mode)
            if len(epoch_list) == 0:
                continue
            # epoch_list = [30]
            for epoch in epoch_list:
                # if epoch != 1:
                #     continue
                for array_size in array_size_dict[epoch]:
                    lcount += 1
                    print("count(%d) sketch_name(%s) mode(%s) epoch(%d) array_size(%d)" % (lcount, sketch_name, mode, epoch, array_size))
                    ret_list = dp_main(sketch_name, mode, epoch, array_size, lcount)
                    # print(len(ret_list))
                    cmd_list += ret_list
                    # print(len(cmd_list))

    # for cmd in cmd_list[0:1]:
    #     print(cmd)
    # print(len(cmd_list))

    from python_lib.run_parallel_helper import run_cmd_list
    run_cmd_list(cmd_list, 70)


if __name__=="__main__":
   main()
