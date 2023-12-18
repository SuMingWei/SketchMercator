from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth

def bitset(M):
    count = 0
    for item in M:
        if item > 0:
            count+=1
    return count

def bitzero(M):
    count = 0
    for item in M:
        if item == 0:
            count+=1
    return count

def get_cardinality(M, level, width):
    for base in reversed(range(0, level-1)):
        level_counter = M[base*width:(base+1)*width]
        # print(base, bitset(level_counter), width)
        if bitset(level_counter) > width/4:
            break

    base = base + 1
    # print(base)
    m = 0
    for i in range(base, level):
        level_counter = M[i*width:(i+1)*width]
        z = bitzero(level_counter)
        import math
        m = m + width * (math.log(width/z))
    card = m*2**(base)
    return int(card)


#### class BetaGenerator ####

class BetaGenerator:
    def __init__(self, sum):

        # int
        self.sum = sum
        self.now_flow_num = 0

        if self.sum > 600:
            self.flow_num_limit = 2
        elif self.sum > 250:
            self.flow_num_limit = 3
        elif self.sum > 100:
            self.flow_num_limit = 4
        elif self.sum > 50:
            self.flow_num_limit = 5
        else:
            self.flow_num_limit = 6
        
        # list
        self.now_result = []


    def get_new_comb(self):
        for j in reversed(range(0, self.now_flow_num-1)):
            self.now_result[j] += 1
            t = self.now_result[j]
            for k in range(j+1, self.now_flow_num):
                self.now_result[k] = t
            partial_sum = 0
            for k in range(0, self.now_flow_num-1):
                partial_sum += self.now_result[k]
            remain = self.sum - partial_sum
            if remain >= self.now_result[self.now_flow_num - 2]:
                self.now_result[self.now_flow_num - 1] = remain
                return True
        return False

    def get_next(self):
        while self.now_flow_num <= self.flow_num_limit:
            if self.now_flow_num == 0:
                self.now_flow_num = 1
                self.now_result = [self.sum]
                return True
            elif self.now_flow_num == 1:
                self.now_flow_num = 2
                self.now_result[0] = 0

            while len(self.now_result) < self.now_flow_num:
                self.now_result.append(0)
            if self.get_new_comb():
                return True
            else:
                self.now_flow_num += 1
                for i in range(0, self.now_flow_num-2):
                    self.now_result[i] = 1
                self.now_result[self.now_flow_num-2] = 0
        return False

def factorial (n):
    if n == 0 or n == 1:
        return 1
    return n * factorial(n-1)


def get_p_from_beta(bt, lamb, now_dist, now_n, width):
    
    mp = {}
    for i in range(0, bt.now_flow_num):
        if bt.now_result[i] in mp:
            mp[bt.now_result[i]] += 1
        else:
            mp[bt.now_result[i]] = 1
    import math
    ret = math.exp(-lamb)
    for si, fi in mp.items():
        lamb_i = now_n * now_dist[si] / float(width)
        ret *= (lamb_i ** fi) / factorial (fi)
    return ret


class MRAC:
    def __init__(self):
        pass
    
    def set_counters(self, width, counters):
        # int
        self.width = width
        self.max_cnt = max(counters)

        # list
        self.counter_dist = [0] * (self.max_cnt+1)
        for count in counters:
            self.counter_dist[count] += 1

        # int
        self.n_new = self.width - self.counter_dist[0]

        # list
        self.dist_new = [0] * (self.max_cnt+1)
        self.ns = [0] * (self.max_cnt+1)
        for i in range(1, self.max_cnt+1):
            self.ns[i] = self.counter_dist[i]
            self.dist_new[i] = self.counter_dist[i] / float(self.width - self.counter_dist[0])
    

    def next_epoch(self):
        # list
        self.dist_old = self.dist_new

        # int
        self.n_old = self.n_new
    
        lamb = self.n_old / float(self.width)

        for i in range(1, self.max_cnt+1):
            self.ns[i] = 0

        for i in range(1, self.max_cnt+1):
            if self.counter_dist[i] == 0:
                continue
            bts1 = BetaGenerator(i)
            bts2 = BetaGenerator(i)
            sum_p = 0.0

            while bts1.get_next():
                p = get_p_from_beta(bts1, lamb, self.dist_old, self.n_old, self.width)
                sum_p += p

            while bts2.get_next():
                p = get_p_from_beta(bts2, lamb, self.dist_old, self.n_old, self.width)
                for j in range(0, bts2.now_flow_num):
                    self.ns[bts2.now_result[j]] += self.counter_dist[i] * p / sum_p
                sum_p += p
        
        self.n_new = 0.0
        for i in range(1, self.max_cnt+1):
            self.n_new += self.ns[i]

        for i in range(1, self.max_cnt+1):
            self.dist_new[i] = self.ns[i] / self.n_new

        self.n_sum = self.n_new


        





def get_mrac_error(param, gt_path, data):
    width, level = param
    # print(width, level)

    gt_data = load_ground_truth(gt_path)
    true_cardinality = len(gt_data)

    max_cnt = 0
    for entry in gt_data:
        if entry[1] > max_cnt:
            max_cnt = entry[1]
    print("max_cnt:", max_cnt)
    true_dist = [0] * (max_cnt+1)
    for entry in gt_data:
        true_dist[entry[1]] += 1

    est_cardinality = get_cardinality(data[0], level, width)
    print("true:", true_cardinality)
    print("est:", est_cardinality)

    est_cardinality_temp = est_cardinality
    for base in range(0, level):
        est_cardinality_temp = est_cardinality_temp/2
        if est_cardinality_temp <= width:
            break

    level_counter = data[0][base*width:(base+1)*width]
    print(base, bitset(level_counter), bitzero(level_counter))

    MRAC_inst = MRAC()
    MRAC_inst.set_counters(width, level_counter)

    for em_epoch in range(0, 1):
        MRAC_inst.next_epoch()
        dist_est = MRAC_inst.ns
        
    WMRD_nom = 0
    WMRD_denom = 0
    for i in range(1, len(true_dist)):
        true = true_dist[i]
        if i < len(dist_est):
            est = dist_est[i] * (2**(base+1))
        else:
            est = 0
        # print(i, true, est, est * (2**(base+1)))
        WMRD_nom += abs(true - est)
        WMRD_denom += float(true + est)/2
    WMRD = WMRD_nom/WMRD_denom

    print("[EM] %d th epoch...with cardinality : %8.2f WMRD (%3.5f)\n" % (em_epoch, MRAC_inst.n_sum, WMRD))
    return WMRD
