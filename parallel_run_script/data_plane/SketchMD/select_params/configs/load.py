import importlib

def load_param_list(sketch_name):
    full_module_name = "parallel_run_script.data_plane.SketchMD.configs." + sketch_name+"_config"
    print(full_module_name)
    mymodule = importlib.import_module(full_module_name)
    ret = {}
    ret["key_list"] = mymodule.key_list
    ret["epoch_list"] = mymodule.epoch_list
    ret["width_list"] = mymodule.width_list
    ret["row_list"] = mymodule.row_list
    ret["level_list"] = mymodule.level_list
    ret["seed_list"] = mymodule.seed_list
    ret["xor_hash_type_list"] = mymodule.xor_hash_type_list
    return ret
