import os
from env_setting.env_module import result_gt_path, result_sw_dp_path

def search_sw_dp_gt_path(epoch=1, pcap_file_name=""):
    path = os.path.join(result_gt_path, "srcIP", pcap_file_name, "%02ds" % epoch)
    if os.path.isdir(path):
        return path
    return None

def sw_dp_path_input(name, epoch=1, w=4096, d=1, l=1, mode="baseline", crc=True, pcap_file_name="", hardware=False, api='cpp', date="111111_222222"):

    param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
    # mode = str(problem)

    if crc:
        hash_name = "crc_hash"
    else:
        hash_name = "universal_hash"

    if hardware == True:
        # path = os.path.join(result_sw_dp_path, name, "hardware", "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date)
        path = os.path.join(result_sw_dp_path, "SketchAug", name, "hardware", "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date)
    else:
        # path = os.path.join(result_sw_dp_path, name, "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date)
        path = os.path.join(result_sw_dp_path, "SketchAug", name, "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date)

    return path

def sw_dp_path_with_hash_name(name, epoch=1, w=4096, d=1, l=1, mode="baseline", crc=True, pcap_file_name="", hardware=False, api='cpp', date="111111_222222", hash_set_num=1):

    hash_set_name = "%02d.txt" % hash_set_num
    param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
    # mode = str(problem)

    if crc:
        hash_name = "crc_hash"
    else:
        hash_name = "universal_hash"

    if hardware == True:
        path = os.path.join(result_sw_dp_path, name, "hardware", "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date, hash_set_name)
    else:
        path = os.path.join(result_sw_dp_path, name, "srcIP", param, mode, hash_name, pcap_file_name, "%02ds" % epoch, api, date, hash_set_name)

    if os.path.isdir(path):
        return path
    return None
    # print("[%s] Can not find this path\n%s\nexit!" % (name, path))
    # exit(1)
    # else:
    # return None


# # def search_sw_dp_cs_path(hash_set_num=1, w=4096, d=1, l=1, sketch_aug=False, crc=True, epoch=1, pcap_file_name=""):
# #     hash_set_name = "%02d.txt" % hash_set_num
# #     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
# #     if sketch_aug == False:
# #         mode = "normal"
# #     else:
# #         mode = "sketch_aug"

# #     if crc:
# #         hash_name = "crc_hash"
# #     else:
# #         hash_name = "universal_hash"

# #     path = os.path.join(result_sw_dp_path,"countsketch", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
# #     if os.path.isdir(path):
# #         return path
# #     else:
# #         print("[HLL] Can not find this path\n%s\nexit!" % path)
# #         exit(1)
# #     return None

# def search_sw_dp_cs_path(hash_set_num=1, w=4096, d=1, l=1, problem=0, crc=True, epoch=1, pcap_file_name=""):
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

#     path = os.path.join(result_sw_dp_path,"countsketch", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     if os.path.isdir(path):
#         return path
#     else:
#         print("[HLL] Can not find this path\n%s\nexit!" % path)
#         exit(1)
#     return None

# def search_sw_dp_hll_path(hash_set_num=1, w=4096, d=1, l=1, sketch_aug=False, crc=True, epoch=1, pcap_file_name=""):
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

#     path = os.path.join(result_sw_dp_path,"hll", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     if os.path.isdir(path):
#         return path
#     else:
#         print("[HLL] Can not find this path\n%s\nexit!" % path)
#         exit(1)
#     return None

# # def search_sw_dp_mrb_path(hash_set_num=1, w=4096, d=1, l=1, sketch_aug=False, crc=True, epoch=1, pcap_file_name=""):
# #     hash_set_name = "%02d.txt" % hash_set_num
# #     param = "__t__200__w__%d__d__%d__l__%d" % (w, d, l)
# #     if sketch_aug == False:
# #         mode = "normal"
# #     else:
# #         mode = "sketch_aug"

# #     if crc:
# #         hash_name = "crc_hash"
# #     else:
# #         hash_name = "universal_hash"

# #     path = os.path.join(result_sw_dp_path,"mrb", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
# #     if os.path.isdir(path):
# #         return path
# #     else:
# #         print("[MRB] Can not find this path\n%s\nexit!" % path)
# #         exit(1)
# #     return None

# def search_sw_dp_mrb_path(hash_set_num=1, w=4096, d=1, l=1, problem=0, crc=True, epoch=1, pcap_file_name="", hardware=False):
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
#         path = os.path.join(result_sw_dp_path, "mrb", "hardware", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     else:
#         path = os.path.join(result_sw_dp_path, "mrb", "srcIP", hash_set_name, param, mode, hash_name, pcap_file_name, "%02ds" % epoch)
#     if os.path.isdir(path):
#         return path
#     else:
#         print("[MRB] Can not find this path\n%s\nexit!" % path)
#         exit(1)
#     return None


