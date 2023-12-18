import os
from parallel_run_script.jose.common import jose_run_cmd
from data_helper.data_path_helper.p4_path_helper import sketch_lib_p4_path
from data_helper.data_path_helper.jose_path_helper import output_path

cmd_list = []
log_str_list = []

# for sketch_name in ['01_CS', '03_UnivMon', '04_RHHH']:
for sketch_name in ['03_UnivMon', '04_RHHH']:

    if sketch_name == '01_CS':
        name_template = "p414_original_cs_simple_row_%02d"
        row_list = [1, 2, 3, 4, 5]
        level_list = [1, 1, 1, 1, 1]

    if sketch_name == '03_UnivMon':
        name_template = "p414_original_univmon_simple_row_%02d_level_%02d"
        # row_list =   [ 1,  2,  3,  4,  5, 5, 5,  5,  5]
        # level_list = [16, 16, 16, 16, 16, 4, 8, 12, 20]
        # row_list =   [5, 5,  5, 5, 5]
        # level_list = [4, 8, 12, 16, 20]
        row_list =   [3, 3,  3, 3, 3]
        level_list = [4, 8, 12, 16, 20]

    if sketch_name == '04_RHHH':
        name_template = "p414_original_rhhh_simple_row_%02d_level_%02d"
        # row_list =   [ 1,  2,  3,  4,  5, 5, 5,  5,  5,  5]
        # level_list = [25, 25, 25, 25, 25, 4, 8, 12, 16, 20]
        # row_list =   [5, 5,  5,  5,  5]
        # level_list = [4, 8, 12, 16, 20]
        row_list =   [3, 3,  3,  3,  3]
        level_list = [4, 8, 12, 16, 20]

    objective_str = 'maximumStage'
    for row, level in zip(row_list, level_list):
        if sketch_name == '01_CS':
            p4_file_name = name_template % (row)
            gap = 0.08
            switch_target = 'RmtTofino12'
        else:
            p4_file_name = name_template % (row, level)
            gap = 0.08
            switch_target = 'RmtTofino45'

        full_p4_path = sketch_lib_p4_path(sketch_name, p4_file_name)
        output, output_log = output_path(sketch_name, objective_str, p4_file_name)
        cmd = jose_run_cmd(objective_str, full_p4_path, output, output_log, switch_target, gap)
        cmd_list.append(cmd)
        log_str = "%s" % (p4_file_name)
        log_str_list.append(log_str)

for cmd in cmd_list:
    print(cmd)
print(len(cmd_list))

from python_lib.run_parallel_helper import ParallelRunHelper
helper = ParallelRunHelper(70)

from multiprocessing import Process, current_process
def run_cmd_func(cmd, log_str):
	print("[by thread %s] %s" % (current_process().name, log_str))
	os.system(cmd)
	print("[Done] %s" % (log_str))


count = 0
for cmd, log_str in zip(cmd_list, log_str_list):
    count += 1
    log_str = ("%d " % count) + log_str
    print(log_str)
    # run_cmd_func(cmd, log_str)
    helper.call(run_cmd_func, [cmd, log_str])

