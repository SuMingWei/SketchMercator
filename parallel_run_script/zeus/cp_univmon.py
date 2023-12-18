from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
from env_setting.env_module import result_sw_dp_path
from env_setting.env_module import result_gt_path
from env_setting.env_module import sw_dp_simulator_path

import os

from sw_dp_simulator.file_io.py.read_univmon import load_univmon
from sketch_control_plane.lib.common import counter_diff, relative_error

def call_entropy(sim_full_path):
    t = 200
    w = 2048
    l = 16
    d = 5

    print(sim_full_path)
    basename = os.path.basename(sim_full_path)
    fn = os.path.join("http", "entropy", basename + ".txt")
    f = open(fn, "w")
    log = "epoch total_packet_count true_entropy univmon_entropy relative_error(%)\n"
    print(log)
    f.write(log)

    for epoch in range(1, 61):
        path = os.path.join(sim_full_path, "01.txt", "%02d" % epoch)
        result = load_univmon(path, t, w, d, l)

        gt_result_list = result["gt"]
        from sketch_control_plane.lib.gsum_lib import ground_truth_entropy
        total, true_entropy = ground_truth_entropy(gt_result_list)

        from sketch_control_plane.lib.univmon_lib import create_estimate_hh_dict_list, trim_by_topk
        from sketch_control_plane.lib.gsum_lib import estimate_entropy_gsum, estimate_cardinality_gsum

        topk = 100
        hh_list = create_estimate_hh_dict_list(result, result["sketch_array_list"], d, w, l, "crc_hash", True)
        hh_list = trim_by_topk(hh_list, topk)
        sim_entropy = estimate_entropy_gsum(hh_list, total)
        sim_error = relative_error(true_entropy, sim_entropy)
        log = "%d %d %f %f %.2f\n" % (epoch, total, true_entropy, sim_entropy, sim_error)
        print(log)
        f.write(log)

def call_cardinality(sim_full_path):
    t = 200
    w = 2048
    l = 16
    d = 5

    print(sim_full_path)
    basename = os.path.basename(sim_full_path)
    fn = os.path.join("http", "cardinality", basename + ".txt")
    f = open(fn, "w")
    # log = "epoch total_packet_count true_cardinality univmon_cardinality relative_error(%)\n"
    log = "epoch total_packet_count true_cardinality\n"
    print(log)
    f.write(log)

    for epoch in range(1, 61):
        path = os.path.join(sim_full_path, "01.txt", "%02d" % epoch)
        result = load_univmon(path, t, w, d, l)

        gt_result_list = result["gt"]
        from sketch_control_plane.lib.gsum_lib import ground_truth_cardinality
        total, true_cardinality = ground_truth_cardinality(gt_result_list)

        # log = "%d %d %d\n" % (epoch, total, true_cardinality)
        # print(log)
        # f.write(log)

        from sketch_control_plane.lib.univmon_lib import create_estimate_hh_dict_list, trim_by_topk
        from sketch_control_plane.lib.gsum_lib import estimate_entropy_gsum, estimate_cardinality_gsum

        topk = 100
        hh_list = create_estimate_hh_dict_list(result, result["sketch_array_list"], d, w, l, "crc_hash", True)
        hh_list = trim_by_topk(hh_list, topk)
        sim_cardinality = estimate_cardinality_gsum(hh_list)
        sim_error = relative_error(true_cardinality, sim_cardinality)
        log = "%d %d %d %d %.2f\n" % (epoch, total, true_cardinality, sim_cardinality, sim_error)
        print(log)
        f.write(log)

def call_heavy_hitter(sim_full_path):
    t = 200
    w = 2048
    l = 16
    d = 5

    print(sim_full_path)
    basename = os.path.basename(sim_full_path)
    fn = os.path.join("dns", "heavy_hitter", basename + ".txt")
    f = open(fn, "w")
    log = "epoch dstIP_top1_packet_count\n"
    print(log)
    f.write(log)

    for epoch in range(1, 61):
        path = os.path.join(sim_full_path, "01.txt", "%02d" % epoch)
        result = load_univmon(path, t, w, d, l)

        from sketch_control_plane.lib.univmon_lib import create_estimate_hh_dict_list, trim_by_topk

        topk = 100
        hh_list = create_estimate_hh_dict_list(result, result["sketch_array_list"], d, w, l, "crc_hash", True)
        hh_list = trim_by_topk(hh_list, topk)
        for z, (k, v) in enumerate(hh_list[0].items()):
            # print(z, k, v)
            break
        log = "%d %d\n" % (epoch, v[0])
        print(log)
        f.write(log)

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

# pcap_input_folder = os.path.join(pcap_storage_path, "zeus", "syn")

# file_list = []
# for file_name in sorted(os.listdir(pcap_input_folder)):
#     if file_name.endswith(".pcap"):
#         if file_name != "small.pcap":
#             file_list.append(file_name)

# sim_list = []

# for file_name in file_list:
#     sim_full_path = os.path.join(result_sw_dp_path, "zeus", "syn", file_name)
#     sim_list.append(sim_full_path)

# for sim_full_path in sim_list:
#     # call_entropy(sim_full_path)
#     # call_cardinality(sim_full_path)
#     helper.call(call_entropy, (sim_full_path, ))
#     helper.call(call_cardinality, (sim_full_path, ))


# pcap_input_folder = os.path.join(pcap_storage_path, "zeus", "dns")

# file_list = []
# for file_name in sorted(os.listdir(pcap_input_folder)):
#     if file_name.endswith(".pcap"):
#         if file_name != "small.pcap":
#             file_list.append(file_name)

# sim_list = []

# for file_name in file_list:
#     sim_full_path = os.path.join(result_sw_dp_path, "zeus", "dns", file_name)
#     sim_list.append(sim_full_path)

# for sim_full_path in sim_list:
#     # call_heavy_hitter(sim_full_path)
#     helper.call(call_heavy_hitter, (sim_full_path, ))

# #     # call_entropy(sim_full_path)
# #     # call_cardinality(sim_full_path)
# #     helper.call(call_entropy, (sim_full_path, ))
# #     helper.call(call_cardinality, (sim_full_path, ))



pcap_input_folder = os.path.join(pcap_storage_path, "zeus", "http")

file_list = []
for file_name in sorted(os.listdir(pcap_input_folder)):
    if file_name.endswith(".pcap"):
        if file_name != "small.pcap":
            file_list.append(file_name)

sim_list = []

for file_name in file_list:
    sim_full_path = os.path.join(result_sw_dp_path, "zeus", "http", file_name)
    sim_list.append(sim_full_path)

for sim_full_path in sim_list:
    # call_entropy(sim_full_path)
    # helper.call(call_heavy_hitter, (sim_full_path, ))

    # call_cardinality(sim_full_path)
    helper.call(call_cardinality, (sim_full_path, ))
    # call_entropy(sim_full_path)
    # break


# pcap_input_folder = os.path.join(pcap_storage_path, "caida", "20140320", "60s")

# file_list = []
# for file_name in sorted(os.listdir(pcap_input_folder)):
#     if file_name.endswith(".pcap"):
#         if file_name != "small.pcap":
#             file_list.append(file_name)

# sim_list = []

# for file_name in file_list:
#     sim_full_path = os.path.join(result_sw_dp_path, "zeus", "5-tuple", file_name)
#     sim_list.append(sim_full_path)

# for sim_full_path in sim_list:
#     # call_cardinality(sim_full_path)
#     helper.call(call_cardinality, (sim_full_path, ))

#     # call_entropy(sim_full_path)
#     # break
