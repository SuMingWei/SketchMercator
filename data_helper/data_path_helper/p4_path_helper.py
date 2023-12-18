from env_setting.env_module import p4_repo_path
import os

p4_sketch_lib_path = os.path.join(p4_repo_path, "p414", "open", "sketches", "SketchLib")

def sketch_lib_p4_path(sketch_name, p4_file_name):
    # mode = main or appendix
    full_p4_path = os.path.join(p4_sketch_lib_path, sketch_name, p4_file_name, "%s.p4" % p4_file_name)
    return full_p4_path

p4_sketchMD_path = os.path.join(p4_repo_path, "p414", "open", "sketches", "SketchMD")

def sketchMD_p4_path(sketch_name, p4_file_name):
    # mode = main or appendix
    full_p4_path = os.path.join(p4_sketchMD_path, sketch_name, "%s.p4" % p4_file_name)
    return full_p4_path
