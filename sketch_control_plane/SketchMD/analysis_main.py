from parallel_run_script.control_plane.SketchMD.lib import get_params, get_overall_flowkey
from sketch_control_plane.SketchMD.lib.cm import get_CM_ARE
from sketch_control_plane.SketchMD.lib.kary import get_kary_ARE
from sketch_control_plane.SketchMD.lib.cs import get_CS_ARE
from sketch_control_plane.SketchMD.lib.mrb import get_mrb_error
from sketch_control_plane.SketchMD.lib.hll import get_hll_error
from sketch_control_plane.SketchMD.lib.pcsa import get_pcsa_error
from sketch_control_plane.SketchMD.lib.mrac import get_mrac_error

from sketch_control_plane.SketchMD.lib.lc import get_lc_error

from sketch_control_plane.SketchMD.lib.univmon import get_univmon_error
from sketch_control_plane.SketchMD.lib.entropy import get_entropy_error
from sketch_control_plane.SketchMD.lib.hf import find_miss_flowkey_before, find_miss_flowkey_after


import os

def analysis_main(metadata, counter_data, gt_path_dict, hf_data, caida_date):
    workload_name, bf, program_name, pcap_file_name = metadata
    inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list = get_params(workload_name, bf)
    # flowkey, hfkey = get_overall_flowkey(workload_name)
    for inst_name, sketch_name, flowkey, flowsize, id, row, width, level, epoch, hfkey, threshold, type, limit_row in zip(inst_name_list, sketch_name_list, flowkey_list, flowsize_list, id_list, row_list, width_list, level_list, epoch_list, hfkey_list, threshold_list, type_list, limit_row_list):

        # if inst_name != "inst10":
        #     continue
        # if inst_name != "inst2":
        #     continue
        # if sketch_name == "UnivMon" or sketch_name == "MRAC":
        #     continue
        # if sketch_name != "MRAC":
        #     continue
        # if sketch_name != "Kary":
        #     continue
        if sketch_name != "Entropy":
            continue

        from python_lib.pkl_saver import PklSaver
        SKETCH_CONTROL_PLANE = os.getenv('sketch_control_plane')
        path = os.path.join(SKETCH_CONTROL_PLANE, "SketchMD", "result", workload_name, caida_date, bf, pcap_file_name, inst_name)
        result_list = []

        print()
        print(inst_name, sketch_name)

        if sketch_name == "Kary":
            key_list = list(counter_data[inst_name].keys())
            for i in range(0, len(key_list)-1):
                key1 = key_list[i]
                key2 = key_list[i+1]
                ARE = get_kary_ARE(gt_path_dict[inst_name][key1], counter_data[inst_name][key1], gt_path_dict[inst_name][key2], counter_data[inst_name][key2], threshold)
                result_list.append(ARE)
                print(key1, key2, "%.2f" % ARE)
        else:
            for key in counter_data[inst_name].keys(): # epoch
                if sketch_name == "UnivMon":
                    param = (width, level)
                    if bf == "before":
                        error = get_univmon_error(bf, param, gt_path_dict[inst_name][key], counter_data[inst_name][key], hf_data[inst_name][key], 0, 0, hfkey, flowkey)
                    else:
                        start = int(key)-int(epoch/10)+1
                        end = int(key)
                        error = get_univmon_error(bf, param, gt_path_dict[inst_name][key], counter_data[inst_name][key], hf_data, start, end, hfkey, flowkey)
                    result_list.append(error)
                    print(key, "%.2f" % error)

                if sketch_name == "HLL":
                    param = (width)
                    error = get_hll_error(param, gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(error)
                    print(key, "%.2f" % error)

                if sketch_name == "PCSA":
                    param = (width)
                    error = get_pcsa_error(param, gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(error)
                    print(key, "%.2f" % error)

                if sketch_name == "MRB":
                    param = (width, level)
                    error = get_mrb_error(param, gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(error)
                    print(key, "%.2f" % error)

                if sketch_name == "Entropy":
                    # print(key)
                    error = get_entropy_error(gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(error)
                    print(key, "%.2f" % error)
                    # break

                if sketch_name == "CountMin":
                    ARE = get_CM_ARE(gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(ARE)
                    print(key, "%.2f" % ARE)
                    # break

                if sketch_name == "CountSketch":
                    ARE = get_CS_ARE(gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(ARE)
                    print(key, "%.2f" % ARE)
                    # import statistics
                    # print(statistics.median(result_list))

                if sketch_name == "LinearCounting":
                    param = width
                    error = get_lc_error(param, gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    result_list.append(error)
                    print(key, "%.2f" % error)

                if sketch_name == "MRAC":
                    param = (width, level)
                    WMRD = get_mrac_error(param, gt_path_dict[inst_name][key], counter_data[inst_name][key])
                    print(key, WMRD)
                    result_list.append(WMRD)
                    print()

        if len(result_list) > 0:
            saver = PklSaver(path, "data.pkl")
            saver.save(result_list)

        result_list = []
        # print()
        # print(inst_name, sketch_name)
        for key in counter_data[inst_name].keys(): # epoch
            if sketch_name == "CountMin" or sketch_name == "CountSketch" or sketch_name == "Kary" or sketch_name == "UnivMon":
                if bf == "before":
                    # print(key)
                    key_found, key_miss = find_miss_flowkey_before(gt_path_dict[inst_name][key], hf_data[inst_name][key], counter_data[inst_name][key])
                    # print(key, key_found, key_miss)
                    result_list.append((key_found, key_miss))
                else:
                    start = int(key)-int(epoch/10)+1
                    end = int(key)
                    key_found, key_miss = find_miss_flowkey_after(gt_path_dict[inst_name][key], hf_data, counter_data[inst_name][key], start, end, hfkey, flowkey)
                    # print(key, start, end, key_found, key_miss)
                    result_list.append((key_found, key_miss))

        if len(result_list) > 0:
            saver = PklSaver(path, "hf.pkl")
            saver.save(result_list)

