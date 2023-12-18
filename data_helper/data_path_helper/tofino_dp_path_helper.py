from env_setting.env_module import result_tofino_dp_path
import os

# def get_tofino_path(name, api, array_size, epoch):
#     folder_path = os.path.join(result_tofino_dp_path, "sketchAug", name, api, "%05d" % array_size, "%02ds" % epoch)
#     if not os.path.exists(folder_path):
#         os.makedirs(folder_path)
#     return folder_path

# def get_pcounter_path(name, api, array_size, epoch):
#     folder_path = get_tofino_path(name, api, array_size, epoch)
#     return os.path.join(folder_path, "pcounter.txt")


# def get_tofino_path_with_count(name, api, array_size, epoch, count):
#     folder_path = os.path.join(result_tofino_dp_path, "sketchAug", name, api, "%05d" % array_size, "%02ds" % epoch, "%02d" % count)
#     if not os.path.exists(folder_path):
#         os.makedirs(folder_path)
#     return folder_path

# def get_tofino_result_path(name, api, array_size, epoch, count):
#     folder_path = get_tofino_path_with_count(name, api, array_size, epoch, count)
#     return os.path.join(folder_path, "result.txt")

def get_date_list(name, mode, api, array_size, epoch, pcap_name):
    # print(name, mode, api, array_size, epoch, pcap_name)
    folder_path = os.path.join(result_tofino_dp_path, "sketchAug", name, mode, api, "%05d" % array_size, "%02ds" % epoch, pcap_name)

    if os.path.isdir(folder_path) == False:
        return []

    ret_list = []
    count = 0
    for folder_name in sorted(os.listdir(folder_path)):
        full_path = os.path.join(folder_path, folder_name)
        if os.path.isdir(full_path):
            ret_list.append(folder_name)
    return ret_list

def get_tofino_path(name, mode, api, array_size, epoch, pcap_name, date):
    folder_path = os.path.join(result_tofino_dp_path, "sketchAug", name, mode, api, "%05d" % array_size, "%02ds" % epoch, pcap_name, date)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    return folder_path

def read_pcounter(pcounter_path):
    f = open(pcounter_path, "r")
    counter = []
    for a in f:
        counter.append(int(a))
    return counter

def get_pcounter_path(name, mode, api, array_size, epoch, pcap_name, date):
    folder_path = get_tofino_path(name, mode, api, array_size, epoch, pcap_name, date)
    return os.path.join(folder_path, "pcounter.txt")


def get_tofino_path_with_count(name, mode, api, array_size, epoch, pcap_name, count, date):
    prev_path = get_tofino_path(name, mode, api, array_size, epoch, pcap_name, date)
    folder_path = os.path.join(prev_path, "%02d" % count)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    return folder_path

def get_tofino_result_path(name, mode, api, array_size, epoch, pcap_name, count, date):
    folder_path = get_tofino_path_with_count(name, mode, api, array_size, epoch, pcap_name, count, date)
    return os.path.join(folder_path, "result.txt")
