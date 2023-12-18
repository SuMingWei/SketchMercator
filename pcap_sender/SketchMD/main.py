from pcap_sender.SketchMD.lib.com import *
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path, get_test_pcap_list_count
from python_lib.hun_timer import hun_timer

import importlib
import datetime

from time import sleep

from pcap_sender.SketchMD.config import BEFORE_AFTER


# for data set [2014, 2016, 2018]

# caida_date = "20160121"

# for caida_date in ["20140320", "20140619", "20160121", "20180517", "20180816"]:
for caida_date in ["20140619"]:
    ret_list = get_pcap_list_by_date_and_count(caida_date, "60s", 10)
    # ret_list = get_test_pcap_list_count("small_ether.pcap")
    # ret_list = get_test_pcap_list_count("8s.pcap")
    # ret_list = get_test_pcap_list_count("4s.pcap")


    program_name_dict = {}
    if BEFORE_AFTER == "before":
        program_name_dict["workload_1"] = [ ("p416_workload_1_06_07_before_5_hash_1_tofino1", "before") ]
        program_name_dict["workload_2"] = [ ("p416_workload_2_10_11_before_1_hash_1_tofino1", "before") ]
        program_name_dict["workload_3"] = [ ("p416_workload_3_10_11_before_1_hash_1_tofino1", "before") ]
        program_name_dict["workload_4"] = [ ("p416_workload_4_10_11_before_1_hash_1_tofino1", "before") ]

    if BEFORE_AFTER == "after":
        program_name_dict["workload_1"] = [ ("p416_workload_1_06_07_after_5_hash_1_tofino1", "after") ]
        program_name_dict["workload_2"] = [ ("p416_workload_2_10_11_after_1_hash_1_tofino1", "after") ]
        program_name_dict["workload_3"] = [ ("p416_workload_3_10_11_after_1_hash_1_tofino1", "after") ]
        program_name_dict["workload_4"] = [ ("p416_workload_4_10_11_after_1_hash_1_tofino1", "after") ]

    for workload_name in ["workload_4"]:
    # for workload_name in ["workload_2", "workload_3", "workload_4"]:
        for program_name, bf in program_name_dict[workload_name]:
            tuple1 = (workload_name, program_name, bf)

            # from pcap_sender.SketchMD.config import TOFINO_STR
            # from pcap_sender.SketchMD.lib.tcp import tcp_execute
            # tcp_execute("test/abc/abc", TOFINO_STR, "cpp", None)
            # exit(1)

            turn_on_switch_cpp(tuple1)
            hun_timer("turn_on_switch", 15)

            python_setup(tuple1, caida_date)
            hun_timer("python_setup", 5)

            for (pcap_full_path, pcap_folder_path, pcap_file_name) in [ret_list[3]]:
                # print(pcap_full_path)
                # exit(1)
                # if pcap_file_name != "equinix-sanjose.dirA.20140320-130200.UTC.anon.pcap":
                #     continue
                # if pcap_file_name != "equinix-sanjose.dirA.20140320-130600.UTC.anon.pcap" and pcap_file_name != "equinix-sanjose.dirA.20140320-130700.UTC.anon.pcap":
                #     continue
                # if pcap_file_name != "equinix-sanjose.dirA.20140320-130100.UTC.anon.pcap":
                #     continue
                # print(pcap_full_path)
                e_full_path, e_folder_path, e_file_name = convert_to_ether_path(pcap_full_path)
                date = datetime.datetime.now().strftime("%y%m%d_%H%M%S")

                tuple2 = (workload_name, program_name, bf, e_file_name, date)

                python_digest(tuple2, caida_date)
                hun_timer("python_digest", 5)

                send_msg_cpp_with_pcap("start", e_full_path, date)
                hun_timer("pcap_send", 70)

                turn_off_switch_python()
                hun_timer("python_turn_off", 5)

                python_epoch(tuple2, caida_date)
                hun_timer("python_epoch write", 5)
                # break

            turn_off_switch_cpp()
            hun_timer("turn_off_switch", 5)

            # # exit(1)
