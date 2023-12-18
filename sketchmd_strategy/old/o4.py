import pandas as pd

from sketch_formats.sketch_instance import *
from sketch_formats.sketch import *
from lib.obj_func import *
from lib.inst_list import *
from opt.salu_reuse import *
from opt.salu_merge import *

# base_flowkey = flowkey1 xor flowkey2
# flowkey1 = base_flowkey xor flowkey2
# flowkey2 = base_flowkey xor flowkey1
def get_min_hashcall_three(base_flowkey, base_r, flowkey1, flowkey2, o2inst_list):
    hash_instruction = ""

    remaining_dict = {}
    remaining_dict[str(base_flowkey)] = base_r

    total_hashcall = base_r
    for o2inst in o2inst_list:
        max_r = o2inst.get_max_r()
        total_hashcall += max_r
        if str(o2inst.flowkey) not in remaining_dict:
            remaining_dict[str(o2inst.flowkey)] = max_r
        else:
            remaining_dict[str(o2inst.flowkey)] = max(max_r, remaining_dict[str(o2inst.flowkey)])


    count_base = remaining_dict[str(base_flowkey)]
    count_1 = remaining_dict[str(flowkey1)]
    count_2 = remaining_dict[str(flowkey2)]

    msg = f"base ({str(base_flowkey)}, {count_base})\n\
flowkey1 ({str(flowkey1)}, {count_1})\n\
flowkey2 ({str(flowkey2)}, {count_2})\n"

    remaining = 0
    for k, v in remaining_dict.items():
        if k != str(base_flowkey) and k != str(flowkey1) and k != str(flowkey2):
            remaining += v
            msg += f"remaining ({k}, {v})\n"

    if base_flowkey == set_union(flowkey1, flowkey2):
        new_count_1 = count_1
        new_count_2 = count_2
        while new_count_1 * new_count_2 < count_base:
            if new_count_1 < new_count_2:
                new_count_1 += 1
            else:
                new_count_2 += 1
        reduced_hashcall = new_count_1 + new_count_2 + remaining
        total_reduction = total_hashcall - reduced_hashcall
        hash_instruction = msg
        hash_instruction += "-"*15 +"\n"
        hash_instruction += f"base ({str(base_flowkey)}, 0) = flowkey1 ({str(flowkey1)}, {new_count_1}) XOR flowkey2 ({str(flowkey2)}, {new_count_2})\n"
        hash_instruction += f"Total {reduced_hashcall} = {new_count_1} + {new_count_2} + {remaining} hash calls / reduction by XOR {count_base+count_1+count_2-new_count_1-new_count_2} reduction by total {total_reduction}\n"
        # print(hash_instruction)

    else: # in the case of flowkey1 = base xor flowkey2
        if flowkey1 == set_union(base_flowkey, flowkey2):
            reduced_hashcall = count_base + count_2 + remaining
            total_reduction = total_hashcall - reduced_hashcall
            hash_instruction = msg
            hash_instruction += "-"*15 +"\n"
            hash_instruction += f"flowkey1 ({str(flowkey1)}, 0) = base ({str(base_flowkey)}, {count_base}) XOR flowkey2 ({str(flowkey2)}, {count_2})\n"
            hash_instruction += f"Total {reduced_hashcall} = {count_base} + {count_2} + {remaining} hash calls \ reduction by XOR = {count_1} reduction by total {total_reduction}\n"
            # print(hash_instruction)

        else: # flowkey2 == set_union(base_flowkey, flowkey1):
            reduced_hashcall = count_base + count_1 + remaining
            total_reduction = total_hashcall - reduced_hashcall
            hash_instruction = msg
            hash_instruction += "-"*15 +"\n"
            hash_instruction += f"flowkey2 ({str(flowkey2)}, 0) = base ({str(base_flowkey)}, {count_base}) XOR flowkey1 ({str(flowkey1)}, {count_1})\n"
            hash_instruction += f"Total {reduced_hashcall} = {count_base} + {count_1} + {remaining} hash calls\ reduction by XOR = {count_2} reduction by total {total_reduction}\n"
            # print(hash_instruction)

    return reduced_hashcall, hash_instruction, total_reduction

