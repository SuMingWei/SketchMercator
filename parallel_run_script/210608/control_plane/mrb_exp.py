from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.sw_dp_path_helper import search_sw_dp_gt_path, search_sw_dp_mrb_path
from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_mrb_path
from sketch_control_plane.mrb import mrb_main, mrb_counter_main
from env_setting.env_module import result_tofino_dp_path
import os

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)

level = 16
row = 1

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    # if pcap_file_name != "small.pcap":
    #     continue    
    if pcap_file_name != "4s.pcap":
        continue    
    print(pcap_full_path, pcap_folder_path, pcap_file_name)
    # break
    for epoch in [10]:
        for width in [256, 512, 1024, 2048, 4096]:
            # gt_path = search_sw_dp_gt_path(epoch=epoch, pcap_file_name=pcap_file_name)
            # print(gt_path)
            for p in [0]:
                mrb_path = search_sw_dp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
                print(mrb_path)
                size = width*16
                # cpp_path = os.path.join(result_tofino_dp_path, "sketchAug", "mrb", "small", "cpp_%d_bulk.txt" % size)
                cpp_path = os.path.join(result_tofino_dp_path, "sketchAug", "mrb", "4s", "cpp_%d_bulk.txt" % size)
                mrb_output_path = get_sketch_cp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
                mrb_counter_main(mrb_path, cpp_path, mrb_output_path, width, row, level)
                # exit(1)


                # python_path = os.path.join(result_tofino_dp_path, "sketchAug", "mrb", "python_%d.txt" % size)

        #         # print(mrb_output_path)
        #         # mrb_main(gt_path, mrb_path, mrb_output_path, width, row, level)
        #         # helper.call(mrb_main, (gt_path, mrb_path, mrb_output_path, width, row, level, ))
        # #         break
        # #     break
        # # break
    break
