import os
import sys
import sympy
import itertools
from collections import defaultdict

import utils
# import sketchovsky_utils
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main_classes import *

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
            metric = query[0]
            sketch_instance = solution['query_to_sketch_map'][query]
            sketch = sketch_instance[0]
            result.append(float(self.error_bound_config[sketch][metric]))
        return result            

    def get_errors(self, solution):
        result = []
        for query in self.queries:
            metric = query[0]
            flowkey = query[1]

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
            profile = self.profiles[v[0]][k[0]]
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
            profile = self.profiles[v[0]][k[0]]

            result[v] = utils.get_strawman_resource_allocation_from_resource_bound(resource_bound, v[0], is_strawman)
            if result[v] is None:
                return None
            
        return result

    def get_post_optimization_total_resource_usage(self, solution, allocation=None):
        return sketchovsky_utils.main(solution, self.solution_idx, '_'.join([self.output_dir, self.__class__.__name__, str(allocation)]))
