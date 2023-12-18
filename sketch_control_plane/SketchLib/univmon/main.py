import os

from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import result_cp_path
from env_setting.env_module import sw_dp_simulator_path

from sketch_control_plane.common.gsum_lib import ground_truth_entropy, ground_truth_cardinality
from sketch_control_plane.common.common import relative_error
from sketch_control_plane.common.univmon_lib import create_estimate_hh_dict_list, trim_by_topk, create_estimate_hh_dict_list_using_pq
from sketch_control_plane.common.gsum_lib import estimate_entropy_gsum, estimate_cardinality_gsum
from sw_dp_simulator.file_io.py.read_univmon import load_univmon
from sketch_control_plane.SketchLib.fcm_eval.common import get_miss_rate, get_ARE

def univmon_main(fn, t, width, row, level, flag, topk):
    print("load start")
    result = load_univmon(fn, t, width, row, level)
    # result["gt"]
    # print(result.keys())

    gt_result_list = result["gt"]

    # hh_list = create_estimate_hh_dict_list(result, result["sketch_array_list"], row, width, level, "crc_hash", flag)
    hh_list = create_estimate_hh_dict_list_using_pq(result, result["sketch_array_list"], row, width, level, "crc_hash", flag)
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
    # ARE = get_ARE(gt_result_list, a, 50)
    # print("[UnivMon] ARE: %f%%" % ARE)

    return [true_entropy, sim_entropy, sim_entropy_error, true_card, sim_card, sim_card_error]
    # return [true_entropy, sim_entropy, sim_entropy_error, true_card, sim_card, sim_card_error, ARE]

from python_lib.pkl_saver import PklSaver
def sketch_cp(sketch_name, pcap_file_name, width, row, level, flag, seed, topk, output_dir, output_pkl_dir):
    # str = "row_%d_level_%d_width_%d" % (row, level, width)
    # if flag:
    #     str = "optimized/row_%d_level_%d_width_%d" % (row, level, width)
    # else:
    #     str = "original/row_%d_level_%d_width_%d" % (row, level, width)
    # str2 = "%02d.txt" % seed

    # output_dir = os.path.join(result_sw_dp_path, "SketchLib", sketch_name, pcap_file_name, str, str2)

    result_list = []
    # pkl_path = os.path.join(result_cp_path, "SketchLib", sketch_name, pcap_file_name, str, str2)
    saver = PklSaver(output_pkl_dir, "data.pkl")
    for fn in sorted(os.listdir(output_dir)):
        print("epoch", fn)
        result = univmon_main(os.path.join(output_dir,fn), 200, width, row, level, flag, topk)
        result_list.append(result)
    saver.save(result_list)
