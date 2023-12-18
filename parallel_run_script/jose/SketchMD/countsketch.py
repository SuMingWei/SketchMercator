import os
from parallel_run_script.jose.common import jose_run_cmd
from data_helper.data_path_helper.p4_path_helper import sketchMD_p4_path
from data_helper.data_path_helper.jose_path_helper import sketchMD_output_path as output_path

cmd_list = []
log_str_list = []

for sketch_name in ['countsketch']:
    row_list = []
    width_list = []
    instance_list = []
    switch_list = []
    p4_file_name_list = []

    if sketch_name == 'countsketch':
        name_template = "opt_countsketch_row_%d_width_%d_instance_%d"
        # for row, width in zip([3, 5], [8192, 16384]):
        # # for row, width in zip([5], [16384]):
        #     # for instance in [3, 4]:
        #     for instance in range(1, 10):
        #         # for switch in ["RmtTofino45", "no_constraint_45"]:
        #         # for switch in ["RmtTofino45"]:
        #         # for switch in ["no_constraint_45"]:
        #         for switch in ["SALU_constraint_45", "HASH_constraint_45", "SRAM_constraint_45"]:
        #         # for switch in ["RmtTofino45", "salu_bottleneck_45", "sram_bottleneck_45", "hash_bottleneck_45"]:
        #             row_list.append(row)
        #             width_list.append(width)
        #             instance_list.append(instance)
        #             switch_list.append(switch)
        #             p4_file_name_list.append(name_template % (row, width, instance))

        # row_list.append(3)
        # width_list.append(8192)
        # instance_list.append(4)
        # # switch_list.append("SALU_constraint_45")
        # switch_list.append("SALU_constraint_20")
        # p4_file_name_list.append(name_template % (3, 8192, 4))

        # row_list.append(5)
        # width_list.append(16384)
        # instance_list.append(3)
        # switch_list.append("HASH_constraint_20")
        # p4_file_name_list.append(name_template % (5, 16384, 3))

        # row_list.append(5)
        # width_list.append(16384)
        # instance_list.append(4)
        # switch_list.append("HASH_constraint_20")
        # p4_file_name_list.append(name_template % (5, 16384, 4))

        # row_list.append(5)
        # width_list.append(16384)
        # instance_list.append(5)
        # switch_list.append("HASH_constraint_20")
        # p4_file_name_list.append(name_template % (5, 16384, 5))

        row_list.append(5)
        width_list.append(16384)
        instance_list.append(9)
        switch_list.append("HASH_constraint_20")
        p4_file_name_list.append(name_template % (5, 16384, 9))

        # row_list.append(5)
        # width_list.append(16384)
        # instance_list.append(8)
        # switch_list.append("SALU_constraint_20")
        # p4_file_name_list.append(name_template % (5, 16384, 8))

    objective_str = 'maximumStage'
    # gap = 0.2
    # gap = 0.08
    gap = 0.02
    # gap = 0.005
    count = 0
    for row, width, instance, switch, p4_file_name in zip(row_list, width_list, instance_list, switch_list, p4_file_name_list):
        count += 1
        print(count, row, width, instance, switch, p4_file_name)
        output, output_log = output_path(sketch_name, objective_str, p4_file_name, "SketchMD", switch)
        full_p4_path = sketchMD_p4_path(sketch_name, p4_file_name)
        # full_p4_path = "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchLib/01_CS/p414_original_cs_simple_row_01/p414_original_cs_simple_row_01.p4"
        cmd = jose_run_cmd(objective_str, full_p4_path, output, output_log, switch, gap)
        cmd_list.append(cmd)
        log_str = "[%s] %s" % (switch, p4_file_name)
        log_str_list.append(log_str)
        # if count == 2:
        #     break

for cmd in cmd_list:
    print(cmd)
print(len(cmd_list))

# from python_lib.run_parallel_helper import ParallelRunHelper
# helper = ParallelRunHelper(70)

# from multiprocessing import Process, current_process
# def run_cmd_func(cmd, log_str):
# 	print("[by thread %s] %s" % (current_process().name, log_str))
# 	os.system(cmd)
# 	print("[Done] %s" % (log_str))


# count = 0
# for cmd, log_str in zip(cmd_list, log_str_list):
#     count += 1
#     log_str = ("[%d] " % count) + log_str
#     print(log_str)
#     # run_cmd_func(cmd, log_str)
#     helper.call(run_cmd_func, [cmd, log_str])

