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


    def dup_check_pass(self, candidate, statistic):
        flowkey, flowsize, epoch = candidate
        for inst in self.result_inst_list:
            if inst.sketch.statistic == statistic and inst.flowkey == flowkey and inst.epoch == epoch and inst.flowsize == flowsize:
                # print("fail1")
                return False

            if statistic == STATISTIC_TYPE_GENERAL:
                if inst.flowkey == flowkey and inst.epoch == epoch and inst.flowsize == flowsize:
                    if inst.sketch.statistic == STATISTIC_TYPE_ENTROPY or inst.sketch.statistic == STATISTIC_TYPE_HEAVY_HITTER:
                        # print("fail2")
                        return False
                if inst.flowkey == flowkey and inst.epoch == epoch:
                    if inst.sketch.statistic == STATISTIC_TYPE_CARDINALITY:
                        # print("fail3")
                        return False

            if inst.sketch.statistic == STATISTIC_TYPE_GENERAL:
                if inst.flowkey == flowkey and inst.epoch == epoch and inst.flowsize == flowsize:
                    if statistic == STATISTIC_TYPE_ENTROPY or statistic == STATISTIC_TYPE_HEAVY_HITTER:
                        # print("fail4")
                        return False
                if inst.flowkey == flowkey and inst.epoch == epoch:
                    if statistic == STATISTIC_TYPE_CARDINALITY:
                        # print("fail5")
                        return False

            if self.input_spec[F9] == 1:
                if inst.flowkey != flowkey:
                    return False
            
            if self.input_spec[F12] == 1:
                if inst.epoch != epoch:
                    return False

        return True

    def get_candidate_list(self, statistic):

        candidate_list = []

        if self.input_spec[F10] != [1] and (statistic == STATISTIC_TYPE_HEAVY_HITTER or statistic == STATISTIC_TYPE_HEAVY_CHANGE):
            for flowkey in pool_of_flowkeys:
                for flowsize in pool_of_flowsize:
                    for epoch in pool_of_epochs:
                        candidate_list.append((flowkey, flowsize, epoch))
        else:
            for flowkey in pool_of_flowkeys:
                for epoch in pool_of_epochs:
                    candidate_list.append((flowkey, 1, epoch))
        return candidate_list

    def generate(self):
        from lib.inst_list import rand_select, rand_select_and_remove

        retry = 0

        while True:
            flag = False
            self.result_inst_list = []

            if self.input_spec[F1] == 1: # workload 1
                sketch = rand_select(pool_of_sketches)
                for i in range(self.input_spec[F8]):
                    inst = SketchInstance()
                    inst.workload_init(sketch, None, None, None)
                    self.result_inst_list.append(inst)
            else:
                flowkey = None
                flowsize = None
                epoch = None
                if self.input_spec[F9] == 1:
                    flowkey = rand_select(pool_of_flowkeys)
                if self.input_spec[F12] == 1:
                    epoch = rand_select(pool_of_epochs)
                for i in range(self.input_spec[F8]):
                    inst = SketchInstance()
                    sketch = rand_select(pool_of_sketches)
                    # print(sketch.name, flowkey, flowsize, epoch)
                    inst.workload_init(sketch, flowkey, flowsize, epoch)
                    self.result_inst_list.append(inst)

            for i in [0, 1]:
                for inst in self.result_inst_list:
                    if (i == 0 and inst.sketch.name == "UnivMon") or (i == 1 and inst.sketch.name != "UnivMon"):
                        candidate_list = self.get_candidate_list(inst.sketch.statistic)
                        # for e in candidate_list:
                        #     print(e)
                        # print(len(candidate_list))
                        new_candidate_list = []
                        for candidate in candidate_list:
                            if self.dup_check_pass(candidate, inst.sketch.statistic):
                                new_candidate_list.append(candidate)
                            # else:
                            #     print("fail")
                        # print(len(new_candidate_list))
                        if len(new_candidate_list) == 0:
                            print_msg("out of candidate_list, retry", 10, "yellow")
                            flag = True
                            break
                        flowkey, flowsize, epoch = rand_select(new_candidate_list)
                        inst.flowkey = flowkey
                        inst.flowsize = flowsize
                        inst.epoch = epoch
                if flag:
                    break
            if flag:
                # exit(1)
                retry+=1
                # print(retry)
                if retry % 100 == 0:
                    print_msg(f"retry : {retry}", 3, "red")
            else:
                break
        return True
