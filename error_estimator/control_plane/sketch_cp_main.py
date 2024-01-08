import os
from error_estimator.control_plane.sketch.cs import cs_main
from error_estimator.control_plane.sketch.cm import cm_main
from error_estimator.control_plane.sketch.mrac import mrac_main
from python_lib.pkl_saver import PklSaver

def sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level, arow):
    # print("come?")
    sim_dir = []
    for dir in sorted(os.listdir(output_dir)):
        p = os.path.join(output_dir, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)
            
    for dir in sim_dir:
        full_dir = os.path.join(output_dir, dir)
        dist_dir = os.path.join(output_pkl_dir, dir)
        print(sketch_name, full_dir)
        if sketch_name == "cm":
            cm_main(sketch_name, dist_dir, full_dir, row, width, level, arow)
        elif sketch_name == "cs":
            cs_main(sketch_name, dist_dir, full_dir, row, width, level, arow)
        elif sketch_name == "mrac":
            mrac_main(sketch_name, dist_dir, full_dir, row, width, level)

    # saver = PklSaver(output_pkl_dir, "data.pkl")
    # saver.save(result_list)
