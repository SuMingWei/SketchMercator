import os
from sketch_control_plane.QuerySketch.select_params.sketch.hll import hll_main
from sketch_control_plane.QuerySketch.select_params.sketch.cs import cs_main
from sketch_control_plane.QuerySketch.select_params.sketch.cm import cm_main
from sketch_control_plane.QuerySketch.select_params.sketch.univmon import univmon_main
from sketch_control_plane.QuerySketch.select_params.sketch.lc import lc_main
from sketch_control_plane.QuerySketch.select_params.sketch.mrac import mrac_main
from sketch_control_plane.QuerySketch.select_params.sketch.ll import ll_main
from sketch_control_plane.QuerySketch.select_params.sketch.mrb import mrb_main
from python_lib.pkl_saver import PklSaver

def sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level, arow):
    # print("come?")
    sim_dir = []
    for dir in sorted(os.listdir(output_dir)):
        p = os.path.join(output_dir, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)
    result_list = []
    for dir in sim_dir:
        full_dir = os.path.join(output_dir, dir)
        print(sketch_name, full_dir)
        if sketch_name == "hll":
            ret = hll_main(sketch_name, full_dir, row, width, level)
        elif sketch_name == "ll":
            ret = ll_main(sketch_name, full_dir, row, width, level)
        elif sketch_name == "lc":
            ret = lc_main(sketch_name, full_dir, row, width, level)
        elif sketch_name == "cm":
            ret = cm_main(sketch_name, full_dir, row, width, level, arow)
        elif sketch_name == "cs":
            ret = cs_main(sketch_name, full_dir, row, width, level, arow)
        elif sketch_name == "univmon":
            ret = univmon_main(sketch_name, full_dir, row, width, level, arow)
        elif sketch_name == "mrac":
            ret = mrac_main(sketch_name, full_dir, row, width, level)
        elif sketch_name == "mrb":
            ret = mrb_main(sketch_name, full_dir, row, width, level)
        result_list.append(ret)
    saver = PklSaver(output_pkl_dir, "data.pkl")
    saver.save(result_list)
