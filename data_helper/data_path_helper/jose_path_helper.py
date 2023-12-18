from env_setting.env_module import result_resource_path
from env_setting.env_module import switch_compiler_path
import os

jose_python_path = os.path.join(switch_compiler_path, "mapper", "parser", "p4-compile.py")

def output_path(sketch_name, objective_str, p4_file_name, paper="SketchLib"):
    output_folder = os.path.join(result_resource_path, paper, "jose", sketch_name, objective_str)
    from python_lib.sys import hun_mkdir
    hun_mkdir(output_folder)
    output = os.path.join(output_folder, p4_file_name+".txt")
    output_log = os.path.join(output_folder, "log_"+p4_file_name+".txt")
    return output, output_log

def sketchMD_output_path(sketch_name, objective_str, p4_file_name, paper, target):
    output_folder = os.path.join(result_resource_path, paper, "jose", sketch_name, objective_str)
    from python_lib.sys import hun_mkdir
    hun_mkdir(output_folder)
    output = os.path.join(output_folder, target+"_"+p4_file_name+".txt")
    output_log = os.path.join(output_folder, "log_"+target+"_"+p4_file_name+".txt")
    return output, output_log
