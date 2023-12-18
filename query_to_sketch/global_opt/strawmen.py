import os
import sys
import sympy
import itertools
import numpy as np
from collections import defaultdict

from classes import AbstractSolver
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main_classes import *

class Strawman(AbstractSolver):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.remove_duplicate_sketch_instances = True
        self.init_allocator()
    
    def compute_query_to_sketch_map(self):
        return {}

    def get_solution(self, seed):
        np.random.seed(seed)
        query_to_sketch_map = self.compute_query_to_sketch_map()

        if query_to_sketch_map is None:
            return None, None
        
        sketch_instances = sorted(list(query_to_sketch_map.values()))
        if self.remove_duplicate_sketch_instances:
            sketch_instances = set(sketch_instances)
        
        resource_allocations = self.resource_allocator(query_to_sketch_map, sketch_instances, is_strawman=True)
        if resource_allocations is None:
            return None, None
        solution = {'sketch_instances': sketch_instances, 'resource_allocation_map': resource_allocations, 'query_to_sketch_map': query_to_sketch_map}
        error_bounds = self.get_error_bounds(solution)
        resource_usage = self.get_pre_optimization_total_resource_usage(resource_allocations)
        return solution, error_bounds, resource_usage

# randomly select sketch for each query
class RandomStrawman(Strawman):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def compute_query_to_sketch_map(self):
        query_to_sketch_map = {}

        for query in self.queries:
            #metric = query[0]
            #flowkey = query[1]
            metric = query.metric
            flowkey = query.flowkey

            available_sketches = sorted(list(set(self.sketches) & set(self.coverage_data['metric_to_sketch'][metric])))
            if not available_sketches:
                return None
            selected_sketch = np.random.choice(available_sketches)
            #query_to_sketch_map[query] = (selected_sketch, query)
            query_to_sketch_map[query] = (selected_sketch, flowkey)

        return query_to_sketch_map

# select sketches invidividually for each metric depending on error bound
class ErrorBoundMinimizerStrawman(Strawman):
    def compute_query_to_sketch_map(self):
        query_to_sketch_map = {}

        for query in self.queries:
            #metric = query[0]
            #flowkey = query[1]
            metric = query.metric
            flowkey = query.flowkey

            available_sketches = list(set(self.sketches) & set(self.coverage_data['metric_to_sketch'][metric]))
            if not available_sketches:
                return None
            available_sketches = sorted(available_sketches, key=lambda s: float(self.error_bound_config[s][metric]))
            selected_sketch = available_sketches[0]
            #query_to_sketch_map[query] = (selected_sketch, query)
            query_to_sketch_map[query] = (selected_sketch, flowkey)

        return query_to_sketch_map

# change to selects 1 general sketch, if available, and for uncovered metrics, select sketch randomly
class GeneralityStrawman(Strawman):
    def compute_query_to_sketch_map(self):
        query_to_sketch_map = {}
        if 'univmon' or 'fcm' in self.sketches:
            general_sketch = 'univmon' if 'univmon' in self.sketches else 'fcm'
            for query in self.queries:
                #metric = query[0]
                #flowkey = query[1]
                metric = query.metric
                flowkey = query.flowkey

                if general_sketch in self.coverage_data['metric_to_sketch'][metric]:
                    #query_to_sketch_map[query] = (general_sketch, query)
                    query_to_sketch_map[query] = (general_sketch, flowkey)

        uncovered_queries = list(set(self.queries) - set(query_to_sketch_map.keys()))
        
        if len(uncovered_queries) > 0:
            for query in uncovered_queries:
                #metric = query[0]
                #flowkey = query[1]
                metric = query.metric
                flowkey = query.flowkey

                available_sketches = list(set(self.sketches) & set(self.coverage_data['metric_to_sketch'][metric]))
                if not available_sketches:
                    return None
                selected_sketch = np.random.choice(available_sketches)
                #query_to_sketch_map[query] = (selected_sketch, query)
                query_to_sketch_map[query] = (selected_sketch, flowkey)
            
        return query_to_sketch_map            

