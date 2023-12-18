import os
import sys
import glob
import shutil
import subprocess
from collections import defaultdict

from constants import *

#TODO: tidy up imports
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
    files = glob.glob(os.path.join(working_dir, 'samples') + '/**/resource.txt', recursive=True)
    assert(len(files) == 1)
    lines = open(files[0]).readlines()
    tokens = lines[25].strip().split(' ')
    return tokens[-1]

def main(solution, idx, output_dir):
    working_dir = os.path.join(output_dir, 'sketchovsky_output', str(idx))
    #working_dir = os.path.join(ROOT_DIR, 'global_opt', 'sketchovsky_output', output_dir, str(idx)) 
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

def check_compatibility(solution):
    # no need to check flowsize (C5) and epoch (C6)
    partitions = defaultdict(list)

    sketch_instances = list(set(solution['query_to_sketch_map'].values()))
    for sketch_instance in sketch_instances:
        sketch = sketch_instance[0]
        sketch_class = sketch_class_map[sketch]
        
        # partition sketches in solution based on below properties:
            # counter array type (C1)
            # counter update type (C2)
            # flowkey (C4)
        # remove condition on single vs multi level sketches
        #counter_array_type = sketch_class.multi_level_sketch
        counter_update_type = sketch_class.counter_update_type
        flowkey = sketch_instance[1]

        #partitions[(counter_array_type, counter_update_type, flowkey)].append(sketch_instance)
        partitions[(counter_update_type, flowkey)].append({'q2s_sketch_object': sketch_instance, 'sketchovsky_sketch_object': sketch_class})

    # check if any partition has >1 sketches
    for key, val in partitions.items():
        if len(val) > 1:
            return True, partitions
    return False, None

def get_resource_usage(partitions, solution):
    resource_usage = 0
    for key, val in partitions.items():
        #if len(val) == 1:
        #    alloc = solution['resource_allocation_map'][val['q2s_sketch_object']].get_resource_allocation()
        #    resource_usage += alloc['level'] * alloc['row'] * alloc['width']
        #else:
        sketch_alloc_map = {v['q2s_sketch_object']: solution['resource_allocation_map'][v['q2s_sketch_object']].get_resource_allocation() for v in val}
        single_level_sketches = [v['q2s_sketch_object'] for v in val if not v['sketchovsky_sketch_object'].multi_level_sketch]
        multi_level_sketches = [v['q2s_sketch_object'] for v in val if v['sketchovsky_sketch_object'].multi_level_sketch]

        # if we have only single level sketches, just optimize them
        # if we have single and multi level sketch together, optimize single level sketch and first level of multi level sketch
        # below logic does both as it doesn't consider levels
        max_rows = max([alloc['row'] for alloc in sketch_alloc_map.values()])
        for row in range(max_rows):
            relevant_widths = [alloc['width'] for alloc in sketch_alloc_map.values() if alloc['row'] >= row]
            resource_usage += max(relevant_widths)
        # include the resource usage for 2nd to last layer of multi-level sketches, if any
        for sketch in multi_level_sketches:
            resource_usage += sketch_alloc_map[sketch]['row'] * sketch_alloc_map[sketch]['width'] * (sketch_alloc_map[sketch]['level'] - 1)
    return resource_usage
            

def main_2(solution, idx, output_dir):
    is_compatible, partitions = check_compatibility(solution)
    if not is_compatible:
        return None
    return get_resource_usage(partitions, solution)
