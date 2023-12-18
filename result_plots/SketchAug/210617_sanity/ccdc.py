pcap_file_name_list = ["ccdc_01.pcap",
                       "ccdc_02.pcap",
                       "ccdc_03.pcap",
                       "ccdc_04.pcap",
                       "ccdc_05.pcap"]

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
from python_lib.hun_timer import hun_timer

from parallel_run_script.data_plane.cmd import mrb_cmd, hll_cmd, cs_cmd, cm_cmd, univmon_cmd

# from sketch_control_plane.main import sketch_cp
import importlib

from data_helper.data_path_helper.tofino_dp_path_helper import get_date_list
from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path
from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path, get_tofino_path
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_with_hash_name
from python_lib.pkl_saver import PklSaver
from statistics import median
import os
from pcap_sender.SketchAug.configs.load import load_param_list

from time import sleep
API="cpp"


def get_path(pcap_file_name, sketch_name, mode, array_size, epoch, date):
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
    
    pkl_path = sketch_cp_path(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date, hash_set_num=1)
    
    return pkl_path



global_sim_error_list = []
result_dict = {}
result_dict_across_pcap = {}


def sketch_cp(file_name, sketch_name, mode, array_size, epoch):
    global global_sim_error_list
    global result_dict
    global result_dict_across_pcap
    API = "cpp"
    date_list = get_date_list(sketch_name, mode, API, array_size, epoch, file_name)
    tofino_error_list = []
    sim_error_list = []
    wrong_sum_list = []
    wrong_count_list = []
    total_array_size_p = 0
    # print(date_list)
    count = 0
    for date in date_list:

        pkl_path = get_path(file_name, sketch_name, mode, array_size, epoch, date)
        print(pkl_path)
        if os.path.isfile(os.path.join(pkl_path, "data.pkl")) == False:
            continue

        saver = PklSaver(pkl_path, "data.pkl")
        load_data = saver.load()
        # print(pkl_path)
        # print(len(load_data))

        for tuple_data in load_data:
            if sketch_name == "cm":
                (wrong_count, wrong_sum, total_array_size, sim_error, tofino_error) = tuple_data
            elif sketch_name == "cs":
                (wrong_count, wrong_sum, total_array_size, true, sim, sim_error, tofino, tofino_error, sim_ARE_error, tofino_ARE_error) = tuple_data
                sim_error = sim_ARE_error
                tofino_error = tofino_ARE_error
            else:
                (wrong_count, wrong_sum, total_array_size, true, sim, sim_error, tofino, tofino_error) = tuple_data
            if total_array_size == 0:
                continue
            # print(tuple_data)
            sim_error_list.append(sim_error)
            global_sim_error_list.append(sim_error)
            tofino_error_list.append(tofino_error)
            wrong_sum_list.append(wrong_sum)
            wrong_count_list.append(wrong_count)
            total_array_size_p = total_array_size

            result_dict_across_pcap[sketch_name][mode]["tofino_error"].append(tofino_error)
            result_dict_across_pcap[sketch_name][mode]["wrong_sum"].append(wrong_sum)
            result_dict_across_pcap[sketch_name][mode]["diff_rate"].append(wrong_count/total_array_size*100)

        count+=1
        if count >= 1:
            break
    if len(tofino_error_list) == 0:
        return
    tofino_error = median(tofino_error_list)
    sim_error = median(sim_error_list)
    wrong_sum = median(wrong_sum_list)
    wrong_count = median(wrong_count_list)
    # result_dict_across_pcap[sketch_name][mode]["tofino_error"].append(tofino_error)
    # result_dict_across_pcap[sketch_name][mode]["wrong_sum"].append(wrong_sum)
    # result_dict_across_pcap[sketch_name][mode]["diff_rate"].append(wrong_count/total_array_size*100)


    # print(total_array_size)
    print("%20s %20s %20s %20s" % (("sim_error(%.2f)" % sim_error),
                              ("tofino_error(%.2f)" % tofino_error),
                              ("wrong_sum(%d)" % wrong_sum),
                              ("diff_rate(%.2f)" % (wrong_count/total_array_size_p*100))))
    # print("count(%d) pcap(%s)" % (count, file_name))
    # print()
    # print("%30s %30s %30s" % ("sim_error(%.2f)" % sim_error))
    # print("sim_error(%.2f) tofino_error(%.2f) wrong_sum(%d)" % (sim_error, tofino_error, wrong_sum))
    # print("tofino_error(%.2f)" % (tofino_error))


