from sw_dp_simulator.file_io.py.common import parse_line

def load_ground_truth(dir):
    # dict = {}
    # i = 0
    result = []
    with open('%s/ground_truth.txt' % dir) as f:
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            result.append((string_key, estimate, flowkey))
    return result


def load_ground_truth_topk(dir, topk):
    # dict = {}
    result = []
    i = 0
    with open('%s/ground_truth.txt' % dir) as f:
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            result.append((string_key, estimate, flowkey))
            i += 1
            if i == topk:
                break
            
    return result


def load_ground_truth_threshold(dir, threshold):
    # dict = {}
    result = []
    i = 0
    with open('%s/ground_truth.txt' % dir) as f:
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            if estimate < threshold:
                break
            result.append((string_key, estimate, flowkey))
            
    return result

def load_ground_truth_cardinality(dir):
    count = 0
    with open('%s/ground_truth.txt' % dir) as f:
        key = f.readline().strip()
        for line in f:
            count += 1
    return count

