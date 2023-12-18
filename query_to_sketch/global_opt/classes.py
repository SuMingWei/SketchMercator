import os
import sys
import sympy
import itertools
import numpy as np
from collections import defaultdict

import utils
import sketchovsky_utils
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main_classes import *

class Query:
    def __init__(self, metric, flowkey):
        self.metric = metric
        self.flowkey = flowkey

    def __repr__(self):
        return str((self.metric, self.flowkey))

    def __lt__(self, other):
        return self.__repr__() < other.__repr__()

class AbstractSolver:
    def __init__(self, queries, sketches, resources, coverage_data, profiler_config, profiler_classes, resource_modeler, opt_config, output_dir, use_sketchovsky, sketch_selection=None, allocation_strategy=None, error_bound_config=None):
        self.queries = queries
        self.sketches = sketches
        self.resources = resources
        self.coverage_data = coverage_data
        self.profiler_config = profiler_config
        self.profiler_classes = profiler_classes
        self.resource_modeler = resource_modeler
        self.output_dir = output_dir
        self.use_sketchovsky = use_sketchovsky
        self.sketch_selection = sketch_selection
        self.allocation_strategy = allocation_strategy
        self.error_bound_config = error_bound_config

        self.resource_allocations_map = {}
        self.profiles = None
        self.profile_specific_resource_allocations = {}

        self.solution_idx = 0
        self.set_config(opt_config)
        self.init_profilers()

    def set_config(self, opt_config):
        self.opt_config = {}
        for key, val in dict(opt_config).items():
            try:
                self.opt_config[key] = int(val)
            except ValueError:
                self.opt_config[key] = val
                continue

    def init_profilers(self):
        self.profilers = {}
        for key, val in self.profiler_classes.__dict__.items():
            if isinstance(val, type) and 'Profiler' in key:
                self.profilers[key] = val()

    def get_error_bounds(self, solution):
        result = []
        for query in self.queries:
            #metric = query[0]
            metric = query.metric
            sketch_instance = solution['query_to_sketch_map'][query]
            sketch = sketch_instance[0]
            result.append(float(self.error_bound_config[sketch][metric]))
        return result            

    def get_errors(self, solution):
        result = []
        for query in self.queries:
            #metric = query[0]
            #flowkey = query[1]
            metric = query.metric
            flowkey = query.flowkey

            r = ResourceAllocation()
            sketch_instance = solution['query_to_sketch_map'][query]
            sketch = sketch_instance[0]
            sketch_idx = solution['sketch_instances'].index(sketch_instance)
            profiler = self.profilers[self.profiler_config[sketch][metric]]
            resource_allocation = solution['resource_allocation_map'][(sketch, flowkey)]
            result.append(profiler.get_error(DeployedSketchInstance(sketch, resource_allocation), metric, self.opt_config['resource_max'], self.profiles))
        return result

    def init_allocator(self):
        if self.allocation_strategy == 'equal':
            self.resource_allocator = self.get_equal_allocations
        elif self.allocation_strategy == 'query_proportional':
            self.resource_allocator = self.get_query_proportional_allocations
        else:
            self.resource_allocator = None

    def get_equal_allocations(self, solution, sketch_instances, is_strawman):
        result = {}
        for k, v in solution.items():
            resource_bound = self.opt_config['resource_max'] / len(sketch_instances)
            #profile = self.profiles[v[0]][k[0]]
            profile = self.profiles[v[0]][k.metric]
            result[v] = utils.get_strawman_resource_allocation_from_resource_bound(resource_bound, v[0], is_strawman)
            if result[v] is None:
                return None
        return result

    def get_query_proportional_allocations(self, solution, sketch_instances, is_strawman):
        result = {}
        sketch_instance_count_map = defaultdict(int)
        for k, v in solution.items():
            sketch_instance_count_map[v] += 1

        for k, v in solution.items():
            resource_bound = self.opt_config['resource_max'] * sketch_instance_count_map[v] / len(solution)
            #profile = self.profiles[v[0]][k[0]]
            profile = self.profiles[v[0]][k.metric]

            result[v] = utils.get_strawman_resource_allocation_from_resource_bound(resource_bound, v[0], is_strawman)
            if result[v] is None:
                return None
            
        return result
    
    def get_pre_optimization_total_resource_usage(self, alloc):
        return sum([np.prod(list(instance_alloc.get_resource_allocation().values())) for instance_alloc in alloc.values()])

    def get_post_optimization_total_resource_usage(self, solution, allocation_strategy=None):
        #return sketchovsky_utils.main(solution, self.solution_idx, '_'.join([self.output_dir, self.__class__.__name__, str(allocation)]))
        result = sketchovsky_utils.main_2(solution, self.solution_idx, '_'.join([self.output_dir, self.__class__.__name__, str(allocation_strategy)]))
        if result is None:
            return self.get_pre_optimization_total_resource_usage(solution['resource_allocation_map'])
        return result

    #def get_query_proportional_allocations(self, solution, sketch_instances):
    #    result = {}
    #    sketch_instance_count_map = defaultdict(int)
    #    total = 0
    #    for k, v in solution.items():
    #        sketch_instance_count_map[v] += 1
    #        total += 1

    #    for k, v in solution.items():
    #        resource_bound = self.opt_config['resource_max'] * sketch_instance_count_map[v] / total
    #        profile = self.profiles[v[0]][k.metric]
    #        
    #        # select lowest level available
    #        level = min(profile.keys())
    #        # for each row, select max width such that level*row*width <= bound
    #        row_width_map = {}
    #        for row in profile[level].keys():
    #            widths = [w for w in profile[level][row].keys() if level*row*w <= resource_bound]
    #            if len(widths) == 0:
    #                continue
    #            row_width_map[row] = max(widths)
    #        if len(row_width_map.keys()) == 0:
    #            return None
    #        # select max row available
    #        #NOTE: instead of max row, another possibility is to select (row, width) which is as close to resource_bound as possible
    #        row = max(row_width_map.keys())
    #        width = row_width_map[row]

    #        r = ResourceAllocation()
    #        r.add_resource('level', level)
    #        r.add_resource('row', row)
    #        r.add_resource('width', width)
    #        result[v] = r

    #    return result

