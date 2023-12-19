import os
import sys
import pickle
import argparse
from collections import defaultdict

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import main_utils as utils

def generate_metric_sketch_map(config):
    result = {}
    for key, val in config['metric_to_sketch'].items():
        tokens = val.split(',')
        result[key] = [t.strip() for t in tokens]
    return result

def generate_sketch_metric_map(metric_sketch_map):
    result = defaultdict(list)
    for metric, sketches in metric_sketch_map.items():
        for sketch in sketches:
            result[sketch].append(metric)
    return dict(result)

def main(args):
    if not args.dump and not args.print:
        print('Need atleast one of --dump and --print')
        return

    if args.dump:
        if not args.input_file or not args.output_file:
            print('Need input_file and output_file')
            return

    config = utils.read_config_ini(args.input_file)

    metric_sketch_map = generate_metric_sketch_map(config)
    sketch_metric_map = generate_sketch_metric_map(metric_sketch_map)
    
    data = {}
    data['metric_to_sketch'] = metric_sketch_map
    data['sketch_to_metric'] = sketch_metric_map

    if args.print:
        print('metric_to_sketch')
        print(metric_sketch_map)
        print('sketch_to_metric')
        print(sketch_metric_map)

    if args.dump:
        with open(args.output_file, 'wb') as fout:
            pickle.dump(data, fout)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dump', default=False, action='store_true')
    parser.add_argument('--print', default=False, action='store_true')
    parser.add_argument('--input_file')
    parser.add_argument('--output_file')
    args = parser.parse_args()
    main(args)
