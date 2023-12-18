from sw_dp_simulator.file_io.py.read_univmon import load_univmon
from sketch_control_plane.SketchAug.lib.common import counter_diff, relative_error

import os



def univmon_main(file_name, sketch_name, mode, array_size, epoch, tofino_counters, sim_full_path):
    # print(sim_full_path)
    t = 200
    w = int(array_size/16)
    l = 16
    d = 4
    bname = os.path.basename(sim_full_path)
    # print(bname)
    # if bname != "03":
    #     return
    result = load_univmon(sim_full_path, t, w, d, l)
    if result['count_list'][0] == 0:
        return (0, 0, 0, 0, 0, 0, 0, 0)
    array1 = []
    array2 = []
    array3 = []
    array4 = []
    tofino_counters_level = []

    for i in range(0, l):
        tfl = []
        tfl += tofino_counters[32768*0+i*w:32768*0+(i+1)*w]
        tfl += tofino_counters[32768*1+i*w:32768*1+(i+1)*w]
        tfl += tofino_counters[32768*2+i*w:32768*2+(i+1)*w]
        tfl += tofino_counters[32768*3+i*w:32768*3+(i+1)*w]
        tofino_counters_level.append(tfl)
        result["sketch_array_list"][i]
        array1 += result["sketch_array_list"][i][0:w]
        array2 += result["sketch_array_list"][i][w:2*w]
        array3 += result["sketch_array_list"][i][2*w:3*w]
        array4 += result["sketch_array_list"][i][3*w:]
    sim_total = array1 + array2 + array3 + array4

    gt_result_list = result["gt"]

    wrong, sum = counter_diff(sim_total, tofino_counters)
    # print(wrong, sum)

    from sketch_control_plane.SketchAug.lib.gsum_lib import ground_truth_entropy
    total, true_entropy = ground_truth_entropy(gt_result_list)
    
    from sketch_control_plane.SketchAug.lib.univmon_lib import create_estimate_hh_dict_list, trim_by_topk
    from sketch_control_plane.SketchAug.lib.gsum_lib import estimate_entropy_gsum, estimate_cardinality_gsum

    topk = 100
    hh_list = create_estimate_hh_dict_list(result, result["sketch_array_list"], d, w, l, "crc_hash", True)
    hh_list = trim_by_topk(hh_list, topk)
    sim_entropy = estimate_entropy_gsum(hh_list, total)
    sim_error = relative_error(true_entropy, sim_entropy)

    hh_list = create_estimate_hh_dict_list(result, tofino_counters_level, d, w, l, "crc_hash", True)
    hh_list = trim_by_topk(hh_list, topk)
    tofino_entropy = estimate_entropy_gsum(hh_list, total)
    tofino_error = relative_error(true_entropy, tofino_entropy)

    tuple = (wrong, sum, array_size * 4, true_entropy, sim_entropy, sim_error, tofino_entropy, tofino_error)
    print("wrong_count(%d) wrong_sum(%d) total_array_size(%d) true(%f) sim(%f) sim_error(%.2f) tofino(%f) tofino_error(%.2f)" % tuple)

    return tuple
