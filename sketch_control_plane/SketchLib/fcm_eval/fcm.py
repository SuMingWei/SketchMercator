from sw_dp_simulator.file_io.py.read_fcm import load_fcm
from sw_dp_simulator.hash_module.py.hash import compute_hash
from sketch_control_plane.SketchLib.fcm_eval.common import get_miss_rate, get_ARE

def counter_estimate(key, sketch_array, index_hash_sub_list, d, w, hash, level):
    est1=0
    index0 = compute_hash(key, hash, index_hash_sub_list[0], w)
    index1 = index0 >> 3;
    index2 = index0 >> 6;

    est2=0
    index3 = compute_hash(key, hash, index_hash_sub_list[1], w)
    index4 = index3 >> 3;
    index5 = index3 >> 6;


    if sketch_array[0 * w + index0] <= 254:
        est1 = sketch_array[0 * w + index0]
    else:
        if sketch_array[1 * w + index1] <= 65534:
            est1 = 254 + sketch_array[1 * w + index1]
        else:
            est1 = 254 + 65534 + sketch_array[2 * w + index2]
    
    if sketch_array[3 * w + index3] <= 254:
        est2 = sketch_array[3 * w + index3]
    else:
        if sketch_array[4 * w + index4] <= 65534:
            est2 = 254 + sketch_array[4 * w + index4]
        else:
            est2 = 254 + 65534 + sketch_array[5 * w + index5]

    if est1 > est2:
        return est2

    return est1

from sketch_control_plane.common.gsum_lib import ground_truth_entropy

def fcm_main(fn, topk):

    result = load_fcm(fn, 524288, 6)
    gt_result = result["gt"]
    sampling_hash_list = result["sampling_hash_list"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]
    sketch_array_list = result["sketch_array_list"]

    # total, true_entropy = ground_truth_entropy(gt_result)
    # print(true_entropy)

    
    O6_miss_rate = get_miss_rate(gt_result, result["flowkey"], topk)
    print("[FCM+O6] miss rate: %2.f%%" % O6_miss_rate)

    a = []
    for i, hh_elem in enumerate(result["flowkey"]):
        flowkey = hh_elem[2]
        est = counter_estimate(flowkey, sketch_array_list[0], index_hash_list[0], 6, 524288, "crc_hash", 0)
        # print(i, hh_elem, est)
        a.append(est)
    a.sort(reverse=True)
    O6_ARE = get_ARE(gt_result, a, topk)
    print("[FCM+O6] ARE: %f%%" % O6_ARE)

    topk_miss_rate = get_miss_rate(gt_result, result["flowkey_topk"], topk)
    print("[FCM+topK] miss rate: %2.f%%" % topk_miss_rate)

    a = []
    for i, hh_elem in enumerate(result["flowkey_topk"]):
        flowkey = hh_elem[2]
        est = counter_estimate(flowkey, sketch_array_list[1], index_hash_list[1], 6, 524288, "crc_hash", 1)
        # print(i, hh_elem, est)
        a.append(hh_elem[1]+est)
    a.sort(reverse=True)
    topk_ARE = get_ARE(gt_result, a, topk)
    print("[FCM+O6] ARE: %f%%" % topk_ARE)


    return [O6_miss_rate, O6_ARE, topk_miss_rate, topk_ARE]
