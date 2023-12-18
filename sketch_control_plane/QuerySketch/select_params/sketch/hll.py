from sw_dp_simulator.file_io.py.read_hll import load_hll
from hyperloglog import HyperLogLog
import math

def relative_error(true, estimate):
    return abs(true-estimate)/true*100


def get_cardinality(M, width):
    hll = HyperLogLog(1.04 / math.sqrt(width))
    new_list = []
    for item in M:
        new_list.append(item+1)
    hll.M = new_list
    return hll.card()

    # # hll = HyperLogLog(0.03) # 2048
    # p = 0.7213/(1+1.079/width)
    # print(p)
    # # hll = HyperLogLog(0.7213/(1+1.079/width))
    # # hll = HyperLogLog(0.01)
    # # exit(1)
    # Z = 0
    # for item in M:
    #     Z += 2**(-1*item)
    # Z = 1/Z
    # return p * width * width * Z

def bitzero(M):
    count = 0
    for item in M:
        if item == 0:
            count+=1
    return count

def get_cardinality_mine(M, width):
    m = width
    if m <= 16:
        am = 0.673
    elif m <= 32:
        am = 0.697
    elif m <= 64:
        am = 0.709
    else:
        am = 0.7213 / (1 + 1.079 / float(m))
    print(f"am: {am}")
    raw_e = am * (m ** 2) * math.pow(sum(math.pow(2, -x) for x in M), -1)
    # return raw_e
    
    correction_threshold = 32
    if raw_e <= 5/2.0 * m: # Small range correction
        # count number or registers equal to 0
        v = bitzero(M)
        if v != 0:
            return m * math.log2(m / float(v))
        else:
            return raw_e
    elif raw_e <= 1/30.0 * 2 ** correction_threshold: # intermidiate range correction -> No correction
        return raw_e
    else:
        return -2 ** correction_threshold * math.log2(1 - raw_e / 2.0**correction_threshold)

def hll_main(sketch_name, output_dir, row, width, level):
    result = load_hll(output_dir, width, 1)
    true_cardinality = result["cardinality"]
    sim_cardinality = get_cardinality(result["sketch_array_list"][0], width)
    # sim_cardinality = get_cardinality_mine(result["sketch_array_list"][0], width)
    sim_error = relative_error(true_cardinality, sim_cardinality)
    # print(true_cardinality, int(sim_cardinality), sim_error)
    print("true(%d) est(%d) error(%.2f%%)" % (true_cardinality, sim_cardinality, sim_error))
    return [true_cardinality, sim_cardinality, sim_error]
