from sw_dp_simulator.file_io.py.read_hll import load_hll

def relative_error(true, estimate):
    return abs(true-estimate)/true*100


def get_cardinality(M, width):
    m = width
    card = 0.39701 * m * 2 ** ((1.0 / m) * sum(M))

    return card


def ll_main(sketch_name, output_dir, row, width, level):
    result = load_hll(output_dir, width, 1)
    true_cardinality = result["cardinality"]
    sim_cardinality = get_cardinality(result["sketch_array_list"][0], width)
    sim_error = relative_error(true_cardinality, sim_cardinality)
    # print(true_cardinality, int(sim_cardinality), sim_error)
    print("ll: true(%d) est(%d) error(%.2f%%)" % (true_cardinality, sim_cardinality, sim_error))
    return [true_cardinality, sim_cardinality, sim_error]
