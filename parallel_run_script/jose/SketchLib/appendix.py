import os
from parallel_run_script.jose.common import jose_run_cmd
from data_helper.data_path_helper.p4_path_helper import sketch_lib_p4_path
from data_helper.data_path_helper.jose_path_helper import output_path

cmd_list = []
log_str_list = []

for sketch_name in ['03_UnivMon', '04_RHHH', '06_HLL', '07_PCSA', '08_MRB']:
# for sketch_name in ['04_RHHH']:
# for sketch_name in ['03_UnivMon']:

    if sketch_name == '03_UnivMon':
        name_template = "p414_original_univmon_simple_row_%02d_level_%02d"

    if sketch_name == '04_RHHH':
        name_template = "p414_original_rhhh_simple_row_%02d_level_%02d"

    if sketch_name == '06_HLL':
        name_template = "p414_original_hll_level_%02d"

    if sketch_name == '07_PCSA':
        name_template = "p414_original_pcsa_level_%02d"

    if sketch_name == '08_MRB':
        name_template = "p414_original_mrb_level_%02d"

    for objective_str in ['maximumStage']:
        if sketch_name == '03_UnivMon' or sketch_name == '04_RHHH':
            for row in [3, 5]:
                if row == 3:
                    if sketch_name == '03_UnivMon':
                        max_level = 8
                    if sketch_name == '04_RHHH':
                        max_level = 10
   
                if row == 5:
                    if sketch_name == '03_UnivMon':
                        max_level = 5
                    if sketch_name == '04_RHHH':
                        max_level = 6

                for level in range(1, max_level+1):
                    p4_file_name = name_template % (row, level)
                    full_p4_path = sketch_lib_p4_path(sketch_name, p4_file_name)
                    output, output_log = output_path(sketch_name, objective_str, p4_file_name)
                    cmd = jose_run_cmd(objective_str, full_p4_path, output, output_log, 'RmtTofino12', 0.08)
                    cmd_list.append(cmd)
        else:
            pass
            if sketch_name == '08_MRB':
                level = 8
            if sketch_name == '06_HLL':
                level = 10
            if sketch_name == '07_PCSA':
                level = 12
            
            for level in range(1, level+1):
                    p4_file_name = name_template % (level)
                    full_p4_path = sketch_lib_p4_path(sketch_name, p4_file_name)
                    output, output_log = output_path(sketch_name, objective_str, p4_file_name)
                    cmd = jose_run_cmd(objective_str, full_p4_path, output, output_log, 'RmtTofino12', 0.08)
                    cmd_list.append(cmd)

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
for cmd in cmd_list:
    count += 1
    log_str = "%d" % count
    # run_cmd_func(cmd, log_str)
    helper.call(run_cmd_func, [cmd, log_str])

