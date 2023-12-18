import os
import numpy as np

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count

def generate_dataset(data_list, dataset_category_list, flowkey, pcap_count, fs_dist_file):
    # Iterate over pcap files and parse them
    cmd = "%s/pcap_generator " % os.getenv("traffic_sampler")

    # Iterate over pcap files and parse them
    for dataset_category in dataset_category_list:
        for date in date_list:
            pcap_list = get_pcap_list_by_date_and_count(date, "60s", pcap_count, dataset_category)
            cmd += fs_dist_file
            cmd += " "
            for key in flowkey:
                cmd += key
                cmd += " "
                for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
                    # print(pcap_full_path, pcap_folder_path, pcap_file_name)
                    cmd += pcap_full_path
                    cmd += " "

            print("[Run Pcap Generator] ", cmd)
            
    # remove old file
    old_pcap_path = os.getenv("traffic_sampler") + "/syn.pcap"
    old_sorted_pcap_path = os.getenv("traffic_sampler") + "/sorted_syn.pcap"
    if os.path.isfile(old_pcap_path):
        print("[Remove Exists File] ", old_pcap_path)
        os.remove(old_pcap_path)
    if os.path.isfile(old_sorted_pcap_path):
        print("[Remove Exists File] ", old_sorted_pcap_path)
        os.remove(old_sorted_pcap_path)
    os.system(cmd)

if __name__ == "__main__":
    # sample sub-dataset from origin dataset
    date_list = [20180816]
    dataset_category_list = ["caida_specify_time/", ]
    flowkey = ["srcIP"]
    pcap_count = 5

    fs_dist_file = os.getenv("traffic_sampler") + "/fs_dist/fake_dist.txt"

    generate_dataset(date_list, dataset_category_list, flowkey, pcap_count, fs_dist_file)