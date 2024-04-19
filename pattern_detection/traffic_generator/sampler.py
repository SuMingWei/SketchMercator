import os
import numpy as np

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count

def generate_dataset(date_list, dataset_category_list, flowkey, pcap_count, fs_dist_file, total_flows, total_packets):
    # Iterate over pcap files and parse them
    cmd = "%s/traffic_generator/pcap_generator " % os.getenv("pattern_detection")

    # add pcap file info 
    cmd += str(total_flows) + " " + str(total_packets) + " "
    
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
            
    # # remove old file
    # old_sorted_pcap_path = os.getenv("traffic_sampler") + "/traffic_generator/synthetic.pcap"
    # if os.path.isfile(old_sorted_pcap_path):
    #     print("[Remove Exists File] ", old_sorted_pcap_path)
    #     os.remove(old_sorted_pcap_path)
    os.system(cmd)

def generate_distribution(size, alpha, output_file):
    zipf_values = np.random.zipf(alpha, size)
    # print(zipf_values[:10])
    
    # Filter out flow sizes exceeding 1000000
    zipf_values = zipf_values[zipf_values <= 8000]
    
    flow_sizes, frequencies = np.unique(zipf_values, return_counts=True)
    
    total_packets = 0
    total_flows = 0
    
    with open(output_file, 'w') as file:
        for val, freq in zip(flow_sizes, frequencies):
            total_flows += freq
            total_packets += (val*freq)
            file.write(f"{val} {freq}\n")
            
    return total_flows, total_packets

if __name__ == "__main__":
    # sample sub-dataset from origin dataset
    date_list = [20180816]
    dataset_category_list = ["caida_specify_time/", ]
    flowkey = ["srcIP"]
    pcap_count = 5

    fs_dist_file = os.getenv("pattern_detection") + "/traffic_generator/dist.txt"
    
    # total_flows, total_packets = generate_distribution(size=1000000, alpha=2, output_file=fs_dist_file)
    while 1:
        total_flows, total_packets = generate_distribution(size=21000, alpha=1.001, output_file=fs_dist_file)
        if abs(total_packets - 3300000) <= 50000:
            print(total_packets)
            generate_dataset(date_list, dataset_category_list, flowkey, pcap_count, fs_dist_file, total_flows, total_packets)
            break
    
    print("synthetic_flows   : ", total_flows)
    print("synthetic_packets : ", total_packets)