import os

# pcap iteration code
from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_dat_list_by_date_and_count
from data_helper.data_path_helper.pcap_path_helper import get_test_pcap_list_count
from data_helper.data_path_helper.pcap_path_helper import get_test_dat_list_count

# flowkey_list = ["srcIP",
#                 "srcIP,srcPort",
#                 "dstPort",
#                 "dstIP,dstPort",
#                 "dstIP",
#                 "srcIP,dstIP",
#                 "srcIP,dstIP,srcPort,dstPort",
#                 "srcIP,dstIP,srcPort,dstPort,proto",
#                 ]

def handle_dataset(data_list, dataset_category_list, flowkey, pcap_count):
    # Iterate over pcap files and parse them
    cmd = "%s/traffic_generator/pcap_parser " % os.getenv("traffic_sampler")

    # Iterate over pcap files and parse them
    for dataset_category in dataset_category_list:
        for date in date_list:
            pcap_list = get_pcap_list_by_date_and_count(date, "60s", pcap_count, dataset_category)
            for key in flowkey:
                cmd += key
                cmd += " "
                for (pcap_full_path, pcap_folder_path, pcap_file_name) in pcap_list:
                    # print(pcap_full_path, pcap_folder_path, pcap_file_name)
                    cmd += pcap_full_path
                    cmd += " "

            print("[start run] ", cmd)
    os.system(cmd)

if __name__ == "__main__":

    date_list = [20180517]
    dataset_category_list = ["caida_specify_time/", ]
    flowkey = ["srcIP"]
    pcap_count = 1

    handle_dataset(date_list, dataset_category_list, flowkey, pcap_count)