# two hashcall -> hash(A, B, C) = hash(A, B) xor hash (B)
# in this case, if we compute multiple of hash(A, B), then 1 of hash(B), we can get hash (A, B, C)
def get_min_hashcall_two(base_flowkey, base_r, flowkey1, o2inst_list):
    remaining_dict = {}
    remaining_dict[str(base_flowkey)] = base_r

    total_hashcall = base_r
    for o2inst in o2inst_list:
        max_r = o2inst.get_max_r()
        total_hashcall += max_r
        if str(o2inst.flowkey) not in remaining_dict:
            remaining_dict[str(o2inst.flowkey)] = max_r
        else:
            remaining_dict[str(o2inst.flowkey)] = max(max_r, remaining_dict[str(o2inst.flowkey)])

    count_base = remaining_dict[str(base_flowkey)]
    count_1 = remaining_dict[str(flowkey1)]

    msg = f"base ({str(base_flowkey)}, {count_base})\n\
flowkey1 ({str(flowkey1)}, {count_1})\n"

    remaining = 0
    for k, v in remaining_dict.items():
        if k != str(base_flowkey) and k != str(flowkey1):
            remaining += v
            msg += f"remaining ({k}, {v})\n"
    # print(msg)

    if is_subset(base_flowkey, flowkey1):
        count_2 = 1
        while count_1 * count_2 < count_base:
            count_2 += 1

        reduced_hashcall = count_1 + count_2 + remaining
        total_reduction = total_hashcall - reduced_hashcall
        hash_instruction = msg
        hash_instruction += "-"*15 +"\n"
        hash_instruction += f"base ({str(base_flowkey)}, 0) = flowkey1 ({str(flowkey1)}, {count_1}) XOR subtracted ({str(list(set(base_flowkey) - set(flowkey1)))}, {count_2})\n"
        hash_instruction += f"Total {reduced_hashcall} = {count_1} + {count_2} + {remaining} hash calls / reduction by XOR {count_base - count_2} reduction by total {total_reduction}\n"
        # print(hash_instruction)
    else: # flowkey1 = base xor something
        reduced_hashcall = count_base + 1 + remaining
        total_reduction = total_hashcall - reduced_hashcall
        hash_instruction = msg
        hash_instruction += "-"*15 +"\n"
        hash_instruction += f"flowkey1 ({str(flowkey1)}, 0) = base ({str(base_flowkey)}, {count_base}) XOR subtracted ({str(list(set(flowkey1) - set(base_flowkey)))}, 1)\n"
        hash_instruction += f"Total {reduced_hashcall} = {count_base} + 1 + {remaining} hash calls / reduction by XOR {count_1 - 1} reduction by total {total_reduction}\n"
        # print(hash_instruction)

    return reduced_hashcall, hash_instruction, total_reduction

# get max flowkey per each and add them up
def get_min_hashcall_one(base_flowkey, base_r, o2inst_list):
    remaining_dict = {}
    remaining_dict[str(base_flowkey)] = base_r

    total_hashcall = base_r
    for o2inst in o2inst_list:
        max_r = o2inst.get_max_r()
        total_hashcall += max_r
        if str(o2inst.flowkey) not in remaining_dict:
            remaining_dict[str(o2inst.flowkey)] = max_r
        else:
            remaining_dict[str(o2inst.flowkey)] = max(max_r, remaining_dict[str(o2inst.flowkey)])

    msg = ""
    reduced_hashcall = 0
    for k, v in remaining_dict.items():
        msg += f"remaining ({k}, {v})\n"
        reduced_hashcall += v
    total_reduction =  total_hashcall - reduced_hashcall
    hash_instruction = msg
    hash_instruction += "-"*15 +"\n"
    hash_instruction += f"Total {reduced_hashcall} (no reduction by XOR) reduction by total {total_reduction}"
    # print(hash_instruction)

    return reduced_hashcall, hash_instruction, total_reduction


