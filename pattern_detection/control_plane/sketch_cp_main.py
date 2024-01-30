import os
from pattern_detection.control_plane.sketch.cm import cm_main

def sketch_cp(sketch_name, output_dir, output_pkl_dir, row, width, level, arow):
    # print("come?")
    sim_dir = []
    for dir in sorted(os.listdir(output_dir)):
        p = os.path.join(output_dir, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)
            
    for dir in sim_dir: # different epoch
        full_dir = os.path.join(output_dir, dir)
        dist_dir = os.path.join(output_pkl_dir, dir)
        print(sketch_name, full_dir)
        
        if sketch_name == "cm":
            cm_main(full_dir, dist_dir, row, width, level)
        # elif sketch_name == "cs":
        #     cs_main(sketch_name, dist_dir, full_dir, row, width, level, arow)
        # elif sketch_name == "mrac":
        #     mrac_main(sketch_name, dist_dir, full_dir, row, width, level)

