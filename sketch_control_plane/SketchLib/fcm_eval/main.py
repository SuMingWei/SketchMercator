import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import result_cp_path
from env_setting.env_module import sw_dp_simulator_path

from sketch_control_plane.SketchLib.fcm_eval.cm import cm_main
from sketch_control_plane.SketchLib.fcm_eval.fcm import fcm_main

from python_lib.pkl_saver import PklSaver

def sketch_cp(sketch_name, pcap_file_name, topk):
    print(sketch_name, pcap_file_name, topk)
    output_dir = os.path.join(result_sw_dp_path, "SketchLib", "fcm_eval", sketch_name, pcap_file_name, "01.txt")

    pkl_path = os.path.join(result_cp_path, "SketchLib", "fcm_eval", sketch_name, pcap_file_name)
    saver = PklSaver(pkl_path, "data.pkl")
    result_list = []
    for fn in sorted(os.listdir(output_dir)):
        print("epoch", fn)
        ret = []
        if sketch_name == "cm":
            ret = cm_main(os.path.join(output_dir,fn), topk)
            
        if sketch_name == "fcm":
            ret = fcm_main(os.path.join(output_dir,fn), topk)

        result_list.append(ret)
    saver.save(result_list)

