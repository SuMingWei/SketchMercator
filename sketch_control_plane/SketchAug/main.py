from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path, get_tofino_path
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_input, sw_dp_path_with_hash_name
from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path

from sketch_control_plane.SketchAug.sketch.univmon import univmon_main
from sketch_control_plane.SketchAug.sketch.mrb import mrb_main
from sketch_control_plane.SketchAug.sketch.hll import hll_main
from sketch_control_plane.SketchAug.sketch.cs import cs_main
from sketch_control_plane.SketchAug.sketch.cm import cm_main
from python_lib.pkl_saver import PklSaver
import os

from sketch_control_plane.SketchAug.lib.common import get_counter_diff

def get_path(pcap_file_name, sketch_name, mode, array_size, epoch, date):
    API = "cpp"
    if sketch_name == "mrb":
        width = array_size/16
        depth = 1
        level = 16
    if sketch_name == "hll":
        width = array_size
        depth = 1
        level = 1
    if sketch_name == "cs":
        width = array_size
        depth = 4
        level = 1
    if sketch_name == "cm":
        width = array_size
        depth = 4
        level = 1
    if sketch_name == "univmon":
        width = array_size/16
        depth = 4
        level = 16
    
    pcounter_path = get_pcounter_path(sketch_name, mode, API, array_size, epoch, pcap_file_name, date)
    sw_dp_path = sw_dp_path_input(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    pkl_path = sketch_cp_path(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date)
    
    return sw_dp_path, pkl_path

def get_tofino_counter(tofino_full_path):
    f = open(tofino_full_path, "r")
    counter = []
    for a in f:
        b = a.strip()
        counter.append(int(b))
    return counter

def sketch_cp(file_name, sketch_name, mode, array_size, epoch, date):
    API = "cpp"
    tofino_path = get_tofino_path(sketch_name, mode, API, array_size, epoch, file_name, date)
    sw_dp_path, pkl_path = get_path(file_name, sketch_name, mode, array_size, epoch, date)

    if sw_dp_path == None:
        print("[no data plane result] [%s]" % pkl_path)
        return
    saver = PklSaver(pkl_path, "data.pkl")
    pkl_full = os.path.join(pkl_path, "data.pkl")
    if os.path.isfile(pkl_full):
        data = saver.load()
        if len(data) != 0:
            print("[data exist] [%s]" % pkl_path)
            # return

    count = 1000
    # count = 3

    tofino_dir = []
    for dir in sorted(os.listdir(tofino_path)):
        p = os.path.join(tofino_path, dir)
        if os.path.isdir(p):
            tofino_dir.append(dir)

    # print(tofino_path)
    # print(len(tofino_dir), tofino_dir)
    # print()

    tofino_full_path = os.path.join(tofino_path, tofino_dir[0], "result.txt")
    previous_counter = get_tofino_counter(tofino_full_path)

    tofino_dir = tofino_dir[1:count]
    print(len(tofino_dir))

    sim_dir = []
    for dir in sorted(os.listdir(sw_dp_path)):
        p = os.path.join(sw_dp_path, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)

    # print(sw_dp_path)
    # print(len(sim_dir), sim_dir)
    # print()
    # print()

    sim_dir = sim_dir[1:count]
    print(len(sim_dir))

        
    result_list=[]

    for (a, b) in zip(tofino_dir, sim_dir):
        tofino_full_path = os.path.join(tofino_path, a, "result.txt")
        tofino_counters = get_tofino_counter(tofino_full_path)
        # print(len(tofino_counters))

        if mode == "noreset":
            tofino_counters_p = get_counter_diff(previous_counter, tofino_counters)
        else:
            tofino_counters_p = tofino_counters

        sim_full_path = os.path.join(sw_dp_path, b)
        if sketch_name == "mrb":
            ret = mrb_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters_p, sim_full_path)
        if sketch_name == "cs":
            ret = cs_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters_p, sim_full_path)
        if sketch_name == "cm":
            ret = cm_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters_p, sim_full_path)
        if sketch_name == "univmon":
            ret = univmon_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters_p, sim_full_path)
        if sketch_name == "hll":
            ret = hll_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters_p, sim_full_path)
        previous_counter = tofino_counters
        result_list.append(ret)
    # exit(1)
    saver.save(result_list)


