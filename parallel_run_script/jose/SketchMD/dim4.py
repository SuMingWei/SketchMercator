import os
from parallel_run_script.jose.common import jose_run_cmd
from data_helper.data_path_helper.p4_path_helper import sketchMD_p4_path
from data_helper.data_path_helper.jose_path_helper import sketchMD_output_path as output_path

p4_file_name_list = [
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/naive/p414_set_1_4dim_naive.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/naive/p414_set_2_4dim_naive.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/naive/p414_set_3_4dim_naive.p4",

    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea1/p414_set_1_4dim_idea1.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea1/p414_set_2_4dim_idea1.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea1/p414_set_3_4dim_idea1.p4",

    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea2/p414_set_1_4dim_idea2.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea2/p414_set_2_4dim_idea2.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea2/p414_set_3_4dim_idea2.p4",

    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea3/p414_set_1_4dim_idea3.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea3/p414_set_2_4dim_idea3.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea3/p414_set_3_4dim_idea3.p4",

    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea4/p414_set_1_4dim_idea4.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea4/p414_set_2_4dim_idea4.p4",
    "/data1/hun/sketch_home/p4_repo/p414/open/sketches/SketchMD/4dim/idea4/p414_set_3_4dim_idea4.p4",
]

cmd_list = []
log_str_list = []

objective_str = 'maximumStage'
gap = 0.2
# gap = 0.02
count = 0
switch = "RmtTofino45"

for full_p4_path in p4_file_name_list:
    # print(full_p4_path)
    p4_file_name = os.path.basename(full_p4_path).split(".p4")[0]
    output, output_log = output_path("dim4", objective_str, p4_file_name, "SketchMD", switch)
    # print(output, output_log)
    cmd = jose_run_cmd(objective_str, full_p4_path, output, output_log, switch, gap)
    cmd_list.append(cmd)
    log_str = "[%s] %s" % (switch, p4_file_name)
    log_str_list.append(log_str)
    # print(log_str)

for cmd in cmd_list:
    print(cmd)
    print()
# print(len(cmd_list))



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
    log_str = ("[%d] " % count) + log_str
    print(log_str)
    # run_cmd_func(cmd, log_str)
    helper.call(run_cmd_func, [cmd, log_str])



