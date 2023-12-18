import os
from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

def run_compile(workload_name, sketch_num_str, sample_num_str, bf, tofino):
    # cmd = "cd samples/gd/5_5/%s/%s/%s && comp2.sh %s %s 0" % (workload_name, sketch_num_str, sample_num_str, bf, tofino)
    # cmd = "cd samples_epoch/gd/5_5/%s/%s/%s && comp2.sh %s %s 0" % (workload_name, sketch_num_str, sample_num_str, bf, tofino)
    # cmd = "cd samples_epoch_nfs/gd/5_5/%s/%s/%s && comp2.sh %s %s 0" % (workload_name, sketch_num_str, sample_num_str, bf, tofino)
    cmd = "cd query_sketch/gd/5_5/%s/%s/%s && comp2.sh %s %s 0" % (workload_name, sketch_num_str, sample_num_str, bf, tofino)
    print(cmd)
    os.system(cmd)

# def run_compile_2(workload_name, sketch_num_str, sample_num_str, bf, tofino, n):
#     # cmd = "cd samples/gd/5_5/%s/%s/%s && comp2.sh %s %s 0" % (workload_name, sketch_num_str, sample_num_str, bf, tofino)
#     # cmd = "cd samples_epoch/gd/5_5/%s/%s/%s && comp2.sh %s %s %d" % (workload_name, sketch_num_str, sample_num_str, bf, tofino, n)
#     cmd = "cd samples_epoch_nfs/gd/5_5/%s/%s/%s && comp2.sh %s %s %d" % (workload_name, sketch_num_str, sample_num_str, bf, tofino, n)
#     print(cmd)
#     os.system(cmd)

# run_dict = {}
# run_dict["workload_1"] = [8, 9]
# run_dict["workload_2"] = [12, 13, 14, 19]
# run_dict["workload_3"] = [12, 13, 14]
# run_dict["workload_4"] = [11, 13]
# run_dict["workload_5"] = [10, 11, 14]

# count = 0
# for sample_num in range(1, 11):
#     if sample_num != 1:
#         continue
#     sample_num_str = "%02d" % sample_num

#     for sketch_num in range(2, 21, 2):
#     # for sketch_num in range(2, 15, 2):
#         if sketch_num != 2:
#             continue
#         sketch_num_str = "%02d" % sketch_num

#         for workload_name, v in run_dict.items():
#             if workload_name != "workload_1":
#                 continue

#             count += 2
#             run_compile(workload_name, sketch_num_str, sample_num_str, "before", "t1")
#             # run_compile(workload_name, sketch_num_str, sample_num_str, "after", "t1")
#             # helper.call(run_compile, (workload_name, sketch_num_str, sample_num_str, "before", "t1", ))
#             # helper.call(run_compile, (workload_name, sketch_num_str, sample_num_str, "after", "t1", ))
#             # exit(1)

# print(count)

# for n in range(1, 11):
#     # run_compile_2("workload_1", "10", "07", "before", "t1", n)
#     # exit(1)
#     helper.call(run_compile_2, ("workload_1", "10", "07", "before", "t1", n, ))

# print(count)

# helper.call(run_compile, ("workload_1", sketch_num_str, sample_num_str, "before", "t1", ))
# helper.call(run_compile, ("workload_1", sketch_num_str, sample_num_str, "after", "t1", ))

# run_dict = {}
# run_dict["o1a_testcase"] = ["o1a_case1", "o1a_case2", "o1a_case3", "o1a_case4"]
# run_dict["o1b_testcase"] = ["o1b_case1", "o1b_case2", "o1b_case3"]
# run_dict["o2a_testcase"] = ["o2a_case1", "o2a_case2"]
# run_dict["o2b_testcase"] = ["o2b_case1", "o2b_case2", "o2b_case3", "o2b_case4", "o2b_case5", "o2b_case6"]
# run_dict["o3_testcase"] = ["o3_case1", "o3_case2"]

# for workload_name, v in run_dict.items():
#     for case_name in sorted(v):
#         # sketch_num_str = "%02d" % sketch_num
#         helper.call(run_compile, (workload_name, case_name, "before", "t1", ))
#         helper.call(run_compile, (workload_name, case_name, "after", "t1", ))
#         # run_compile(workload_name, case_name, "after", "t1")
#         # exit(1)


# def run_compile(type, num):
#     print(type, num)
#     cmd = "cd bottleneck_analysis/%s/%02d && compile.sh" % (type, num)
#     print(cmd)
#     os.system(cmd)

# # type_list = ["p4all", "sketchlib"]
# type_list = ["p4all"]
# # type_list = ["sketchlib"]
# for type in type_list:
#     for num in range(1, 8):
#         # run_compile(type, num)
#         helper.call(run_compile, (type, num, ))


run_dict = {}
run_dict["set1"] = ["ensemble1", "ensemble2", "ensemble3", "ensemble4", "ensemble5"]

for workload_name, v in run_dict.items():
    for case_name in sorted(v):
        # sketch_num_str = "%02d" % sketch_num
        # helper.call(run_compile, (workload_name, case_name, "before", "t1", ))
        # helper.call(run_compile, (workload_name, case_name, "after", "t1", ))
        run_compile(workload_name, case_name, "01", "before", "t1")
        break
    
        # exit(1)
