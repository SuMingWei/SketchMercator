from env_setting.env_module import result_tofino_dp_path

from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count
from data_helper.data_path_helper.tofino_dp_path_helper import get_tofino_path
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_with_hash_name
from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path


from sketch_control_plane.mrb import mrb_main, mrb_counter_main, mrb_sketchaug_main
import os


from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

ret_list = get_pcap_list_by_date_and_count("20160121", "60s", 10)

level = 16
row = 1

MRB_NAME = "mrb_pingpong"
# MRB_NAME = "mrb_opt"
API = "cpp"

for (pcap_full_path, pcap_folder_path, pcap_file_name) in ret_list:
    if pcap_file_name == "small.pcap":
        continue
    if pcap_file_name == "4s.pcap":
        continue
    print(pcap_full_path, pcap_folder_path, pcap_file_name)
    # for epoch in [10, 20, 30]:
        # for width in [256, 512, 1024]:
    delays = {}
    delays[4096] = 1.722243
    delays[8192] = 3.53519
    delays[16384] = 7.345157
    delays[32768] = 14.843539
    delays[65536] = 30.30019

    for epoch in [1, 5, 10, 20, 30]:
        for width in [256, 512, 1024, 2048, 4096]:
            # if epoch <= delays[width*16]:
            #     continue
    # for epoch in [20, 30]:
    # # for epoch in [1, 5, 10]:
    #     for width in [256, 512, 1024, 2048, 4096]:
            # tofino_path = get_tofino_path("mrb", "python", width*16, epoch)
            tofino_path = get_tofino_path(MRB_NAME, API, width*16, epoch)
            mrb_path = sw_dp_path_with_hash_name(MRB_NAME, epoch, width, d=1, l=16, problem=0, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, hash_set_num=1)
            mrb_output_path =     sketch_cp_path(MRB_NAME, epoch, width, d=1, l=16, problem=0, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, hash_set_num=1)
            print()
            print(tofino_path)
            print()

            print()
            print(mrb_path)
            print()

            print()
            print(mrb_output_path)
            print()

            mrb_sketchaug_main(tofino_path, mrb_path, mrb_output_path, width, row, level)
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
