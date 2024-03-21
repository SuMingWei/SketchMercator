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
    
    caida0517 = ["/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0517-500w.pcap",
                 "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0517-250w.pcap",
                 "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0517-125w.pcap"]
    caida0816 = [ "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0816-600w.pcap",    
                  "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0816-300w.pcap",    
                  "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/caida0816-150w.pcap"]
    zipf2a = [ "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2a-150w.pcap",
               "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2a-75w.pcap",
               "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2a-35w.pcap"]
    zipf2b = [ "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2b-400w.pcap",
               "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2b-200w.pcap",
               "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf2b-100w.pcap"]
    zipf4 = [ "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf4-60w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf4-30w.pcap",
              "/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/zipf4-15w.pcap"]
    
    # print(zipf[0][67:-5])
    # print(caida[2][67:-5])
    
    
    # lens = [["5", "5"],
    #         ["6", "4"],
    #         ["7", "3"],
    #         ["8", "2"],]
    lens = [["6", "4"]]
    
    flowkey = "srcIP"
    date_offset = [0, 91*24*60*60, 56*24*60*60] # [0816 0517 0621]
    
    # same dist, diff tfs
    # generate_dataset(caida[0], caida[1], lens[0][0], lens[0][1], flowkey, caida[0][67:-5], caida[1][67:-5], date_offset[0])
    
    # same dist CAIDA
    for a in caida0517:
        for b in caida0816:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], -date_offset[1])
    for a in caida0816:
        for b in caida0517:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[1])
            
    # same dist ZIPF
    for a in zipf2a:
        for b in zipf2b:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    for a in zipf2b:
        for b in zipf2a:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
        
    # diff dist, CAIDA + ZIPF
    for a in caida0517:
        for b in zipf2a:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], -date_offset[1])
        for b in zipf2b:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], -date_offset[1])
        for b in zipf4:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], -date_offset[1])
    for a in caida0816:
        for b in zipf2a:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
        for b in zipf2b:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
        for b in zipf4:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    
    # diff dist, ZIPF + CAIDA
    for a in zipf2a:
        for b in caida0517:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[1])
        for b in caida0816:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    for a in zipf2b:
        for b in caida0517:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[1])
        for b in caida0816:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    for a in zipf4:
        for b in caida0517:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[1])
        for b in caida0816:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
             
    # diff dist, ZIPF2a + ZIPF4
    for a in zipf2a:
        for b in zipf4:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    for a in zipf4:
        for b in zipf2a:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
                
    # diff dist, ZIPF2b + ZIPF4
    for a in zipf2b:
        for b in zipf4:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    for a in zipf4:
        for b in zipf2b:
            for len in lens:
                generate_dataset(a, b, len[0], len[1], flowkey, a[67:-5], b[67:-5], date_offset[0])
    
