import os
import math
import json
import argparse
import pandas as pd
from collections import defaultdict

def get_max(metric_dict):
    max_value = -math.inf
    for row, row_dict in metric_dict.items():
        for width, errors in row_dict.items():
            max_value = max(max_value, max(errors))
    return max_value

def main(args):
    files = os.listdir(args.profiles_path)
    files = [f for f in files if 'level' in f]
    datas = [json.load(open(os.path.join(args.profiles_path, f))) for f in files]

    metric_max_map = defaultdict(lambda: -math.inf)

    for data in datas:
        for metric, values in data.items():
            metric_max_map[metric] = max(metric_max_map[metric], get_max(values))

    with open(os.path.join(args.profiles_path, args.output_file), 'w') as fout:
        json.dump(metric_max_map, fout)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--profiles_path', required=True)
    parser.add_argument('--output_file', default='metric_max.json')
    args = parser.parse_args()
    main(args)
