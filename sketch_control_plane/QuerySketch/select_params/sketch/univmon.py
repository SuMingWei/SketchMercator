from sketch_control_plane.common.gsum_lib import ground_truth_entropy, ground_truth_cardinality
from sketch_control_plane.common.common import relative_error
from sketch_control_plane.common.univmon_lib import create_estimate_hh_dict_list, trim_by_topk, create_estimate_hh_dict_list_using_pq
from sketch_control_plane.common.gsum_lib import estimate_entropy_gsum, estimate_cardinality_gsum
from sw_dp_simulator.file_io.py.read_univmon import load_univmon
from sketch_control_plane.QuerySketch.select_params.sketch.common import get_miss_rate, get_ARE

def univmon_main(sketch_name, output_dir, row, width, level, arow):
    topk = 100
    # print("UNIV load start")
    result = load_univmon(output_dir, None, width, row, level)
    # result["gt"]
    # print(result.keys())

    gt_result_list = result["gt"]

    # hh_list = create_estimate_hh_dict_list(result, result["sketch_array_list"], row, width, level, "crc_hash", False)
    hh_list = create_estimate_hh_dict_list_using_pq(result, result["sketch_array_list"], row, width, level, "crc_hash", False)
    hh_list = trim_by_topk(hh_list, topk)
    # for k,v in hh_list[0].items():
    #     print(k, v)

    total, true_entropy = ground_truth_entropy(gt_result_list)

    # total = 734381062
    # true_entropy = 17.543519

    sim_entropy = estimate_entropy_gsum(hh_list, total)
    sim_entropy_error = relative_error(true_entropy, sim_entropy)

    total, true_card = ground_truth_cardinality(gt_result_list)

    # true_card = 30000000
    sim_card = estimate_cardinality_gsum(hh_list)
    sim_card_error = relative_error(true_card, sim_card)
    print(true_entropy, sim_entropy, sim_entropy_error, true_card, sim_card, sim_card_error)
    # print(hh_list[0])
    a = []
    for k, v in hh_list[0].items():
        # print(k, v)
        a.append(v[0])
    # print(a)
    ARE = get_ARE(gt_result_list, a, 50)
    print("[UnivMon] ARE: %f%%" % ARE)

    # return [true_entropy, sim_entropy, sim_entropy_error, true_card, sim_card, sim_card_error]
    return [true_entropy, sim_entropy, sim_entropy_error, true_card, sim_card, sim_card_error, ARE]
