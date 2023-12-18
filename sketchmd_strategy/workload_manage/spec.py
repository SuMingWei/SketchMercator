from sketch_formats.sketch import *

# invariant features

# 1. # of sketch algos
# 2. # of stats
STATISTIC_TYPE_MEMBERSHIP = 1
STATISTIC_TYPE_CARDINALITY = 2
STATISTIC_TYPE_ENTROPY = 3
STATISTIC_TYPE_HEAVY_HITTER = 4
STATISTIC_TYPE_HEAVY_CHANGE = 5
STATISTIC_TYPE_FLOWSIZE_DIST = 6
STATISTIC_TYPE_GENERAL = 7

sketch_dict = {}
# sketch_dict[STATISTIC_TYPE_MEMBERSHIP] = [BloomFilter, CountingBloomFilter]
sketch_dict[STATISTIC_TYPE_MEMBERSHIP] = [BloomFilter]
sketch_dict[STATISTIC_TYPE_CARDINALITY] = [LinearCounting, HLL, MRB, PCSA]
sketch_dict[STATISTIC_TYPE_ENTROPY] = [Entropy]
sketch_dict[STATISTIC_TYPE_HEAVY_HITTER] = [CountMin, CountSketch]
sketch_dict[STATISTIC_TYPE_HEAVY_CHANGE] = [Kary]
sketch_dict[STATISTIC_TYPE_FLOWSIZE_DIST] = [MRAC]
sketch_dict[STATISTIC_TYPE_GENERAL] = [UnivMon]

sketch_list = []
for k, v in sketch_dict.items():
    sketch_list += v

pool_of_statistics = [1, 2, 3, 4, 5, 6, 7]
# pool_of_statistics = [1, 2, 3, 4, 5, 6]
pool_of_sketches = [BloomFilter, LinearCounting, HLL, MRB, PCSA, Entropy, CountMin, CountSketch, Kary, MRAC, UnivMon]

# 3. (SL or ML or SL/ML)
# 4. Counter Update Type
# 5. Counter Value in DP
# 6. Sampling Compatible
# 7. Heavy Flowkey Storage

# configurable features

# 8. # of sketch instances
# 9. unique # of flowkeys
SRCIP = 0
DSTIP = 1
SRCPORT = 2
DSTPORT = 3
PROTO = 4

Key1 = [SRCIP]
Key2 = [SRCIP, SRCPORT]
# Key3 = [DSTPORT]
Key4 = [DSTIP, DSTPORT]
Key5 = [DSTIP]
Key6 = [SRCIP, DSTIP]
Key7 = [SRCIP, DSTIP, SRCPORT, DSTPORT]
Key8 = [SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO]

Key9 = [SRCPORT]

Key10 = [SRCIP, DSTPORT]
Key11 = [DSTIP, SRCPORT]

# pool_of_flowkeys = [Key1, Key2, Key3, Key4, Key5, Key6, Key7, Key8, Key9, Key10, Key11]
pool_of_flowkeys = [Key1, Key2, Key4, Key5, Key6, Key7, Key8]

# 10. unique # of flowsize
FLOW_SIZE_TYPE_PACKET = 1
FLOW_SIZE_TYPE_BYTE = 2
pool_of_flowsize = [1, 2]

# 11. unique # of sketch param
# 12. unique # of epoch
# pool_of_epochs = [10, 20, 30, 40, 50, 60, 70]
# pool_of_epochs = [15, 30, 45]
pool_of_epochs = [10, 20, 30, 40]
# pool_of_epochs = [10, 20, 30, 40, 50, 60]

F1 = "num_sketch_algo"
F2 = "num_stats"
F3 = "SLML"
F4 = "num_counter_update"
F5 = "num_dp"
F6 = "num_sampling"
F7 = "num_heavy"

F8 = "num_sketch_inst"
F9 = "num_flowkey"
F10 = "num_flowsize"
F11 = "num_sketch_param"
F12 = "num_epoch"

def get_default_spec():
    spec = {}

    total_sketch_num = 0
    for k, v in sketch_dict.items():
        total_sketch_num += len(v)

    spec[F1] = total_sketch_num
    spec[F2] = 8
    spec[F3] = [1, 2]
    spec[F4] = 5
    spec[F5] = [0, 1]
    spec[F6] = [0, 1]
    spec[F7] = [0, 1]

    spec[F8] = 20
    spec[F9] = 7
    spec[F10] = [1, 2]
    spec[F11] = 5
    spec[F12] = 4
    return spec
