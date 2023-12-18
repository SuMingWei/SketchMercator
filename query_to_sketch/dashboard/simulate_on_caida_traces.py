import os
import copy
import time
import glob
import json
import pickle
import argparse
import subprocess

from prometheus_client import start_http_server, Gauge

from classes import hashabledict
from query_to_sketch.main_constants import *

def parse_sql_input(sql_input):
    script_path = os.path.join(ROOT_DIR, 'intent_parser', 'run_packetq.py')
    cmd = 'python3 {} -s "{}"'.format(script_path, sql_input)
    output = subprocess.check_output(cmd, shell=True).strip().decode('utf-8')
    print(output)
    return output

def run_global_optimizer(parsed_sql, args):
    output_file = os.path.join(args.output_dir, 'output.txt')

    cmd = 'python3 {}'.format(os.path.join(ROOT_DIR, 'global_opt', 'main.py'))
    cmd += ' --queries "{}"'.format(parsed_sql)
    cmd += ' --sketches {}'.format(args.sketches)
    cmd += ' --resources level,row,width'
    cmd += ' --total_sram {}'.format(args.sram)
    cmd += ' --resource_modeler LinearModeler'
    cmd += ' --profiler_config only_actual.ini'
    cmd += ' --coverage_pickle_file actual.pkl'
    cmd += ' --deployment_output'
    cmd += ' --output_dir {}'.format(args.output_dir)
    cmd += ' > {} 2>&1'.format(output_file)

    print(cmd)

    subprocess.run(cmd, shell=True)

#def get_sketch_configs(solution_config):
#    result = {}
#    for solution in solution_config:
#        name = solution['name']
#        result[name] = []
#        for sketch in solution['solutions']:
#            config = copy.deepcopy(sketch)
#            del config['metric']
#            result[name].append(config)
#    return result

def convert_to_hashabledict(data):
    if type(data) in [int, float, str, hashabledict]:
        return data
    elif type(data) == list:
        return [convert_to_hashabledict(d) for d in data]
    elif type(data) == dict:  
        return hashabledict({convert_to_hashabledict(k):convert_to_hashabledict(v) for (k,v) in data.items()})    
    else:
        print('Unsupported datatype', type(data))
        assert(False)

def get_solution_configs(args):
    solution_configs = None
    new_solution_configs = None
    with open(os.path.join(args.output_dir, 'output.json')) as fin:
        solution_configs = json.load(fin)
    
    return convert_to_hashabledict(solution_configs)

def convert_width_to_num_cells(width_kb, sketch):
    sketch_cell_size_map = {
        'cm': 32,
        'cs': 32,
        'mrac': 32,
        'lc': 1,
        'mrb': 1,
        'hll': 8,
        'll': 8,
        'univmon': 32
    }

    return width_kb * 8 // sketch_cell_size_map[sketch]

def get_flowkeys_from_queries(parsed_sql_queries):
    queries = parsed_sql_queries.split(';')
    queries = [eval(query) for query in queries]
    flowkeys = [query[1:] for query in queries]
    return flowkeys

def get_flowkey_dir(flowkey):
    if flowkey == 'five_tuple':
        flowkey = ('srcIP', 'srcPort', 'dstIP', 'dstPort', 'proto')
    return ','.join(flowkey)

def get_cp_config(parsed_sql_queries, solution_configs, args):
    input_dir_root = os.path.join(SKETCH_HOME, 'result_{}_cp'.format(args.dataplane), args.project_name)
    cp_config = {}
    
    sketch_configs = []
    for solution_config in solution_configs:
        solutions = [hashabledict(s) for s in solution_config['solutions']]
        sketch_configs.extend(solutions)
        #sketch_configs.extend(solution_config['solutions'])
    #sketch_configs = list(frozenset(sketch_configs))
    sketch_configs = list(set(sketch_configs))

    for sketch_config in sketch_configs:
        #print(sketch_config)
        sketch_config_without_query = copy.deepcopy(sketch_config)
        del sketch_config_without_query['query']
        cp_config[sketch_config_without_query] = {}
        for query in sketch_config['query']:
            flowkey = tuple(query['flowkey'])
            metric = query['metric']
        #for flowkey in flowkeys:
            #print(flowkey, type(flowkey))
            #cp_config[sketch_config][flowkey] = {}
            #cp_config[sketch_config][query] = {}

            flowkey_dir = get_flowkey_dir(flowkey)
            num_cells = convert_width_to_num_cells(sketch_config['width'], sketch_config['algo'])
            config_string = 'row_{}_width_{}_level_{}_epoch_60_count_1_seed_1'.format(sketch_config['row'], num_cells, sketch_config['level'])
            result_pkl_glob = os.path.join(input_dir_root, sketch_config['algo']) + '/*/' + os.path.join(flowkey_dir, config_string, '01', 'data.pkl.class')
            results = [pickle.load(open(pkl_file, 'rb')) for pkl_file in glob.glob(result_pkl_glob)]

            cp_config[sketch_config_without_query][query] = [result[metric] for result in results]

            ##for metric in sketch_config['metric']:
            #for query in sketch_config['query']:
            #    if flowkey != tuple(query['flowkey']):
            #        continue
            #    #cp_config[str(sketch_config)][metric] = [result[metric] for result in results]
            #    #cp_config[sketch_config][metric] = [result[metric] for result in results]
            #    flowkey = tuple(query['flowkey'])
            #    print(flowkey, type(flowkey))
            #    metric = query['metric']
            #    print(flowkey, metric)

            #    cp_config[sketch_config][flowkey][metric] = [result[metric] for result in results]

    for k,v in cp_config.items():
        print(k)
        print(v)
        print('-' * 20)
    return cp_config

