import os

SKETCH_HOME = os.path.expandvars('$sketch_home')
ROOT_DIR = os.path.join(SKETCH_HOME, 'query_to_sketch')
#PROFILES_PATH = os.path.join(ROOT_DIR, 'profiler', 'actual_profiles')
PROFILES_PATH = os.path.join(ROOT_DIR, 'profiler', 'actual_profiles_lower_memory')

pretty_sketch_map = {
    'cm': 'Count-min Sketch',
    'cs': 'Count Sketch',
    'hhh': 'HHH',
    'rhhh': 'RHHH',
    'univmon': 'Univmon',
    'fcm': 'FCM',
    'lc': 'Linear Counting',
    'pcsa': 'PCSA',
    'mrb': 'Multi-resolution Bitmap',
    'll': 'Loglog',
    'hll': 'Hyperloglog',
    'mrac': 'MRAC',
    'bf': 'BloomFilter'
}

pretty_metric_map = {
    'hh': 'heavy hitter',
    'cd': 'change detection',
    'ent': 'entropy',
    'cardinality': 'cardinality',
    'fsd': 'flow size distribution',
    'membership': 'membership',
}

total_sketches = list(pretty_sketch_map.keys())
total_metrics = list(pretty_metric_map.keys())
total_resources = ['hash_unit', 'salu', 'sram', 'columns']
