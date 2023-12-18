from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.hash_module.py.hash import compute_hash

from sketch_control_plane.SketchLib.fcm_eval.common import get_miss_rate, get_ARE


width = 32768
row = 6


def counter_estimate(key, sketch_array, index_hash_sub_list, d, w, hash, level):
    a = []

    for i in range(0, d):
        # if i <= 3:
        #     index = compute_hash(key, hash, index_hash_sub_list[i], 65536)
        # else:
        index = compute_hash(key, hash, index_hash_sub_list[i], w)
        estimate = sketch_array[i * w + index]
        a.append(estimate)
        # print(estimate)
    a.sort()
    return a[0]

def cm_main(fn, topk):
    result = load_cm(fn, width, row)
    miss_rate = get_miss_rate(result["gt"], result["flowkey"], topk)
    print("[CM+O6] miss rate: %2.f%%" % miss_rate)

    gt_result = result["gt"]
    sampling_hash_list = result["sampling_hash_list"]

    index_hash_list = result["index_hash_list"]

    res_hash_list = result["res_hash_list"]
    sketch_array_list = result["sketch_array_list"]

    a = []
    count = 0
    for hh_elem in result["flowkey"]:
        count += 1
        flowkey = hh_elem[2]
        est = counter_estimate(flowkey, sketch_array_list[0], index_hash_list[0], row, width, "crc_hash", 0)
        # print(flowkey, est)
        a.append(est)
        # if count == 2:
        #     exit(1)

    a.sort(reverse=True)
    ARE = get_ARE(gt_result, a, topk)

    print("[CM+O6] ARE: %f%%" % ARE)
    return [miss_rate, ARE]

