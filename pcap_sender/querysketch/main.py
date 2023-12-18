from pcap_sender.querysketch.lib.com import *
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path, get_test_pcap_list_count, get_pcap_list_by_date_and_hour_list
from python_lib.hun_timer import hun_timer

import importlib
import datetime

from time import sleep

from pcap_sender.querysketch.config import BEFORE_AFTER

program_name_dict = {}

program_name_dict["workload_1"] = "p416_set1_ensemble1_01_before_0_tofino1"
program_name_dict["workload_2"] = "p416_set1_ensemble2_01_before_0_tofino1"
program_name_dict["workload_3"] = "p416_set1_ensemble3_01_before_0_tofino1"
program_name_dict["workload_4"] = "p416_set1_ensemble4_01_before_0_tofino1"
program_name_dict["workload_5"] = "p416_set1_ensemble5_01_before_0_tofino1"

for caida_date in ["20180517", "20180621", "20180816"]:
    ret_list = get_pcap_list_by_date_and_hour_list(caida_date, "60s", ["130900", "131000", "131100"])

    for ensemble_name in ["workload_1", "workload_2", "workload_3", "workload_4", "workload_5"]:
        tuple1 = (ensemble_name, program_name_dict[ensemble_name])

        turn_on_switch_cpp(tuple1)
        hun_timer("turn_on_switch", 40)

        python_setup(tuple1, caida_date)
        hun_timer("python_setup", 5)

        turn_off_switch_cpp()
        hun_timer("turn_off_switch", 5)
    break








        # for (pcap_full_path, pcap_folder_path, pcap_file_name) in [ret_list[3]]:
        #     # print(pcap_full_path)
        #     # exit(1)
        #     # if pcap_file_name != "equinix-sanjose.dirA.20140320-130200.UTC.anon.pcap":
        #     #     continue
        #     # if pcap_file_name != "equinix-sanjose.dirA.20140320-130600.UTC.anon.pcap" and pcap_file_name != "equinix-sanjose.dirA.20140320-130700.UTC.anon.pcap":
        #     #     continue
        #     # if pcap_file_name != "equinix-sanjose.dirA.20140320-130100.UTC.anon.pcap":
        #     #     continue
        #     # print(pcap_full_path)
        #     e_full_path, e_folder_path, e_file_name = convert_to_ether_path(pcap_full_path)
        #     date = datetime.datetime.now().strftime("%y%m%d_%H%M%S")

        #     tuple2 = (workload_name, program_name, bf, e_file_name, date)

        #     python_digest(tuple2, caida_date)
        #     hun_timer("python_digest", 5)

        #     send_msg_cpp_with_pcap("start", e_full_path, date)
        #     hun_timer("pcap_send", 70)

        #     turn_off_switch_python()
        #     hun_timer("python_turn_off", 5)

        #     python_epoch(tuple2, caida_date)
        #     hun_timer("python_epoch write", 5)
        #     # break


        # # # exit(1)
