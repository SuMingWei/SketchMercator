import os
from sketch_control_plane.SketchMD.sketch.hll import hll_main
from sketch_control_plane.SketchMD.sketch.cs import cs_main
from sketch_control_plane.SketchMD.sketch.cm import cm_main
from python_lib.pkl_saver import PklSaver

def sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level, xor_hash_type=1):
    # print(sketch_name)

    # print(output_dir)
    saver = PklSaver(output_pkl_dir, "data.pkl")

    result_list = []

    sim_dir = []
    for dir in sorted(os.listdir(output_dir)):
        p = os.path.join(output_dir, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)
    for dir in sim_dir:
        full_dir = os.path.join(output_dir, dir)
        if sketch_name == "hll":
            ret = hll_main(sketch_name, full_dir, row, width, level)
        if sketch_name == "cs":
            ret = cs_main(sketch_name, full_dir, row, width, level)
        if sketch_name == "cm":
            ret = cm_main(sketch_name, full_dir, row, width, level, xor_hash_type)
        result_list.append(ret)
    saver.save(result_list)
