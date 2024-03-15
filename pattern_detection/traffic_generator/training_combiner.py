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
    old_sorted_pcap_path = os.getenv("pattern_detection") + "/traffic_generator/scaled_pcap_file/tmp.pcap"
    if os.path.isfile(old_sorted_pcap_path):
        print("[Remove Exists File] ", old_sorted_pcap_path)
        os.remove(old_sorted_pcap_path)
    
    os.system(cmd)


if __name__ == "__main__":
    # combine two dataset
    
    caida = [ "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0816-600w.pcap",    
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0816-300w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0816-150w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0517-250w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0517-125w.pcap"]
    zipf = [  "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2a-150w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2a-75w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2b-40w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2b-10w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf4-60w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf4-30w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2a-35w.pcap",]
    
    # print(zipf[0][67:-5])
    # print(caida[2][67:-5])
    
    
    lens = [["5", "5"],
            ["6", "4"],
            ["7", "3"],
            ["8", "2"],]
    
    flowkey = "srcIP"
    date_offset = [0, 91*24*60*60, 56*24*60*60] # [0816 0517 0621]
    
    # same dist, diff tfs
    # generate_dataset(caida[0], caida[1], lens[0][0], lens[0][1], flowkey, caida[0][67:-5], caida[1][67:-5], date_offset[0])
    
    for len in lens:
        generate_dataset(caida[0], caida[1], len[0], len[1], flowkey, caida[0][67:-5], caida[1][67:-5], date_offset[0])
        generate_dataset(caida[1], caida[0], len[0], len[1], flowkey, caida[1][67:-5], caida[0][67:-5], date_offset[0])
        generate_dataset(caida[0], caida[3], len[0], len[1], flowkey, caida[0][67:-5], caida[3][67:-5], date_offset[1])
        generate_dataset(caida[3], caida[0], len[0], len[1], flowkey, caida[3][67:-5], caida[0][67:-5], -date_offset[1])
        generate_dataset(caida[0], caida[4], len[0], len[1], flowkey, caida[0][67:-5], caida[4][67:-5], date_offset[1])
        generate_dataset(caida[4], caida[0], len[0], len[1], flowkey, caida[4][67:-5], caida[0][67:-5], -date_offset[1])
        generate_dataset(zipf[0], zipf[2], len[0], len[1], flowkey, zipf[0][67:-5], zipf[2][67:-5], date_offset[0])
        generate_dataset(zipf[2], zipf[0], len[0], len[1], flowkey, zipf[2][67:-5], zipf[0][67:-5], date_offset[0])
        generate_dataset(zipf[1], zipf[3], len[0], len[1], flowkey, zipf[1][67:-5], zipf[3][67:-5], date_offset[0])
        generate_dataset(zipf[3], zipf[1], len[0], len[1], flowkey, zipf[3][67:-5], zipf[1][67:-5], date_offset[0])
        
    # diff dist, same tfs
    for len in lens:
        generate_dataset(caida[2], zipf[0], len[0], len[1], flowkey, caida[2][67:-5], zipf[0][67:-5], date_offset[0])
        generate_dataset(zipf[0], caida[2], len[0], len[1], flowkey, zipf[0][67:-5], caida[2][67:-5], date_offset[0])
        generate_dataset(zipf[6], zipf[5], len[0], len[1], flowkey, zipf[6][67:-5], zipf[5][67:-5], date_offset[0])
        generate_dataset(zipf[5], zipf[6], len[0], len[1], flowkey, zipf[5][67:-5], zipf[6][67:-5], date_offset[0])
    
    # diff dist, diff tfs 
    for len in lens:
        generate_dataset(caida[0], zipf[0], len[0], len[1], flowkey, caida[0][67:-5], zipf[0][67:-5], date_offset[0])
        generate_dataset(zipf[0], caida[0], len[0], len[1], flowkey, zipf[0][67:-5], caida[0][67:-5], date_offset[0])
        generate_dataset(caida[0], zipf[2], len[0], len[1], flowkey, caida[0][67:-5], zipf[2][67:-5], date_offset[0])
        generate_dataset(zipf[2], caida[0], len[0], len[1], flowkey, zipf[2][67:-5], caida[0][67:-5], date_offset[0])
        generate_dataset(caida[0], zipf[4], len[0], len[1], flowkey, caida[0][67:-5], zipf[4][67:-5], date_offset[0])
        generate_dataset(zipf[4], caida[0], len[0], len[1], flowkey, zipf[4][67:-5], caida[0][67:-5], date_offset[0])
        generate_dataset(zipf[0], zipf[4], len[0], len[1], flowkey, zipf[0][67:-5], zipf[4][67:-5], date_offset[0])
        generate_dataset(zipf[4], zipf[0], len[0], len[1], flowkey, zipf[4][67:-5], zipf[0][67:-5], date_offset[0])
    
