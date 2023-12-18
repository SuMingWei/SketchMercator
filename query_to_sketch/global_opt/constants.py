import os

# output format constants
sketch_idx_map = {
'cm': 0,
'cs': 1,
'mrac': 2,
'lc': 3,
'mrb': 4,
'hll': 5,
'll': 6,
'univmon': 7
}

metric_idx_map = {
'hh': 0,
'fsd': 1,
'ent': 2,
'cardinality': 3,
'cd': 4
}

# sketchovsky constants
SKETCHOVSKY_ROOT_DIR = os.path.join(os.path.expandvars('$sketch_home'), 'sketchmd_strategy')
#SKETCHOVSKY_WORKLOAD_DIR = os.path.join(SKETCHOVSKY_ROOT_DIR, 'workload_manage', 'bruteforce')
WORKLOAD_PKL_FILE = 'bruteforce.pkl'