def cp_main_start(sketch_name, mode, epoch, array_size):
    global result_dict
    global result_dict_across_pcap

    for file_name in pcap_file_name_list:
        # print("sketch_name(%s) mode(%s) epoch(%d) array_size(%d) pcap(%s)" % (sketch_name, mode, epoch, array_size, file_name))
        sketch_cp(file_name, sketch_name, mode, array_size, epoch)
    if len(result_dict_across_pcap[sketch_name][mode]["tofino_error"]) == 0:
        result_dict[sketch_name][mode]["tofino_error"] = 0
        result_dict[sketch_name][mode]["wrong_sum"] = 0
        result_dict[sketch_name][mode]["diff_rate"] = 0
    else:
        result_dict[sketch_name][mode]["tofino_error"] = median(result_dict_across_pcap[sketch_name][mode]["tofino_error"])
        result_dict[sketch_name][mode]["wrong_sum"] = median(result_dict_across_pcap[sketch_name][mode]["wrong_sum"])
        result_dict[sketch_name][mode]["diff_rate"] = median(result_dict_across_pcap[sketch_name][mode]["diff_rate"])

    tofino_error = result_dict[sketch_name][mode]["tofino_error"]
    wrong_sum = result_dict[sketch_name][mode]["wrong_sum"]
    diff_rate = result_dict[sketch_name][mode]["diff_rate"]

    print("%20s %20s %20s %20s" % ("[%s]" % mode, ("tofino_error(%.2f)" % tofino_error),
                              ("wrong_sum(%d)" % wrong_sum),
                              ("diff_rate(%.2f)" % diff_rate)))

    print()

sketch_list = ["mrb", "hll", "cs", "cm", "univmon"]
mode_list = ["baseline", "pingpong", "noreset", "sol3cpp"]

