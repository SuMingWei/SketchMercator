import os
from env_setting.env_module import result_cp_path
def sketch_cp_path(name, epoch=1, w=4096, d=1, l=1, mode="baseline", crc=True, pcap_file_name="", hardware=False, api='cpp', date="111111_222222", hash_set_num=1):
    hash_set_name = "%02d.txt" % hash_set_num
    param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
    # mode = str(problem)

    # if sketch_aug == False:
    #     mode = "normal"
    # else:
    #     mode = "sketch_aug"

    if crc:
        hash_name = "crc_hash"
    else:
        hash_name = "universal_hash"

    if hardware == True:
        # path = os.path.join(result_cp_path, name, "hardware", "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date, hash_set_name)
        path = os.path.join(result_cp_path, "SketchAug_new", name, "hardware", "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date, hash_set_name)
    else:
        # path = os.path.join(result_cp_path, name, "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date, hash_set_name)
        path = os.path.join(result_cp_path, "SketchAug_new", name, "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date, hash_set_name)
    return path

# def get_sketch_cp_mrb_path(hash_set_num=1, w=4096, d=1, l=1, problem=0, crc=True, epoch=1, pcap_file_name="", hardware=False, api="python"):
#     hash_set_name = "%02d.txt" % hash_set_num
#     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
#     mode = str(problem)
#     # if sketch_aug == False:
#     #     mode = "normal"
#     # else:
#     #     mode = "sketch_aug"

#     if crc:
#         hash_name = "crc_hash"
#     else:
#         hash_name = "universal_hash"
#     if hardware == True:
#         path = os.path.join(result_cp_path, "mrb", "hardware", api, "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     else:
#         path = os.path.join(result_cp_path, "mrb", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     return path

# def get_sketch_cp_cs_path(hash_set_num=1, w=4096, d=1, l=1, sketch_aug=False, crc=True, epoch=1, pcap_file_name=""):

#     hash_set_name = "%02d.txt" % hash_set_num
#     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
#     if sketch_aug == False:
#         mode = "normal"
#     else:
#         mode = "sketch_aug"

#     if crc:
#         hash_name = "crc_hash"
#     else:
#         hash_name = "universal_hash"

#     path = os.path.join(result_cp_path,"countsketch", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     return path

# def get_sketch_cp_cs_path(hash_set_num=1, w=4096, d=1, l=1, problem=0, crc=True, epoch=1, pcap_file_name=""):

#     hash_set_name = "%02d.txt" % hash_set_num
#     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
#     mode = str(problem)
#     # if sketch_aug == False:
#     #     mode = "normal"
#     # else:
#     #     mode = "sketch_aug"

#     if crc:
#         hash_name = "crc_hash"
#     else:
#         hash_name = "universal_hash"

#     path = os.path.join(result_cp_path,"countsketch", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     return path


# def get_sketch_cp_hll_path(hash_set_num=1, w=4096, d=1, l=1, sketch_aug=False, crc=True, epoch=1, pcap_file_name=""):
#     hash_set_name = "%02d.txt" % hash_set_num
#     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
#     if sketch_aug == False:
#         mode = "normal"
#     else:
#         mode = "sketch_aug"

#     if crc:
#         hash_name = "crc_hash"
#     else:
#         hash_name = "universal_hash"

#     path = os.path.join(result_cp_path,"hll", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     return path

# def get_sketch_cp_mrb_path(hash_set_num=1, w=4096, d=1, l=1, sketch_aug=False, crc=True, epoch=1, pcap_file_name=""):
#     hash_set_name = "%02d.txt" % hash_set_num
#     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
#     if sketch_aug == False:
#         mode = "normal"
#     else:
#         mode = "sketch_aug"

#     if crc:
#         hash_name = "crc_hash"
#     else:
#         hash_name = "universal_hash"

#     path = os.path.join(result_cp_path,"mrb", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     return path

