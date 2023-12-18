from sw_dp_simulator.file_io.py.read_mrb import load_mrb

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

def bitset(M):
    count = 0
    for item in M:
        if item == 1:
            count+=1
    return count

def bitzero(M):
    count = 0
    for item in M:
        if item == 0:
            count+=1
    return count

def get_cardinality(M, level, width):
    # for base in range(0, level):
    #     level_counter = M[base*width:(base+1)*width]
    #     print(base, bitset(level_counter), bitzero(level_counter))
    for base in reversed(range(0, level-1)):
        level_counter = M[base*width:(base+1)*width]
        if bitset(level_counter) > width/4:
            break

    base = base + 1
    # print(base)
    m = 0
    for i in range(base, level):
        level_counter = M[i*width:(i+1)*width]
        z = bitzero(level_counter)
        # prevent division by zero
        if z == 0:
            z = 1
        import math
        m = m + width * (math.log(width/z))
    card = m*2**(base)
    return int(card)

def mrb_main(sketch_name, output_dir, row, width, level):
    result = load_mrb(output_dir, width, row, level)
    true_cardinality = result["cardinality"]
    
    # convert multi-level array to single array
    cArray = []
    for arr in result['sketch_array_list']:
        cArray += arr

    sim_cardinality = get_cardinality(cArray, level, width)
    sim_error = relative_error(true_cardinality, sim_cardinality)
    # print(true_cardinality, int(sim_cardinality), sim_error)
    print("true(%d) est(%d) error(%.2f%%)" % (true_cardinality, sim_cardinality, sim_error))
    return [true_cardinality, sim_cardinality, sim_error]
