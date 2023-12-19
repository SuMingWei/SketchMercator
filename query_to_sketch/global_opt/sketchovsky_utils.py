import os
import sys
import glob
import shutil
import subprocess

from constants import *

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from python_lib.pkl_saver import PklSaver
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'sketchmd_strategy'))
from lib.inst_list import sort_inst_list
from workload_manage.spec import *
from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main_classes import *
from main_constants import *

sketch_class_map = {
    'lc': LinearCounting,
    'cm': CountMin,
    'cs': CountSketch,
    'univmon': UnivMon,
    'mrb': MRB,
    'll': LL ,
    'hll': HLL,
    'mrac': MRAC
}

def sort_and_setid(instances):
    j = 0
    for inst in sort_inst_list(instances):
        j += 1
        inst.setid(j)
    return instances

def generate_workload_testcase(solution):
    instance_map = {}

    for key, val in solution['query_to_sketch_map'].items():
        if val in instance_map:
            continue

        sketch = sketch_class_map[val[0]]
        epoch = 30
        alloc = solution['resource_allocation_map'][val].get_resource_allocation()
        row = alloc['row']
        # convert width from bits to number of cells
        width = int(alloc['width'] / sketch.counter_bit)
        level = alloc['level']

        inst = SketchInstance()
        inst.testcase_init(sketch, Key1, FLOW_SIZE_TYPE_PACKET, epoch, row, width, level)
        instance_map[val] = inst

    instances = list(instance_map.values())
    sort_and_setid(instances)
    return {'bruteforce': [instances]}

def dump_workload_testcase(testcase, working_dir):
    shutil.rmtree(working_dir, ignore_errors=True)
    os.makedirs(working_dir)
    saver = PklSaver(os.path.join(working_dir, 'input'), WORKLOAD_PKL_FILE)
    saver.save(testcase)

def run_script_1(working_dir):
    cmd = 'python3'
    cmd += ' ' + os.path.join(SKETCHOVSKY_ROOT_DIR, 'main', 'workload_main.py')
    cmd += ' --input ' + os.path.join(working_dir, 'input')
    cmd += ' --output ' + os.path.join(working_dir, 'output')
    cmd += ' --run gd --timeout_O1 5 --timeout_O2 5'
    #print(cmd)
    subprocess.run(cmd, shell=True)

def run_script_2(working_dir):
    cmd = 'python3'
    cmd += ' ' + os.path.join(SKETCHOVSKY_ROOT_DIR, 'result_analysis', 'analysis_main.py')
    cmd += ' --output ' + os.path.join(working_dir, 'output')
    cmd += ' --result ' + os.path.join(working_dir, 'result')
    #print(cmd)
    subprocess.run(cmd, shell=True)

def run_script_3(working_dir):
    cmd = 'python3'
    cmd += ' ' + os.path.join(SKETCHOVSKY_ROOT_DIR, 'result_analysis', 'pick_data_sample_main.py')
    cmd += ' --output ' + os.path.join(working_dir, 'output')
    cmd += ' --result ' + os.path.join(working_dir, 'result')
    #print(cmd)
    subprocess.run(cmd, shell=True)

def parse_resource_file(working_dir):
    files = glob.glob(os.path.join(working_dir, 'samples_epoch_nfs') + '/**/resource.txt', recursive=True)
    assert(len(files) == 1)
    lines = open(files[0]).readlines()
    tokens = lines[25].strip().split(' ')
    return tokens[-1]

def main(solution, idx, output_dir):
    working_dir = os.path.join(ROOT_DIR, 'global_opt', 'sketchovsky_output', output_dir, str(idx)) 
    # generate testcase
    testcase = generate_workload_testcase(solution)
    # store to pkl
    dump_workload_testcase(testcase, working_dir)
    # run scripts/1_main.sh
    run_script_1(working_dir)
    # run scripts/2_analysis.sh
    run_script_2(working_dir)
    # run scripts/3_pick_sample.sh
    run_script_3(working_dir)
    # read resource.txt
    return parse_resource_file(working_dir)
