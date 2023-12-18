from workload_manage.spec import *
from sketch_formats.sketch_instance import *
from lib.logging import print_msg


# F1
def get_name(inst):
    return inst.sketch.name
# F2
def get_stat(inst):
    return inst.sketch.statistic
# F3
def get_index_type(inst):
    return inst.sketch.index_type
# F4
def get_cu_type(inst):
    return inst.sketch.counter_update_type
# F5
def get_dp_type(inst):
    return inst.sketch.counter_in_dp_type
# F6
def get_samping(inst):
    return inst.sketch.sampling_compatible
# F7
def get_heavy(inst):
    return inst.sketch.heavy_flowkey_storage


# F8
def get_num_sketch_inst(inst_list):
    return len(inst_list)
# F9
def get_flowkey(inst):
    return inst.flowkey
# F10
def get_flowsize(inst):
    return inst.flowsize
# F11
def get_row(inst):
    return inst.row
# F12
def get_epoch(inst):
    return inst.epoch

def row_exception_sketches(inst):
    if inst.sketch.name == "LinearCounting" or \
        inst.sketch.name == "HLL" or \
        inst.sketch.name == "MRB" or \
        inst.sketch.name == "MRAC" or \
        inst.sketch.name == "PCSA":
        return True
    return False


class WorkloadGenerator:
    def __init__(self, input_spec):
        self.input_spec = {}
        for key in [F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12]:
            self.input_spec[key] = input_spec[key]

        self.num_instances = self.input_spec[F8]
        self.result_inst_list = []


    def dup_check_pass(self, flowkey, epoch, flowsize, statistic):
        for inst in self.result_inst_list:

            if inst.flowkey == flowkey and inst.epoch == epoch and inst.flowsize == flowsize and inst.sketch.statistic == statistic:
                return False

            if statistic == STATISTIC_TYPE_GENERAL:
                if inst.flowkey == flowkey and inst.epoch == epoch and inst.flowsize == flowsize:
                    if inst.sketch.statistic == STATISTIC_TYPE_ENTROPY or inst.sketch.statistic == STATISTIC_TYPE_HEAVY_HITTER:
                        return False
                if inst.flowkey == flowkey and inst.epoch == epoch:
                    if inst.sketch.statistic == STATISTIC_TYPE_CARDINALITY:
                        return False

            if inst.sketch.statistic == STATISTIC_TYPE_GENERAL:
                if inst.flowkey == flowkey and inst.epoch == epoch and inst.flowsize == flowsize:
                    if statistic == STATISTIC_TYPE_ENTROPY or statistic == STATISTIC_TYPE_HEAVY_HITTER:
                        return False
                if inst.flowkey == flowkey and inst.epoch == epoch:
                    if statistic == STATISTIC_TYPE_CARDINALITY:
                        return False

        return True


    def limit_check(self, new_inst, func, limit):
        check_dict = {}
        check_dict[ str( func(new_inst) )  ] = 1
        for inst in self.result_inst_list:
            check_dict[ str( func(inst) ) ] = 1
        if len(check_dict.keys()) > limit:
            return False
        return True


    def candidate_check(self, new_inst, func, candidates):
        check_dict = {}
        check_dict[func(new_inst)] = 1
        for inst in self.result_inst_list:
            check_dict[func(inst)] = 1
        for key in check_dict.keys():
            if key not in candidates:
                return False
        return True


    def contraint_check_pass(self, new_inst):
        # check for F1
        if self.limit_check(new_inst, get_name, self.input_spec[F1]) == False:
            print_msg("F1 fail", 10, "red")
            return False
        # check for F2
        if self.limit_check(new_inst, get_stat, self.input_spec[F2]) == False:
            print_msg("F2 fail", 10, "red")
            return False
        # check for F3
        if self.candidate_check(new_inst, get_index_type, self.input_spec[F3]) == False:
            print_msg("F3 fail", 10, "red")
            return False
        # check for F4
        if self.limit_check(new_inst, get_cu_type, self.input_spec[F4]) == False:
            print_msg("F4 fail", 10, "red")
            return False
        # check for F5
        if self.candidate_check(new_inst, get_dp_type, self.input_spec[F5]) == False:
            print_msg("F5 fail", 10, "red")
            return False
        # check for F6
        if self.candidate_check(new_inst, get_samping, self.input_spec[F6]) == False:
            print_msg("F6 fail", 10, "red")
            return False
        # check for F7
        if self.candidate_check(new_inst, get_heavy, self.input_spec[F7]) == False:
            print_msg("F7 fail", 10, "red")
            return False

        # check for F8 -> does not need to be checked
        # check for F9
        if self.limit_check(new_inst, get_flowkey, self.input_spec[F9]) == False:
            print_msg("F9 fail", 10, "red")
            return False
        # check for F10
        if self.candidate_check(new_inst, get_flowsize, self.input_spec[F10]) == False:
            print_msg("F10 fail", 10, "red")
            return False

        if row_exception_sketches(new_inst) == False:
            count_check_dict = {}
            count_check_dict[new_inst.row] = 1
            for inst in self.result_inst_list:
                if row_exception_sketches(inst) == False:
                    count_check_dict[inst.row] = 1

            if len(count_check_dict.keys()) > self.input_spec[F11]:
                print_msg("F11 fail", 10, "red")
                return False

        # check for F12
        if self.limit_check(new_inst, get_epoch, self.input_spec[F12]) == False:
            print_msg("F12 fail", 10, "red")
            return False

        return True


    def generate(self):
        from lib.inst_list import rand_select
        try_count = 0
        i = 0

        self.result_inst_list = []

        while True:
            try_count += 1
            if  try_count == 10000:
                print_msg(f"{try_count} limit", 3, "red")
                return False
            
            sketch = rand_select(sketch_list)
            flowkey = rand_select(pool_of_flowkeys)
            epoch = rand_select(pool_of_epochs)
            statistic = sketch.statistic
            flowsize = rand_select(pool_of_flowsize)
            if statistic == STATISTIC_TYPE_CARDINALITY or sketch.name == "BloomFilter":
                flowsize = 1

            if self.dup_check_pass(flowkey, epoch, flowsize, statistic) == False:
                print_msg("dup_check fail", 5, "red")
                continue
            inst = SketchInstance()
            inst.workload_init(sketch, flowkey, flowsize, epoch)
            if self.contraint_check_pass(inst) == False:
                print_msg("contraint_check fail", 5, "red")
                continue
            self.result_inst_list.append(inst)
            i += 1
            if i >= self.num_instances:
                break
        print_msg("generate done", 5, "cyan")
        return True
