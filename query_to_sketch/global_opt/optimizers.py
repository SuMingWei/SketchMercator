import os
import sys
import time
import sympy
import itertools
import numpy as np
from collections import defaultdict

import utils
import strawmen
from classes import AbstractSolver

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main_classes import *

class BruteForce(AbstractSolver):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.init_allocator()

        if self.sketch_selection is None:
            self.strawman_object = None
        elif self.sketch_selection == 'random':
            self.strawman_object = strawmen.RandomStrawman(*args, **kwargs)
        elif self.sketch_selection == 'general':
            self.strawman_object = strawmen.GeneralityStrawman(*args, **kwargs)
        else:
            print('Unsupported sketch_selection!')
            assert(False)
    
    def get_profile_specific_resource_allocations(self, query_to_sketch_map):
        possible_allocations_map = {}
        all_possible_allocations = []

        for key, val in query_to_sketch_map.items():
            #metric = key[0]
            metric = key.metric
            sketch = val[0]
            instance = val

            possible_allocations_map[instance] = self.profile_specific_resource_allocations[sketch][metric]

        keys = possible_allocations_map.keys()
        values = possible_allocations_map.values()

        all_possible_allocations = [dict(zip(keys, x)) for x in itertools.product(*values)]
        #TODO: currently, this skips allocations where pre_optimization_total >= max, but post_optimization_total <= max
        all_possible_allocations = [alloc for alloc in all_possible_allocations if self.get_pre_optimization_total_resource_usage(alloc) <= self.opt_config['resource_max']]
        return all_possible_allocations
        
    def get_possible_exponential_resource_allocations(self, length):
        #NOTE: assumes increase in resource usage decreases error
        res_max = self.opt_config['resource_max']
        res_min = self.opt_config['resource_min']
        res_exp = self.opt_config['resource_exp']

        if length == 1:
            self.resource_allocations_map[1] = [[1024 * res_exp**res_max]]

        if length in self.resource_allocations_map:
            return self.resource_allocations_map[length]
        
        possible_resource_values = np.logspace(start=res_min, stop=res_max, base=res_exp, num=res_max-res_min+1, dtype=np.uint32) * 1024
        combos = list(itertools.combinations_with_replacement(possible_resource_values, length - 1))
        full_combos = set()
        for i in range(len(combos)):
            nth_element = 1024 * res_exp**res_max - sum(combos[i])
            if nth_element > 0:
                # find largest element from possible_resource_values that is <= nth_element
                nth_element = res_exp**(np.where(possible_resource_values <= nth_element)[0][-1]) * 1024
                full_combos.add(tuple(list(combos[i]) + [nth_element]))

        full_combos = list(full_combos)

        result = []
        for combo in full_combos:
            result.extend(sympy.utilities.iterables.multiset_permutations(combo))

        self.resource_allocations_map[length] = result
        return result
        
    def get_possible_uniform_resource_allocations(self, length):
        #NOTE: assumes increase in resource usage decreases error
        res_max = self.opt_config['resource_max']
        res_min = self.opt_config['resource_min']
        res_step = self.opt_config['resource_step']

        if length == 1:
            self.resource_allocations_map[1] = [[res_max]]

        if length in self.resource_allocations_map:
            return self.resource_allocations_map[length]

        possible_resource_values = range(res_min, res_max + res_step, res_step)
        combos = list(itertools.combinations_with_replacement(possible_resource_values, length - 1))
        full_combos = set()
        for i in range(len(combos)):
            nth_element = res_max - sum(combos[i])
            if nth_element > 0:
                full_combos.add(tuple(list(combos[i]) + [nth_element]))

        full_combos = list(full_combos)

        result = []
        for combo in full_combos:
            result.extend(sympy.utilities.iterables.multiset_permutations(combo))

        self.resource_allocations_map[length] = result
        return result

    def get_metric_to_sketch_maps(self):
        metric_to_available_sketches_map = {}
        metrics = list(set([q.metric for q in self.queries]))

        for metric in metrics:
            metric_to_available_sketches_map[metric] = list(set(self.sketches) & set(self.coverage_data['metric_to_sketch'][metric]))

        iterables = [[(m, v) for v in metric_to_available_sketches_map[m]] for m in metric_to_available_sketches_map.keys()]
        product = itertools.product(*iterables)

        result = []
        for p in product:
            result.append({m:s for (m, s) in p})

        return result

    def get_all_instances(self):
        result = []
        #NOTE: assuming all queries with same metric will be provided by same sketch
        if self.sketch_selection is None:
            metric_to_sketch_maps = self.get_metric_to_sketch_maps()
        else:
            strawman_map = self.strawman_object.compute_query_to_sketch_map()
            metric_to_sketch_maps = [{q[0]:s[0] for (q, s) in strawman_map.items()}]
            
        if len(metric_to_sketch_maps) == 0:
            return None
        
        for metric_to_sketch_map in metric_to_sketch_maps:
            #query_to_sketch_map = {(m,f):(metric_to_sketch_map[m], (m, f)) for (m, f) in self.queries}
            query_to_sketch_map = {}
            for query in self.queries:
                m = query.metric
                f = query.flowkey
                query_to_sketch_map[query] = (metric_to_sketch_map[m], f)
            #query_to_sketch_map = {(m,f):(metric_to_sketch_map[m], f) for (m, f) in self.queries}
            sketch_instances = sorted(list(set(query_to_sketch_map.values())))
            #TODO: add intermediate naive resource allocation strategy
            if self.allocation_strategy is None:
                #resource_allocations_list = self.get_possible_uniform_resource_allocations(len(sketch_instances))
                #resource_allocations_list = self.get_possible_exponential_resource_allocations(len(sketch_instances))
                resource_allocations_list = self.get_profile_specific_resource_allocations(query_to_sketch_map)
            else:
                resource_allocations_list = [self.resource_allocator(query_to_sketch_map, sketch_instances, is_strawman=False)]

            for resource_allocation_map in resource_allocations_list:
                candidate_solution = {'sketch_instances': sketch_instances, 'resource_allocation_map': resource_allocation_map, 'query_to_sketch_map': query_to_sketch_map}
                #if self.use_sketchovsky:
                #    #TODO: what to do with this resource usage
                #    resource_usage = self.get_post_optimization_total_resource_usage(candidate_solution)
                self.solution_idx += 1
                result.append(candidate_solution)

        return result

    def get_solution(self, opt_function, query_error_constraints, use_sketchovsky):
        def compare_solution_fitnesses(candidate, benchmark):
            # if both error and resource usage are better or worse
            if candidate['error'] < benchmark['error'] and candidate['resource_usage'] < benchmark['resource_usage']:
                return True
            if candidate['error'] > benchmark['error'] and candidate['resource_usage'] > benchmark['resource_usage']:
                return False

            # if either error or resource usage is equal
            if candidate['error'] == benchmark['error']:
                return candidate['resource_usage'] < benchmark['resource_usage']
            if candidate['resource_usage'] == benchmark['resource_usage']:
                return candidate['error'] < benchmark['error']

            # if we reach here, it means one of "candidate" and "benchmark" has lower error and higher resource_usage than the other (and vice versa)
            # we need to weigh errors and resource_usage to get a meaningful answer
            #weight = 5e-4
            weight = 0
            return (candidate['error'] + weight * candidate['resource_usage']) < (benchmark['error'] + weight * benchmark['resource_usage'])

        candidate_solutions = self.get_all_instances()

        if candidate_solutions is None:
            return None, None
        
        min_opt_function_value = opt_function([np.inf for i in range(len(self.queries))])
        solution = None
        solution_errors = None
        solution_resource_usage = None

        min_fitness = {'error': np.inf, 'resource_usage': np.inf}

        for candidate_solution in candidate_solutions:
            errors = self.get_errors(candidate_solution)
            if query_error_constraints is not None:
                if not self.check_query_error_constraints(errors, query_error_constraints):
                    continue
            
            opt_function_value = opt_function(errors)
            if use_sketchovsky:
                resource_usage = self.get_post_optimization_total_resource_usage(candidate_solution)
                candidate_solution_fitness = {'error': opt_function_value, 'resource_usage': resource_usage}
                if compare_solution_fitnesses(candidate_solution_fitness, min_fitness):
                    min_fitness = candidate_solution_fitness
                    solution = candidate_solution
                    solution_errors = errors
                    solution_resource_usage = resource_usage
            else:
                resource_usage = None
                if min_opt_function_value > opt_function_value:
                    min_opt_function_value = opt_function_value
                    solution = candidate_solution
                    solution_errors = errors

        return solution, solution_errors, solution_resource_usage

    def read_and_process_profiles(self, profiles_path):
        self.read_profiles(profiles_path)
        self.normalize_profile_errors()
        self.populate_profile_specific_resource_allocations()

    def read_profiles(self, profiles_path):
        self.profiles = utils.read_profiles(profiles_path)

    def normalize_profile_errors(self):
        metric_max_map = defaultdict(int)
        for sketch, sketch_val in self.profiles.items():
            for metric, metric_val in sketch_val.items():
                for level, level_val in metric_val.items():
                    values = []
                    for row, row_val in level_val.items():
                        for width in row_val.keys():
                            values.extend(row_val[width])
                    metric_max_map[metric] = max(metric_max_map[metric], max(values))

        for sketch, sketch_val in self.profiles.items():
            for metric, metric_val in sketch_val.items():
                for level, level_val in metric_val.items():
                    for row, row_val in level_val.items():
                        for width in row_val.keys():
                            values = row_val[width]
                            values = [v/metric_max_map[metric] for v in values]
                            row_val[width] = np.median(values)

    def populate_profile_specific_resource_allocations(self, profiles):
        self.profiles = profiles

        for sketch, sketch_val in self.profiles.items():
            self.profile_specific_resource_allocations[sketch] = {}
            for metric, metric_val in sketch_val.items():
                self.profile_specific_resource_allocations[sketch][metric] = []
                for level, level_val in metric_val.items():
                    for row, row_val in level_val.items():
                        for width, width_val in row_val.items():
                            r = ResourceAllocation()
                            r.add_resource('level', level)
                            r.add_resource('row', row)
                            r.add_resource('width', width)
                            self.profile_specific_resource_allocations[sketch][metric].append(r)

                self.profile_specific_resource_allocations[sketch][metric].sort(key=utils.resource_allocation_sort_lambda)

    def check_query_error_constraints(self, errors, constraints):
        # based on order of errors computed in get_errors()
        for idx, query in enumerate(self.queries):
            #metric = query[0]
            metric = query.metric
            if metric not in constraints:
                continue
            if errors[idx] > constraints[metric]:
                return False
        return True
