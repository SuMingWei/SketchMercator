import os
import pickle

def relative_error(true, estimate):
    return abs(true-estimate)/true

def parameter_txt_iteration(controlplane_folder_name):
    ret = []
    for dirname in sorted(os.listdir(controlplane_folder_name)):
        if dirname.endswith(".txt"):
            full_folder_path = os.path.join(controlplane_folder_name, dirname)
            if os.path.isdir(full_folder_path):
                ret.append((dirname, full_folder_path))
    return ret

def window_size_iteration(parameter_txt_path):
    ret = []
    for dirname in sorted(os.listdir(parameter_txt_path)):
        if dirname.endswith("s"):
            window_file_path = os.path.join(parameter_txt_path, dirname)
            ret.append((dirname, window_file_path))
    return ret

def data_process(data):

    pcap = []
    for k2, v2 in data.items():  # pcap files
        # data.append([])
        opt = []
        for k3, v3 in v2.items():  # 0_original, 1_crc_original
            result = []
            # print(k3)
            for z, (k4, v4) in enumerate(v3.items()):  # (cardinality / entropy) X (topk 20 ~ 300 / threshold 0.2 ~ 0.0001 / both)
                # print(z, (k4, v4))
                if z == 0:
                    result.append(v4[0])
                if z == 1:
                    result.append(relative_error(v4[0], v4[1])*100)
                if z == 2:
                    result.append(relative_error(v4[0], v4[1])*100)
            opt.append(result)
        pcap.append(opt)

    return pcap


def data_process_within_parameter(window_path):

    new_array_2 = []
    for width in [1024, 2048, 4096]:
        new_array_1 = []
        for row in [3, 4, 5, 6]:
            fn = "%d_%d.pkl" % (row, width)
            with open(os.path.join(window_path, fn), 'rb') as f:
                pkl_data = pickle.load(f)
                new_array_1.append(data_process(pkl_data))
        new_array_2.append(new_array_1)

    return new_array_2

def read_data(controlplane_folder_name):

    data_array1 = []

    parameter_txt_list = parameter_txt_iteration(controlplane_folder_name)
    for (parameter_txt_name, parameter_txt_path) in parameter_txt_list: # parameter txt
        window_list = window_size_iteration(parameter_txt_path)
        data_array2 = []
        for (window_name, window_path) in window_list: # window size
            if window_name != '30s':
                continue
            data_array2 = data_process_within_parameter(window_path)
        data_array1.append(data_array2)

    return data_array1
