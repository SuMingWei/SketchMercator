import os
import sys
import argparse

from python_lib.pkl_saver import PklSaver
from lib.logging import print_msg

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--output', type=str)
argparser.add_argument('--result', type=str)
args = argparser.parse_args()

# from result_analysis.data_parse import *

from result_analysis.lib.data_process import *

def run_analysis(output_folder, result_folder, pkl_name):
    output_data = data_read(output_folder, pkl_name)

    data = {}
    data["time"] = data_parse_time(output_data)
    df_list, mean_df = data_parse_breakdown(output_data)
    data["df_list"] = df_list
    data["mean_df"] = mean_df
    out_saver = PklSaver(result_folder, pkl_name)
    out_saver.save(data)
    # print(mean_df)


def run_analysis_folder(output_folder, result_folder):
    global helper
    for pkl_name in sorted(os.listdir(output_folder)):
        if ".pkl" in pkl_name:
            print(output_folder, pkl_name)
            # run_analysis(output_folder, result_folder, pkl_name)
            # exit(1)
            # exit(1)
            # if "workload" in output_folder:
                # print(output_folder, pkl_name)
            # run_analysis(output_folder, result_folder, pkl_name)
            helper.call(run_analysis, (output_folder, result_folder, pkl_name, ))


for workload_name in sorted(os.listdir(args.output)):
    print(workload_name)
    from sketchmd_strategy.lib.logging import SELECT_MODE, NORMAL_MODE, TESTCASE_MODE
    # if SELECT_MODE == TESTCASE_MODE:
    #     if workload_name != "workload_testcase":
    #         continue
    # if workload_name.startswith("workload"):
    for run_name in ["gd"]:
    # for run_name in ["bf"]:
    # for run_name in ["bf", "gd"]:
        if run_name == "gd":
            output_folder = os.path.join(args.output, workload_name, run_name)
            for timeout_name in sorted(os.listdir(output_folder)):
                if "_" in timeout_name and timeout_name == "5_5":
                    output_folder = os.path.join(args.output, workload_name, run_name, timeout_name)
                    result_folder = os.path.join(args.result, workload_name, run_name, timeout_name)
                    run_analysis_folder(output_folder, result_folder)
                    # exit(1)
        else:
            output_folder = os.path.join(args.output, workload_name, run_name)
            result_folder = os.path.join(args.result, workload_name, run_name)
            run_analysis_folder(output_folder, result_folder)
    # break