def get_control_plane_accuracy(parsed_sql_queries, args):
    result = {}
    #flowkeys = get_flowkeys_from_queries(parsed_sql_queries)
    # read solution configuration given by global optimizer
    solution_configs = get_solution_configs(args)
    # for each sketch deployment, for each trace, read control plane accuracy
    cp_config = get_cp_config(parsed_sql_queries, solution_configs, args)
    # for each solution, for each query, assign control place accuracy from cp_config
    for solution_config in solution_configs:
        result[solution_config['name']] = {}
        for sketch_config in solution_config['solutions']:
            sketch_config_without_query = copy.deepcopy(sketch_config)
            del sketch_config_without_query['query']
            #flowkey = sketch_config['flowkey']
            #query = sketch_config['query']
            #result[solution_config['name']][flowkey] = {}
            #result[solution_config['name']][query] = {}
            #for flowkey in flowkeys:
            for query in sketch_config['query']:
            #for metric in sketch_config['metric']:
                #result[solution_config['name']][flowkey][metric] = cp_config[sketch_config][flowkey][metric]
                result[solution_config['name']][query] = cp_config[sketch_config_without_query][query]

    return result

def export_prometheus_metrics(inference_map):
    prometheus_gauges_map = {}

    for solution_name in inference_map.keys():
        prometheus_gauges_map[solution_name] = {}
        for query in inference_map[solution_name].keys():
            metric = query['metric']
            flowkey = tuple(query['flowkey'])
            flowkey_repr = '_'.join(flowkey)
            prefix = '{}_{}_{}'.format(solution_name.replace('.', '_'), metric, flowkey_repr)
            prometheus_gauges_map[solution_name][metric] = {}
            prometheus_gauges_map[solution_name][metric]['value'] = Gauge(prefix + '_value', 'Value of ' + prefix)
            prometheus_gauges_map[solution_name][metric]['error'] = Gauge(prefix + '_error', 'Error of ' + prefix)
            for result in inference_map[solution_name][query]:
                if result.estimated_value:
                    prometheus_gauges_map[solution_name][metric]['value'].set(result.estimated_value)
                print(solution_name, metric, result.error)
                time.sleep(10)
                prometheus_gauges_map[solution_name][metric]['error'].set(result.error)

    return prometheus_gauges_map

def main(args):
    os.makedirs(args.output_dir, exist_ok=True)
    # parse sql_input
    parsed_sql_queries = parse_sql_input(args.sql_input)
    # get data plane and control plane configuration
    run_global_optimizer(parsed_sql_queries, args)
    # for each profiled trace, get the control plane inference accuracy
    inference_map = get_control_plane_accuracy(parsed_sql_queries, args)
    start_http_server(args.http_port)
    # expose resource usage and accuracies as prometheus metrics
    prometheus_gauges_map = export_prometheus_metrics(inference_map)

    print('Started exporting prometheus metrics!')

    while True:
        pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sql_input', required=True)
    parser.add_argument('--dataplane', required=True)
    parser.add_argument('--sram', required=True)
    parser.add_argument('--output_dir', required=True)
    parser.add_argument('--all_caida', default=False, action='store_true')
    parser.add_argument('--sketches', default='cm,cs,hll,lc,ll,mrac,mrb,univmon')
    parser.add_argument('--project_name', default='QuerySketch')
    parser.add_argument('--http_port', type=int, default=8000)
    args = parser.parse_args()
    main(args)
