import os
import numpy as np

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count

def generate_dataset(pcap_folder_path, pcap_file, flowkey, pcap_count):
    # Iterate over pcap files and parse them
    cmd = "%s/traffic_generator/pcap_scaler " % os.getenv("pattern_detection")


    # Iterate over pcap files and parse them
    pcap_full_path = os.path.join(pcap_folder_path, pcap_file)
    
    for key in flowkey:
        cmd += key
        cmd += " "
        cmd += pcap_full_path
        cmd += " "

        print("[Run Pcap Generator] ", cmd)

        os.system(cmd)
    # # remove old file
    # old_sorted_pcap_path = os.getenv("traffic_sampler") + "/traffic_generator/synthetic.pcap"
    # if os.path.isfile(old_sorted_pcap_path):
    #     print("[Remove Exists File] ", old_sorted_pcap_path)
    #     os.remove(old_sorted_pcap_path)


if __name__ == "__main__":
    # sample sub-dataset from origin dataset
    pcap_folder_path = "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s-new"
    flowkey = ["srcIP"]
    pcap_count = 5

    pcap_file = "caida0816-500w.pcap"
    generate_dataset(pcap_folder_path, pcap_file, flowkey, pcap_count)
    # pcap_file = "zipf18-35w_10_.pcap"
    # generate_dataset(pcap_folder_path, pcap_file, flowkey, pcap_count)
    
