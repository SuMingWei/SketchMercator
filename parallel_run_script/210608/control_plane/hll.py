from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.sw_dp_path_helper import search_sw_dp_gt_path, search_sw_dp_hll_path
from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_hll_path
from sketch_control_plane.hll import hll_main

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 5)

row = 1

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    for epoch in [1,3,5,10]:
        for width in [512, 1024, 2048, 4096, 8192]:
            gt_path = search_sw_dp_gt_path(epoch=epoch, pcap_file_name=pcap_file_name)

            hll_path = search_sw_dp_hll_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            hll_output_path = get_sketch_cp_hll_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            # hll_main(gt_path, hll_path, hll_output_path, width, row)
            helper.call(hll_main, (gt_path, hll_path, hll_output_path, width, row, ))

            hll_path = search_sw_dp_hll_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            hll_output_path = get_sketch_cp_hll_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            # hll_main(gt_path, hll_path, hll_output_path, width, row)
            helper.call(hll_main, (gt_path, hll_path, hll_output_path, width, row, ))
