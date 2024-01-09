from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.hash_module.py.hash import compute_hash
from error_estimator.control_plane.sketch.common import write_file_fsd

import os

def counter_estimate(key, sketch_array, index_hash_sub_list, res_hash_sub_list, d, w, hash, level):
    a = []

    for i in range(0, d):
        index = compute_hash(key, hash, index_hash_sub_list[i], w)
        estimate = sketch_array[i * w + index]
        a.append(estimate)

    return min(a)

def get_flow_size_distribution(result, row, width):
    cArray = result["sketch_array_list"][0]
    gt_result = result["gt"]
    index_hash_list = result["index_hash_list"]
    res_hash_list = result["res_hash_list"]

    true_distribution = {}
    est_distribution = {}
    for i in range(0, len(gt_result)):
        true_flow_count = gt_result[i][1]
        flowkey = gt_result[i][2]

        if true_flow_count in true_distribution:
            true_distribution[true_flow_count] += 1
        else:
            true_distribution[true_flow_count] = 1

        est = counter_estimate(flowkey, cArray, index_hash_list[0], res_hash_list[0], row, width, "crc_hash", 0)
        if est in est_distribution:
            est_distribution[est] += 1
        else:
            est_distribution[est] = 1
    
    # print(est_distribution)

    WMRD_nom = 0
    WMRD_denom = 0

    for key in true_distribution:
        true = true_distribution[key]
        if key in est_distribution:
            est = est_distribution[key]
        else:
            est = 0

        WMRD_nom += abs(true - est)
        WMRD_denom += float(true + est)/2
    WMRD = WMRD_nom/WMRD_denom    
    
    # print(f'WMRD: {WMRD}')
    
    return dict(sorted(true_distribution.items())), dict(sorted(est_distribution.items())), WMRD


def cm_main(sketch_name, dist_dir, output_dir, row, width, level, arow):
    result = load_cm(output_dir, width, row)

    true_d, est_d, WMRD = get_flow_size_distribution(result, arow, width)

    os.makedirs(dist_dir, exist_ok=True)
    
    real_fsd_file = os.path.join(dist_dir, "real_dist.txt")
    esti_fsd_file = os.path.join(dist_dir, "esti_dist.txt")
    error_file = os.path.join(dist_dir, "error.txt")
    write_file_fsd(list(true_d.keys()), list(true_d.values()), real_fsd_file)
    write_file_fsd(list(est_d.keys()), list(est_d.values()), esti_fsd_file)
    with open(error_file, 'w') as file:
        file.write(str(WMRD))
    print(WMRD)
