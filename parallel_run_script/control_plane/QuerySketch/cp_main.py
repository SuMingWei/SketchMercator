from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from parallel_run_script.control_plane.SketchMD.lib import counter_read, hf_read
from sketch_control_plane.SketchMD.analysis_main import analysis_main

import os

program_name_dict = {}

program_name_dict["workload_1"] = {}
program_name_dict["workload_1"]["before"] = "p416_workload_1_06_07_before_5_hash_1_tofino1"
program_name_dict["workload_1"]["after"] = "p416_workload_1_06_07_after_5_hash_1_tofino1"

program_name_dict["workload_2"] = {}
program_name_dict["workload_2"]["before"] = "p416_workload_2_10_11_before_1_hash_1_tofino1"
program_name_dict["workload_2"]["after"] = "p416_workload_2_10_11_after_1_hash_1_tofino1"

program_name_dict["workload_3"] = {}
program_name_dict["workload_3"]["before"] = "p416_workload_3_10_11_before_1_hash_1_tofino1"
program_name_dict["workload_3"]["after"] = "p416_workload_3_10_11_after_1_hash_1_tofino1"

program_name_dict["workload_4"] = {}
program_name_dict["workload_4"]["before"] = "p416_workload_4_10_11_before_1_hash_1_tofino1"
program_name_dict["workload_4"]["after"]  = "p416_workload_4_10_11_after_1_hash_1_tofino1"



from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(60)


def parallel_run(program_name_dict, workload_name, pcap_file_name, bf, caida_date):
    program_name = program_name_dict[workload_name][bf]

    metadata = (workload_name, bf, program_name, pcap_file_name)
    print(metadata)
    # if pcap_file_name == "equinix-sanjose.dirA.20140320-130600.UTC.anon.pcap":
    #     return
    counter_data, gt_path_dict = counter_read(metadata)
    hf_data = hf_read(metadata)
    # hf_data = []

    # print(len(hf_data))
    # for k, v in hf_data.items():
    #     print("[%s] %d" % (k, len(v)))
    #     # for flowkey in v:
    #     #     print(flowkey)
    #     print()
    #     print()
    #     # break
    # exit(1)

    # analysis_main(metadata, counter_data, gt_path_dict, hf_data, caida_date)
    print()
    # exit(1)

# for caida_date in ["20140320", "20140619", "20160121", "20180517", "20180816"]:
for caida_date in ["20180816"]:
    
    ret_list = get_pcap_list_by_date_and_count(caida_date, "60s", 10)
    for workload_name in ["workload_4"]:
    # for workload_name in ["workload_1", "workload_2", "workload_3", "workload_4"]:
        # for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
        for (pcap_full_path, pcap_folder_path, pcap_file_name) in [ret_list[8]]:
            # for bf in ["before", "after"]:
            # for bf in ["after"]:
            for bf in ["before"]:
                # parallel_run(program_name_dict, workload_name, pcap_file_name, bf, caida_date)
                helper.call(parallel_run, (program_name_dict, workload_name, pcap_file_name, bf, caida_date, ))
