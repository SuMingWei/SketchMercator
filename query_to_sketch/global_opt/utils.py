import os
import sys
import math
import json
import pickle
import importlib
import numpy as np
from collections import defaultdict

import constants
import aggregation_functions

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import main_constants
from main_classes import *

def parse_csv_arg(arg):
    return arg.strip().split(',')

def parse_query_arg(arg):
    tokens = arg.strip().split('),(')
    tokens = [t.replace('(', '').replace(')', '') for t in tokens]
    tokens = [tuple(t.strip().split(',')) for t in tokens]
    return tokens

def parse_constraint_arg(arg):
    tokens = parse_query_arg(arg)
    return {token[0]:float(token[1]) for token in tokens}

def get_coverage_data(pickle_file):
    path = os.path.join(main_constants.ROOT_DIR, 'sketch_metric_coverage', pickle_file)
    data = None
    with open(path, 'rb') as fin:
        data = pickle.load(fin)
    return data

def get_profiler_classes():
    path = os.path.join(main_constants.ROOT_DIR, 'profiler')
    sys.path.append(path)
    import profilers
    return profilers

def get_resource_modeler(name):
    path = os.path.join(main_constants.ROOT_DIR, 'resource_modeler')
    sys.path.append(path)
    import modelers
    return getattr(modelers, name)()

def read_profiles(profiles_path):
    profiles = {}
    files = os.listdir(profiles_path)
    files = [f for f in files if '.json' in f]
    
    for f in files:
        sketch_name = f.split('_')[0]
        level = int(f.split('_')[2])

        with open(os.path.join(profiles_path, f)) as fin:
            profile_json = json.load(fin)

        if sketch_name not in profiles:
            profiles[sketch_name] = {}
        parse_profile_json(profile_json, profiles[sketch_name], level)

    return profiles

def parse_profile_json(profile_json, store, level):
    new_profile_json = {}

    for metric, metric_val in profile_json.items():
        if metric == 'entropy':
            metric = 'ent'
        elif metric == 'card':
            metric = 'cardinality'
        elif metric == 'change_det':
            metric = 'cd'

        if metric not in store:
            store[metric] = {}
        store[metric][level] = {}
        for row, row_val in metric_val.items():
            store[metric][level][int(row)] = {}
            for width in row_val.keys():
                store[metric][level][int(row)][int(width)] = row_val[width]

def normalize_profile_errors(profiles, func):
    metric_max_map = defaultdict(int)
    for sketch, sketch_val in profiles.items():
        for metric, metric_val in sketch_val.items():
            for level, level_val in metric_val.items():
                values = []
                for row, row_val in level_val.items():
                    for width in row_val.keys():
                        values.extend(row_val[width])
                metric_max_map[metric] = max(metric_max_map[metric], max(values))

    for sketch, sketch_val in profiles.items():
        for metric, metric_val in sketch_val.items():
            for level, level_val in metric_val.items():
                for row, row_val in level_val.items():
                    for width in row_val.keys():
                        values = row_val[width]
                        values = [v/metric_max_map[metric] for v in values]
                        row_val[width] = func(values, break_ties=False)

def read_and_process_profiles(profiles_path, agg_traces):
    agg_traces_func = get_agg_function(agg_traces)
    profiles = read_profiles(profiles_path)
    normalize_profile_errors(profiles, agg_traces_func)
    return profiles

def resource_allocation_sort_lambda(r):
    alloc_map = r.get_resource_allocation()
    return alloc_map['level'] * alloc_map['row'] * alloc_map['width']

def get_deployment_output(solution, solver_class, sketch_selection, resource_allocation, run):
    output = {}
    
    output['name'] = str(solver_class).split("'")[1]
    output['name'] += ':' + str(sketch_selection)
    output['name'] += ':' + str(resource_allocation)
    output['name'] += ':' + str(run)
    
    sketches = [s[0] for s in solution['query_to_sketch_map'].values()]
    output['solutions'] = {s:{'algo': constants.sketch_idx_map[s], 'metric': []} for s in sketches}

    print(solution['resource_allocation_map'])
    for key, val in solution['query_to_sketch_map'].items():
        sketch = val[0]
        metric = key[0]

        print(key, val)

        output['solutions'][sketch]['metric'].append(constants.metric_idx_map[metric])
        
        if 'level' not in output['solutions'][sketch]:
            alloc = solution['resource_allocation_map'][val].get_resource_allocation()
            output['solutions'][sketch].update(alloc)

    output['solutions'] = list(output['solutions'].values())

    return output

def get_profile_based_resource_allocation_from_resource_bound(resource_bound, profile):
    # select lowest level available
    level = min(profile.keys())
    # for each row, select max width such that level*row*width <= bound
    row_width_map = {}
    for row in profile[level].keys():
        widths = [w for w in profile[level][row].keys() if level*row*w <= resource_bound]
        if len(widths) == 0:
            continue
        row_width_map[row] = max(widths)
    if len(row_width_map.keys()) == 0:
        return None
    # select max row available
    #NOTE: instead of max row, another possibility is to select (row, width) which is as close to resource_bound as possible
    row = max(row_width_map.keys())
    width = row_width_map[row]

    r = ResourceAllocation()
    r.add_resource('level', level)
    r.add_resource('row', row)
    r.add_resource('width', width)
    return r

def get_strawman_resource_allocation_from_resource_bound(resource_bound, sketch, is_strawman):
    level_map = {'mrb': 8, 'mrac': 8, 'univmon': 16}
    strawman_row_map = {'cm': 2, 'cs': 2, 'univmon': 2}
    row_map = {'univmon': 3}

    if sketch in level_map:
        level = level_map[sketch]
    else:
        level = 1

    if is_strawman:
        if sketch in strawman_row_map:
            row = strawman_row_map[sketch]
        else:
            row = 1
    else:
        if sketch in row_map:
            row = row_map[sketch]
        elif sketch in strawman_row_map:
            row = strawman_row_map[sketch]
        else:
            row = 1

    # find largest power of 2 so that level*row*width <= bound
    width = 2**math.floor(math.log(resource_bound / (level * row), 2))
    
    r = ResourceAllocation()
    r.add_resource('level', level)
    r.add_resource('row', row)
    r.add_resource('width', width)
    return r

def get_agg_function(agg_name):
    return getattr(aggregation_functions, agg_name + '_agg_function')