# select sketches individually for each metric based on acc-res profile
class IndividualMetricAccuracyMaximizerStrawman(Strawman):
    def compute_query_to_sketch_map(self):
        query_to_sketch_map = {}
        accuracies = []

        for query in self.queries:
            #metric = query[0]
            #flowkey = query[1]
            metric = query.metric
            flowkey = query.flowkey

            available_sketches = sorted(list(set(self.sketches) & set(self.coverage_data['metric_to_sketch'][metric])))
            if not available_sketches:
                return None
            
            selected_sketch = None
            max_accuracy = -1

            for sketch in available_sketches:
                r = ResourceAllocation()
                profiler = self.profilers[self.profiler_config[sketch][metric]]
                # assign equal resources to each query
                r.add_resource('hash_unit', int(self.opt_config['resource_max']/len(self.queries)))
                accuracy = profiler.get_accuracy(DeployedSketchInstance(sketch, r), metric, self.opt_config['resource_max'], None)
                if accuracy > max_accuracy:
                    max_accuracy = accuracy
                    selected_sketch = sketch

            query_to_sketch_map[query] = (selected_sketch, flowkey)
            accuracies.append(max_accuracy)

        return query_to_sketch_map

# selects sketches based on the theoretical error bounds, giving preference to sketches with error bounds over sketches with just bounds on standard error of the error
# refer https://docs.google.com/spreadsheets/d/1MyExuug8vzBNk7rOmOm1LSlpD00DomvdH0Dzq94h14A/edit#gid=0
class TheoreticalStrawman(Strawman):
    def compute_query_to_sketch_map(self):
        error_bound_sketches = ['cs', 'univmon', 'cm']
        standard_error_sketches = ['hll', 'll']

        query_to_sketch_map = {}
    
        for query in self.queries:
            metric = query.metric
            flowkey = query.flowkey

            for sketch in error_bound_sketches + standard_error_sketches:
                if sketch in self.coverage_data['metric_to_sketch'][metric]:
                    query_to_sketch_map[query] = (sketch, flowkey)
        
        uncovered_queries = list(set(self.queries) - set(query_to_sketch_map.keys()))
        
        if len(uncovered_queries) > 0:
            for query in uncovered_queries:
                metric = query.metric
                flowkey = query.flowkey

                available_sketches = list(set(self.sketches) & set(self.coverage_data['metric_to_sketch'][metric]))
                if not available_sketches:
                    return None
                selected_sketch = np.random.choice(available_sketches)
                query_to_sketch_map[query] = (selected_sketch, flowkey)
         
        return query_to_sketch_map            

# select sketches by greedily maximizing number of metric covered by a sketch
class GreedyNumSketchMinimizerStrawman(Strawman):
    def get_general_sketch(self, uncovered_queries):
        sketch_count_map = defaultdict(int)
        for query in uncovered_queries:
            #metric = query[0]
            #flowkey = query[1]
            metric = query.metric
            flowkey = query.flowkey
            sketches = list(set(self.coverage_data['metric_to_sketch'][metric]) & set(self.sketches))
            
            for sketch in sketches:
                sketch_count_map[(sketch, flowkey)] += 1

        max_count_item = sorted(list(sketch_count_map.items()), key=lambda item: item[1], reverse=True)[0][0]
        selected_sketch = max_count_item[0]
        selected_flowkey = max_count_item[1]
        covered_queries = set([q for q in uncovered_queries if q[0] in self.coverage_data['sketch_to_metric'][selected_sketch] and q[1] == selected_flowkey])
        return selected_sketch, selected_flowkey, covered_queries

    def compute_query_to_sketch_map(self):
        uncovered_queries = set(self.queries)
        query_to_sketch_map = {}

        while len(uncovered_queries) > 0:
            general_sketch, flowkey, covered_queries = self.get_general_sketch(uncovered_queries)
            for q in covered_queries:
                query_to_sketch_map[q] = (general_sketch, flowkey)

            uncovered_queries = uncovered_queries - covered_queries

        return query_to_sketch_map