def main():

    global global_sim_error_list
    global result_dict

    sim_error_list = []
    cmd_list = []
    for sketch_name in sketch_list:
        result_dict[sketch_name] = {}
        result_dict_across_pcap[sketch_name] = {}
        print("sketch name [%s]" % sketch_name)
        for mode in mode_list:
            if mode == "noreset" and sketch_name=="mrb":
                continue
            if mode == "noreset" and sketch_name=="hll":
                continue
            print("mode [%s]" % mode)
            result_dict[sketch_name][mode] = {}
            result_dict_across_pcap[sketch_name][mode] = {}
            result_dict_across_pcap[sketch_name][mode]["tofino_error"] = []
            result_dict_across_pcap[sketch_name][mode]["wrong_sum"] = []
            result_dict_across_pcap[sketch_name][mode]["diff_rate"] = []

            epoch = 1
            if sketch_name == "cs" or sketch_name == "cm":
                array_size = 16384
            elif sketch_name == "univmon":
                array_size = 32768
            elif sketch_name == "mrb":
                array_size = 65536
            elif sketch_name == "hll":
                array_size = 4096

            # if 
            # epoch_list, array_size_list = load_param_list(sketch_name, mode)
            # for epoch in epoch_list:
            #     for array_size in array_size_list:
            cp_main_start(sketch_name, mode, epoch, array_size)
        if len(global_sim_error_list) == 0:
            sim_error = 0
        else:
            sim_error = median(global_sim_error_list)
        sim_error_list.append(sim_error)
        print("sim_error(%.2f)" % (sim_error))
        print()
        print()
        global_sim_error_list = []


        print()
    print("\\textbf{\\unoptshort} & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% \\\\ \\hline" %
                                          (result_dict["mrb"]["baseline"]["wrong_sum"],
                                          result_dict["mrb"]["baseline"]["diff_rate"],
                                          result_dict["hll"]["baseline"]["wrong_sum"],
                                          result_dict["hll"]["baseline"]["diff_rate"],
                                          result_dict["cs"]["baseline"]["wrong_sum"],
                                          result_dict["cs"]["baseline"]["diff_rate"],
                                          result_dict["cm"]["baseline"]["wrong_sum"],
                                          result_dict["cm"]["baseline"]["diff_rate"],
                                          result_dict["univmon"]["baseline"]["wrong_sum"],
                                          result_dict["univmon"]["baseline"]["diff_rate"],
        ))

    print("\\textbf{\\evalsoloneshort} & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% \\\\ " %
                                          (result_dict["mrb"]["pingpong"]["wrong_sum"],
                                          result_dict["mrb"]["pingpong"]["diff_rate"],
                                          result_dict["hll"]["pingpong"]["wrong_sum"],
                                          result_dict["hll"]["pingpong"]["diff_rate"],
                                          result_dict["cs"]["pingpong"]["wrong_sum"],
                                          result_dict["cs"]["pingpong"]["diff_rate"],
                                          result_dict["cm"]["pingpong"]["wrong_sum"],
                                          result_dict["cm"]["pingpong"]["diff_rate"],
                                          result_dict["univmon"]["pingpong"]["wrong_sum"],
                                          result_dict["univmon"]["pingpong"]["diff_rate"],
        ))

    print("\\textbf{\\evalsoltwoshort} & $\\times$ & $\\times$ & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% \\\\ " %
                                          (result_dict["cs"]["noreset"]["wrong_sum"],
                                          result_dict["cs"]["noreset"]["diff_rate"],
                                          result_dict["cm"]["noreset"]["wrong_sum"],
                                          result_dict["cm"]["noreset"]["diff_rate"],
                                          result_dict["univmon"]["noreset"]["wrong_sum"],
                                          result_dict["univmon"]["noreset"]["diff_rate"],
        ))

    print("\\textbf{\\evalsolthreeshort} & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% & %d/%.0f\\%% \\\\ \\bottomrule" %
                                          (result_dict["mrb"]["sol3cpp"]["wrong_sum"],
                                          result_dict["mrb"]["sol3cpp"]["diff_rate"],
                                          result_dict["hll"]["sol3cpp"]["wrong_sum"],
                                          result_dict["hll"]["sol3cpp"]["diff_rate"],
                                          result_dict["cs"]["sol3cpp"]["wrong_sum"],
                                          result_dict["cs"]["sol3cpp"]["diff_rate"],
                                          result_dict["cm"]["sol3cpp"]["wrong_sum"],
                                          result_dict["cm"]["sol3cpp"]["diff_rate"],
                                          result_dict["univmon"]["sol3cpp"]["wrong_sum"],
                                          result_dict["univmon"]["sol3cpp"]["diff_rate"],
        ))

    print()
    print()

    print_str_1 = "\\begin{tabular}[c]{@{}c@{}}\\textbf{Expected}\\\\ \\textbf{Errors}\\end{tabular} & \\begin{tabular}[c]{@{}c@{}}\\textbf{ideal}\\\\ \\textbf{sketch}\\end{tabular} &"
    print_str_2 = "\\multirow{4}{*}{\\begin{tabular}[c]{@{}c@{}}\\textbf{Actual}\\\\ \\textbf{Errors}\\end{tabular}} & \\textbf{\\unoptshort} &"
    print("%s %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% \\\\ \\hline" %
                                          (print_str_1, sim_error_list[0], sim_error_list[1], sim_error_list[2], sim_error_list[3], sim_error_list[4] 
                                          ))

    print("%s %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% \\\\ " %
                                          (print_str_2,
                                            result_dict["mrb"]["baseline"]["tofino_error"],
                                          result_dict["hll"]["baseline"]["tofino_error"],
                                          result_dict["cs"]["baseline"]["tofino_error"],
                                          result_dict["cm"]["baseline"]["tofino_error"],
                                          result_dict["univmon"]["baseline"]["tofino_error"]
                                          ))
    print("& \\textbf{\\evalsoloneshort} & %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% \\\\ " %
                                          (result_dict["mrb"]["pingpong"]["tofino_error"],
                                          result_dict["hll"]["pingpong"]["tofino_error"],
                                          result_dict["cs"]["pingpong"]["tofino_error"],
                                          result_dict["cm"]["pingpong"]["tofino_error"],
                                          result_dict["univmon"]["pingpong"]["tofino_error"]
                                          ))
    print("& \\textbf{\\evalsoltwoshort} & $\\times$ & $\\times$ & %.1f\\%% & %.1f\\%% & %.1f\\%% \\\\ " %
                                          (result_dict["cs"]["noreset"]["tofino_error"],
                                          result_dict["cm"]["noreset"]["tofino_error"],
                                          result_dict["univmon"]["noreset"]["tofino_error"]
                                          ))
    print("& \\textbf{\\evalsolthreeshort} & %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% & %.1f\\%% \\\\ \\bottomrule" %
                                          (result_dict["mrb"]["sol3cpp"]["tofino_error"],
                                          result_dict["hll"]["sol3cpp"]["tofino_error"],
                                          result_dict["cs"]["sol3cpp"]["tofino_error"],
                                          result_dict["cm"]["sol3cpp"]["tofino_error"],
                                          result_dict["univmon"]["sol3cpp"]["tofino_error"]
                                          ))




if __name__=="__main__":
   main()