class O4MergedSketchInstance: # represent O2+O4
    def __init__(self, o2inst_list):
        if len(o2inst_list) == 1:
            print("error, O4MergedSketchInstance can't receive 1 o2inst, exit")
            exit(1)
        max_r = 0
        for o2inst in o2inst_list:
            if max_r < o2inst.get_max_r():
                max_r = o2inst.get_max_r()

        self.big_o2inst = None
        self.small_o2inst_list = []

        for o2inst in o2inst_list:
            if max_r == o2inst.get_max_r() and self.big_o2inst == None:
                self.big_o2inst = o2inst
            else:
                self.small_o2inst_list.append(o2inst)

        self.big_counter_update_type = self.big_o2inst.counter_update_type
        self.hashcall_instruction = "NULL"

    def getSRAM(self):
        big_r, big_list = self.big_o2inst.get_merged_configurations_epoch() # big_list = [(1024, 1), (1024, 1), (1024, 1)]
        small_list = []
        small_r = 0
        for o2inst in self.small_o2inst_list:
            _small_r, _small_list = o2inst.get_merged_configurations_epoch()
            small_r += _small_r
            small_list += _small_list

        SRAM = 0
        epoch_diff_sum = 0
        for A, B in zip(big_list, small_list):
            (A_max_width, A_max_level, A_epoch) = A
            (B_max_width, B_max_level, B_epoch) = B
            SRAM += 2 * ((A_max_width * A_max_level) + (B_max_width * B_max_level))
            epoch_diff_sum += abs(A_epoch - B_epoch)

        for A in big_list[small_r:]:
            (A_max_width, A_max_level, epoch) = A
            SRAM += A_max_width * A_max_level
        return SRAM, epoch_diff_sum

    def get_all_inst_list(self):
        total_sketch_inst_list = []
        total_sketch_inst_list += self.big_o2inst.sketch_inst_list
        for o2inst in self.small_o2inst_list:
            total_sketch_inst_list += o2inst.sketch_inst_list
        return total_sketch_inst_list

    def get_resource_usage(self):
        O1_hashcall_reduction = 0
        big_r, big_list = self.big_o2inst.get_merged_configurations_epoch() # left_list = [(1024, 1), (1024, 1), (1024, 1)]

        # first find three including big one
        unique_flowkeys = get_unique_flowkeys(self.small_o2inst_list)
        two_relevant_flowkeys = get_two_relevant_flowkeys(self.big_o2inst.flowkey, unique_flowkeys)

        min_hashcall = float('inf')
        for (flowkey1, flowkey2) in two_relevant_flowkeys:
            hashcall_count, msg, reduction = get_min_hashcall_three(self.big_o2inst.flowkey, big_r, flowkey1, flowkey2, self.small_o2inst_list)
            if min_hashcall > hashcall_count:
                min_hashcall = hashcall_count
                self.hashcall_instruction = msg
                O1_hashcall_reduction = reduction
        
        relevant_flowkeys = get_relevant_flowkeys(self.big_o2inst.flowkey, unique_flowkeys)
        for flowkey in relevant_flowkeys:
            hashcall_count, msg, reduction = get_min_hashcall_two(self.big_o2inst.flowkey, big_r, flowkey, self.small_o2inst_list)
            if min_hashcall > hashcall_count:
                min_hashcall = hashcall_count
                self.hashcall_instruction = msg
                O1_hashcall_reduction = reduction
        
        hashcall_count, msg, reduction = get_min_hashcall_one(self.big_o2inst.flowkey, big_r, self.small_o2inst_list)
        if min_hashcall > hashcall_count:
            min_hashcall = hashcall_count
            self.hashcall_instruction = msg
            O1_hashcall_reduction = reduction
        
        hash_call = min_hashcall + big_r

        SALU = big_r
        SRAM, epoch = self.getSRAM()

        return hash_call, SALU, SRAM, epoch, O1_hashcall_reduction

    def objective_function(self):
        hash_call, SALU, SRAM, epoch, O1_hashcall_reduction = self.get_resource_usage()
        ret = {}
        ret['overall'] = global_objective_function(hash_call, SALU, SRAM, epoch)
        ret['hashcall'] = global_objective_function(hash_call, 0, 0, 0)
        ret['salu'] = global_objective_function(0, SALU, 0, 0)
        ret['sram'] = global_objective_function(0, 0, SRAM, 0)
        
        return pd.Series(ret)

    def objective_function_breakdown(self):
        before = compute_baseline(self.get_all_inst_list())

        hash_call, SALU, SRAM, epoch, O1_hashcall_reduction = self.get_resource_usage()

        df = self.big_o2inst.objective_function_breakdown()
        for o2inst in self.small_o2inst_list:
            df += o2inst.objective_function_breakdown()

        after = {}
        after['hashcall'] = global_objective_function(hash_call, 0, 0, 0)
        after['salu'] = global_objective_function(0, SALU, 0, 0)
        after['sram'] = global_objective_function(0, 0, SRAM, 0)

        # TODO - Let's continue to work on this tomorrow
        # I need more fine-grained update here between O1/O4

        data = {}
        data['before'] = [before['hashcall'], before['salu'], before['sram']]
        data['after'] = [after['hashcall'], after['salu'], after['sram']]

        data['O1'] = [df["O1"]["hashcall"]+O1_hashcall_reduction, df["O1"]["salu"], df["O1"]["sram"]]
        data['O2'] = [df["O2"]["hashcall"], df["O2"]["salu"], df["O2"]["sram"]]
        data['O3'] = [0, 0, 0]
        data['O4'] = [before['hashcall'] - after['hashcall'] - (df["O1"]["hashcall"]+df["O2"]["hashcall"]+O1_hashcall_reduction), \
                        before['salu'] - after['salu'] - (df["O1"]["salu"]+df["O2"]["salu"]), \
                        before['sram'] - after['sram'] - (df["O1"]["sram"]+df["O2"]["sram"])]

        df = pd.DataFrame(data, index=["hashcall", "salu", "sram"])
        return df


    def print(self):
        print(" "*5 + "*"*40 + "[O4]" + "*"*41)
        print("     [Hash Call Instruction Start]")
        print(self.hashcall_instruction)
        print("     [Hash Call Instruction Done]")

        print("[Big]")
        self.big_o2inst.print()
        print("[Small]")
        for o2inst in self.small_o2inst_list:
            o2inst.print()
            print()
        print(" "*5 + "*"*85)
        print()


def O4_merging_check(o2inst_list):
    # 220220
    # checking O4 only is to check whether we can use sampling over multiple sketches
    # think of (5 rows) + (1 + 2 + 2 rows)
    # we should consider counter update type + sampling compatible

    if len(o2inst_list) == 1:
        return False
    if merging_sum_check(o2inst_list) == False:
        return False

    o2inst = o2inst_list[0]
    counter_update_type = o2inst.counter_update_type
    counter_bit = o2inst.counter_bit
    for o2inst in o2inst_list:
        if o2inst.counter_update_type != counter_update_type:
            return False
        if o2inst.counter_bit != counter_bit:
            return False
        if o2inst.sampling_compatible() == False:
            return False
    return True

