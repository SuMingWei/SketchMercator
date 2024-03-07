import os
import numpy as np

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count

def generate_dataset(file1, file2, len1, len2, flowkey, name1, name2, date_offset):
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
    cmd += " "
    cmd += name1
    cmd += " "
    cmd += name2
    cmd += " "
    cmd += str(date_offset)
    
    print("[Run Pcap Combiner] ", cmd)
    
    # remove old file
    old_sorted_pcap_path = os.getenv("pattern_detection") + "/traffic_generator/testing_pcap_file/tmp.pcap"
    if os.path.isfile(old_sorted_pcap_path):
        print("[Remove Exists File] ", old_sorted_pcap_path)
        os.remove(old_sorted_pcap_path)
    
    os.system(cmd)


if __name__ == "__main__":
    # combine two dataset
    
    file1s = ["/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/60s/333709_2515088.pcap",    
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/60s/1000000_1111018.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/60s/1000000_8769863.pcap"]
    file2s = ["/home/ming/SketchMercator/pcap_storage/caida_specify_time/20180816/60s/equinix-nyc.dirA.20180816-130100.UTC.anon.pcap",
              "/home/ming/SketchMercator/pcap_storage/caida_specify_time/20180517/60s/equinix-nyc.dirA.20180517-130100.UTC.anon.pcap",
              "/home/ming/SketchMercator/pcap_storage/caida_specify_time/20180621/60s/equinix-nyc.dirA.20180621-130100.UTC.anon.pcap"]
    
    name1 = ["zipf2a", "zipf4", "zipf2b"]
    name2 = ["caida20180816", "caida20180517", "caida20180621"]
    
    lens = [["3", "7"],
            ["4", "6"],
            ["5", "5"],
            ["6", "4"],
            ["7", "3"],
            ["8", "2"],]
    
    flowkey = "srcIP"
    date_offset = [0, 91*24*60*60, 56*24*60*60]
    
    for i in range(len(file1s)):
        for l in lens:
            # generate_dataset(file2s[2], file1s[i], l[0], l[1], flowkey, name2[2], name1[i], -date_offset[2])
            generate_dataset(file2s[1], file1s[i], l[0], l[1], flowkey, name2[1], name1[i], -date_offset[1])
            generate_dataset(file1s[i], file2s[2], l[0], l[1], flowkey, name1[i], name2[2], date_offset[2])
    
    # for l in lens:
    #     for ignore in ignores:
            
    
    # for l in lens:
    #     generate_dataset(file2s[0], file2s[1], l[0], l[1], flowkey, name2[0], name2[1], date_offset[1])
    
    # for i in range(len(file1s)):
    #     generate_dataset(file1s[i], file2s[0], "10", "0", flowkey, name1[i], name2[0], date_offset[0])
    # for i in range(len(file2s)):
    #     generate_dataset(file2s[i], file2s[0], "10", "0", flowkey, name2[i], name2[0], date_offset[0])
    
    # for l in lens:
    #     generate_dataset(file2s[0], file2s[2],l[0], l[1], flowkey, name2[0], name2[2], date_offset[2])
        
    # generate_dataset(file2s[2], file2s[0], "10", "0", flowkey, name2[2], name2[0], date_offset[0])
    
    