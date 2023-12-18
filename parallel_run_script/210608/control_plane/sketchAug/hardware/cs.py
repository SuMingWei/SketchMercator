from env_setting.env_module import result_tofino_dp_path

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.tofino_dp_path_helper import get_tofino_path
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_with_hash_name
from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path


from sketch_control_plane.cs_f2 import cs_f2_sketchaug_main

import os


from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)

level = 1
row = 4

# CS_NAME = "cs_sol2"
CS_NAME = "cs_baseline"
API = "cpp"

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    if pcap_file_name == "small.pcap":
        continue
    if pcap_file_name == "4s.pcap":
        continue
    print(pcap_full_path, pcap_folder_path, pcap_file_name)
    for epoch in [1, 5, 10, 20, 30]:
        for width in [1024, 2048, 4096, 8192, 16384]:
            # if epoch != 5:
            #     continue
            # if width != 1024:
            #     continue
            tofino_path = get_tofino_path(CS_NAME, API, width, epoch)
            cs_path = sw_dp_path_with_hash_name(CS_NAME, epoch, width, d=row, l=level, problem=0, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, hash_set_num=1)
            cs_output_path =     sketch_cp_path(CS_NAME, epoch, width, d=row, l=level, problem=0, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, hash_set_num=1)

            # print(tofino_path)
            # print(cs_path)
            # print(cs_output_path)
            if CS_NAME == "cs_sol2":
                cs_f2_sketchaug_main(tofino_path, cs_path, cs_output_path, width, row, level, True)
            else:
                cs_f2_sketchaug_main(tofino_path, cs_path, cs_output_path, width, row, level, False)
            # exit(1)

        #     break
        # break
            # print(mrb_path)
            # size = width*16
            # # cpp_path = os.path.join(result_tofino_dp_path, "sketchAug", "mrb", "small", "cpp_%d_bulk.txt" % size)
            # cpp_path = os.path.join(result_tofino_dp_path, "sketchAug", "mrb", "4s", "cpp_%d_bulk.txt" % size)
            # mrb_output_path = get_sketch_cp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            # mrb_counter_main(mrb_path, cpp_path, mrb_output_path, width, row, level)
            # # exit(1)

    break
