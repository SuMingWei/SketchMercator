from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.sw_dp_path_helper import search_sw_dp_gt_path, search_sw_dp_cs_path
from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_cs_path
from sketch_control_plane.countsketch import cs_main

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)


ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)

# row = 5
# width = 4096
row = 1

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:

    for epoch in [1, 3, 5]:
        for width in [4096, 8192, 16384, 32768, 65536]:
        # for width in [65536]:
            gt_path = search_sw_dp_gt_path(epoch=epoch, pcap_file_name=pcap_file_name)
            # for p in [1]:
            for p in [0, 1, 2, 3, 4, 6]:
                cs_path = search_sw_dp_cs_path(hash_set_num=1, w=width, d=row, l=1, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
                cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
                # cs_main(gt_path, cs_path, cp_output_path, width, row)
                helper.call(cs_main, (gt_path, cs_path, cp_output_path, width, row, ))
        #         break
        #     break
        # break
    break



    # for epoch in [1,3,5,10]:
    #     for row in [1, 2, 3, 4, 5]:
    #         gt_path = search_sw_dp_gt_path(epoch=epoch, pcap_file_name=pcap_file_name)
            
    #         cs_path = search_sw_dp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    #         cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    #         # cs_main(gt_path, cs_path, cp_output_path, width, row)
    #         helper.call(cs_main, (gt_path, cs_path, cp_output_path, width, row, ))

    #         cs_path = search_sw_dp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    #         cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    #         # cs_main(gt_path, cs_path, cp_output_path, width, row)
    #         helper.call(cs_main, (gt_path, cs_path, cp_output_path, width, row, ))
