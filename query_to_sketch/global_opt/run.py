import os
import sys
import json
import time
import argparse

import utils
from optimizers import *
from strawmen import *

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import main_utils
import main_constants
from classes import *

def print_solution(solution, opt_function, errors, time_taken, print_errors):
    if solution is None:
        print('Sketches don\'t cover metrics!')
        return
    print('Solution')
    for key, val in solution['query_to_sketch_map'].items():
        print(key, '\t', val[0], '\t', solution['resource_allocation_map'][val])
    if print_errors:
        errors = [round(e, 2) for e in errors]
        print('Error bounds', errors)
        print('Value of optimization function on errors', opt_function(errors))
    print('Time taken', time_taken)

def main(args):
    Strawmen = [RandomStrawman, GeneralityStrawman]
    #Strawmen = []

    opt_function = utils.get_agg_function(args.agg_queries)

    if args.naive_sketch_selection:
        bruteforce_selections = ['random', 'general']
    else:
        bruteforce_selections = [None]

    if args.naive_resource_allocation:
        bruteforce_allocations = ['equal', 'query_proportional']
    else:
        bruteforce_allocations = [None]
    strawmen_allocations = ['equal', 'query_proportional']

    queries = utils.parse_query_arg(args.queries)
    sketches = utils.parse_csv_arg(args.sketches)
    resources = utils.parse_csv_arg(args.resources)
    if args.query_error_constraints:
        query_error_constraints = utils.parse_constraint_arg(args.query_error_constraints)
    else:
        query_error_constraints = None

    coverage_data = utils.get_coverage_data(args.coverage_pickle_file)
    profiler_config = main_utils.read_config_ini(os.path.join(main_constants.ROOT_DIR, 'profiler', args.profiler_config_file))
    error_bound_config = main_utils.read_config_ini(os.path.join(main_constants.ROOT_DIR, 'profiler', args.error_bound_config_file))
    opt_config = main_utils.read_config_ini(os.path.join(main_constants.ROOT_DIR, 'global_opt', 'config.ini'))

    if args.total_sram:
        opt_config.set('default', 'resource_max', str(args.total_sram))
        opt_config.set('default', 'resource_scale', str(args.total_sram))
    opt_config = opt_config['default']
    
    profiler_classes = utils.get_profiler_classes()
    resource_modeler = utils.get_resource_modeler(args.resource_modeler)

    if args.deployment_output:
        if not args.output_dir:
            print('Need --output_dir with --deployment_output!')
            assert(False)
        os.makedirs(args.output_dir, exist_ok=True)
    deployment_output = []

    if args.profiles_path:
        profiles = utils.read_and_process_profiles(args.profiles_path, args.agg_traces)
    else:
        profiles = utils.read_and_process_profiles(main_constants.PROFILES_PATH, args.agg_traces)

    for solver_class in [BruteForce]:
    #for solver_class in []:
        for bruteforce_selection in bruteforce_selections:
            for bruteforce_allocation in bruteforce_allocations:
                print()
                print(solver_class, bruteforce_selection, bruteforce_allocation)
                solver = solver_class(queries, sketches, resources, coverage_data, profiler_config, profiler_classes, resource_modeler, opt_config, args.output_dir, args.use_sketchovsky, sketch_selection=bruteforce_selection, allocation_strategy=bruteforce_allocation)
                solver.populate_profile_specific_resource_allocations(profiles)
                start = time.time()
                solution, errors = solver.get_solution(opt_function, query_error_constraints)
                end = time.time()
                if args.deployment_output:
                    deployment_output.append(utils.get_deployment_output(solution, solver_class, bruteforce_selection, bruteforce_allocation, 0))
                if bruteforce_allocation is None:
                    print_solution(solution, opt_function, errors, end-start, print_errors=True)
                else:
                    print_solution(solution, opt_function, errors, end-start, print_errors=False)

    for solver_class in Strawmen:
        for strawman_allocation in strawmen_allocations:
            for run in range(args.num_strawman_runs):
                print()
                print(solver_class, strawman_allocation, run)
                solver = solver_class(queries, sketches, resources, coverage_data, profiler_config, profiler_classes, resource_modeler, opt_config, args.output_dir, args.use_sketchovsky, sketch_selection=None, allocation_strategy=strawman_allocation, error_bound_config=error_bound_config)
                solver.profiles = profiles
                start = time.time()
                solution, error_bounds = solver.get_solution(seed=run)
                end = time.time()
                if args.use_sketchovsky:
                    post_opt_resource_usage = solver.get_post_optimization_total_resource_usage(solution, strawman_allocation)
                    print(post_opt_resource_usage)
                if args.deployment_output:
                    deployment_output.append(utils.get_deployment_output(solution, solver_class, None, strawman_allocation, run))
                print_solution(solution, opt_function, error_bounds, end-start, print_errors=False)

    if args.deployment_output:        
        with open(os.path.join(args.output_dir, args.output_file), 'w') as fout:
            print(json.dumps(deployment_output, indent=4), file=fout)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # primary inputs for optimization
    parser.add_argument('--queries', required=True)
    parser.add_argument('--sketches', required=True)
    parser.add_argument('--resources', required=True)
    parser.add_argument('--resource_modeler', required=True)
    parser.add_argument('--agg_queries', default='avg')
    parser.add_argument('--agg_traces', default='median')
    
    # constraints for optimization
    parser.add_argument('--total_sram', type=int)
    parser.add_argument('--query_error_constraints')

    # config files locations
    parser.add_argument('--coverage_pickle_file', default='general.pkl')
    parser.add_argument('--profiles_path', default=None, required=False)
    parser.add_argument('--profiler_config_file', default='general.ini')
    parser.add_argument('--error_bound_config_file', default='error_bound.ini')

    # output format and location
    parser.add_argument('--output_dir', required=True)
    parser.add_argument('--output_file', default='output.json')
    parser.add_argument('--deployment_output', default=False, action='store_true')

    # control which modules are used
    parser.add_argument('--naive_sketch_selection', default=False, action='store_true')
    parser.add_argument('--naive_resource_allocation', default=False, action='store_true')
    parser.add_argument('--use_sketchovsky', default=False, action='store_true')

    # strawman options
    parser.add_argument('--num_strawman_runs', type=int, default=1)
    
    args = parser.parse_args()
    main(args)