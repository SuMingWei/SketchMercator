import importlib

def load_param_list(sketch_name, mode):
    full_module_name = "pcap_sender.SketchAug.configs." + sketch_name
    mymodule = importlib.import_module(full_module_name)
    if mode == "baseline":
        return mymodule.baseline_epoch_list, mymodule.baseline_array_size_dict
    if mode == "pingpong":
        return mymodule.pingpong_epoch_list, mymodule.pingpong_array_size_dict
    if mode == "noreset":
        return mymodule.noreset_epoch_list, mymodule.noreset_array_size_dict
    if mode == "sol3":
        return mymodule.sol3_epoch_list, mymodule.sol3_array_size_dict
    if mode == "sol3cpp":
        return mymodule.sol3cpp_epoch_list, mymodule.sol3cpp_array_size_dict
