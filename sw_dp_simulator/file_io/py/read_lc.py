from sw_dp_simulator.file_io.py.common import parse_line
import os

def load_lc(dir, w, d):

    hh_dict_list = []
    count_list = []

    sampling_hash_list = []
    res_hash_list = []
    index_hash_list = []

    sketch_array_list = []

    f = open(dir + "/cardinality.txt")
    line = f.readline().strip()
    cardinality = int(line)
    f.close()

    for level in range(0, 1):
        file_path = '%s/level_%02d/' % (dir, level)

        f = open(file_path + "total.txt")
        line = f.readline().strip()
        count_list.append(int(line))
        f.close()

        f = open(file_path + "sampling_hash_params.txt")
        f.readline().strip()
        pline = f.readline().strip()
        aParam = int(pline.split(" ")[0])
        bParam = int(pline.split(" ")[1])
        polyParam = int(pline.split(" ")[2])
        initParam = int(pline.split(" ")[3])
        xoutParam = int(pline.split(" ")[4])
        sampling_hash_list.append((aParam, bParam, polyParam, initParam, xoutParam))
        f.close()


        sub_list = []
        f = open(file_path + "index_hash_params.txt")
        for i in range(0, d):
            pline = f.readline().strip()
            aParam = int(pline.split(" ")[0])
            bParam = int(pline.split(" ")[1])
            polyParam = int(pline.split(" ")[2])
            initParam = int(pline.split(" ")[3])
            xoutParam = int(pline.split(" ")[4])
            sub_list.append((aParam, bParam, polyParam, initParam, xoutParam))
        f.close()
        index_hash_list.append(sub_list)


        sub_list = []
        f = open(file_path + "res_hash_params.txt")
        for i in range(0, d):
            pline = f.readline().strip()
            aParam = int(pline.split(" ")[0])
            bParam = int(pline.split(" ")[1])
            polyParam = int(pline.split(" ")[2])
            initParam = int(pline.split(" ")[3])
            xoutParam = int(pline.split(" ")[4])
            sub_list.append((aParam, bParam, polyParam, initParam, xoutParam))
        f.close()
        res_hash_list.append(sub_list)


        sub_list = []
        f = open(file_path + "sketch_counter.txt")
        for i in range(0, d * w):
            pline = f.readline().strip()
            sub_list.append(int(pline))
        f.close()
        sketch_array_list.append(sub_list)

    return_dict = {}

    return_dict["cardinality"] = cardinality

    return_dict["count_list"] = count_list

    return_dict["sampling_hash_list"] = sampling_hash_list
    return_dict["index_hash_list"] = index_hash_list
    return_dict["res_hash_list"] = res_hash_list

    return_dict["sketch_array_list"] = sketch_array_list

    return return_dict