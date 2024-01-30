import os
import numpy as np

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count

def generate_dataset(file1, file2, len1, len2, flowkey):
    # Iterate over pcap files and parse them
    cmd = "%s/traffic_generator/pcap_combiner " % os.getenv("pattern_detection")
    
    cmd += file1
    cmd += " "
    cmd += file2
    cmd += " "
    cmd += len1
    cmd += " "
    cmd += len2
    cmd += " "
    cmd += flowkey
    
    print("[Run Pcap Combiner] ", cmd)
    
    # remove old file
    old_sorted_pcap_path = os.getenv("pattern_detection") + "/traffic_generator/pcap_file/tmp.pcap"
    if os.path.isfile(old_sorted_pcap_path):
        print("[Remove Exists File] ", old_sorted_pcap_path)
        os.remove(old_sorted_pcap_path)
    
    os.system(cmd)


if __name__ == "__main__":
    # combine two dataset
    
    file2 = "/home/ming/SketchMercator/pcap_storage/caida_specify_time/20180816/60s/equinix-nyc.dirA.20180816-130100.UTC.anon.pcap"
    file1 = "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/60s/333709_2515088.pcap"    
    len1 = "5"
    len2 = "5"
    flowkey = "srcIP"
    
    generate_dataset(file1, file2, len1, len2, flowkey)
    