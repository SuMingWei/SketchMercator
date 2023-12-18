from env_setting.env_module import pcap_storage_path

import os


def get_test_pcap_list_count(pcap_name):
    test_path = os.path.join(pcap_storage_path, "test")
    ret_list = []

    count = 0

    folder_path = os.path.join(test_path)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".pcap"):
            if file_name == pcap_name:
                full_path = os.path.join(folder_path, file_name)
                ret_list.append((full_path, folder_path, file_name))
    return ret_list

def get_test_dat_list_count(pcap_name):
    test_path = os.path.join(pcap_storage_path, "compact", "test")
    ret_list = []

    count = 0

    folder_path = os.path.join(test_path)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".dat"):
            if file_name == pcap_name:
                full_path = os.path.join(folder_path, file_name)
                ret_list.append((full_path, folder_path, file_name))
    return ret_list

# /data/sketch_home/pcap_storage/caida/20160121/60s/equinix-chicago.dirA.20160121-130400.UTC.anon.pcap
def get_pcap_list_by_date_and_count(date, pcap_duration, pcap_count, category = "caida"):
    caida_path = os.path.join(pcap_storage_path, category)
    ret_list = []

    count = 0

    folder_path = os.path.join(caida_path, str(date), pcap_duration)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".pcap"):
            if file_name == "large.pcap":
                continue
            if file_name == "small.pcap":
                continue
            if file_name == "4s.pcap":
                continue
            full_path = os.path.join(folder_path, file_name)
            ret_list.append((full_path, folder_path, file_name))
            count += 1
            if count >= pcap_count:
                break
    return ret_list


def get_pcap_list_by_date_and_hour_list(date, pcap_duration, hour_list):
    caida_path = os.path.join(pcap_storage_path, "caida")
    ret_list = []
    count = 0
    folder_path = os.path.join(caida_path, str(date), pcap_duration)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".pcap"):
            for hour in hour_list:
                if hour in file_name:
                    full_path = os.path.join(folder_path, file_name)
                    ret_list.append((full_path, folder_path, file_name))


    return ret_list

def get_dat_list_by_date_and_count(date, pcap_duration, pcap_count):
    caida_path = os.path.join(pcap_storage_path, "compact", "caida")
    ret_list = []

    count = 0

    folder_path = os.path.join(caida_path, str(date), pcap_duration)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".dat"):
            full_path = os.path.join(folder_path, file_name)
            ret_list.append((full_path, folder_path, file_name))
            count += 1
            if count >= pcap_count:
                break
    return ret_list


def convert_to_ether_path(full_path):
    # print(full_path)
    dirname = os.path.dirname(full_path)
    file_name = os.path.basename(full_path)
    folder_path = os.path.join(dirname, "ether")
    full_path = os.path.join(folder_path, file_name)
    return (full_path, folder_path, file_name)

extension_path = os.path.join(pcap_storage_path, "extension")
def get_extension_pcap_list_by_date_and_count(date, pcap_duration, extension_rate, pcap_count):
    ret_list = []

    count = 0

    folder_path = os.path.join(extension_path, str(date), pcap_duration, extension_rate)
    for file_name in sorted(os.listdir(folder_path)):
        if file_name.endswith(".pcap"):
            full_path = os.path.join(folder_path, file_name)
            ret_list.append((full_path, folder_path, file_name))
            count += 1
            if count >= pcap_count:
                break
    return ret_list
