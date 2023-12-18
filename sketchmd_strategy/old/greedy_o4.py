from sketch_formats.sketch_instance import *
from lib.inst_list import *
from opt.salu_reuse import *
from opt.salu_merge import *
from opt.o4 import *
from opt.o3o4 import *

from lib.logging import *
from python_lib.timeout import TimeoutManager

################# O4 bruteforce ################
def O4_merging_check_wrapper(o2o3inst_list):
    for o2o3inst in o2o3inst_list:
        if o2o3inst.__class__.__name__ == "SALUMergeSketchInstance":
            return False
    o2inst_list = o2o3inst_list
    return O4_merging_check(o2inst_list)

def o4_partition(o2o3inst_list, number_list):
    if len(number_list) == 1:
        yield [ number_list ]
        return

    first = number_list[0]

    for smaller in o4_partition(o2o3inst_list, number_list[1:]):
        for n, subset in enumerate(smaller):
            new_o2o3inst_list = get_list_using_number_list(o2o3inst_list, [ first ] + subset)
            if O3O4_merging_check(new_o2o3inst_list) or \
               O4_merging_check_wrapper(new_o2o3inst_list):
                yield smaller[:n] + [[ first ] + subset]  + smaller[n+1:]

        yield [[first]] + smaller

def o4_compute_obj_func(o2o3inst_list):
    if O3O4_merging_check(o2o3inst_list):
        o3o4inst = O3O4MergedSketchInstance(o2o3inst_list[0], o2o3inst_list[1])
        return o3o4inst.objective_function()['overall'], o3o4inst

    if O4_merging_check_wrapper(o2o3inst_list):
        o4inst = O4MergedSketchInstance(o2o3inst_list)
        return o4inst.objective_function()['overall'], o4inst

    if len(o2o3inst_list) == 1:
        return o2o3inst_list[0].objective_function()['overall'], o2o3inst_list[0]
    return float('inf'), None

def greedy_o4_bruteforce(o2o3inst_list):
    o4_objective_function_cache = {}

    o2o3o4inst_list = []

    number_list = list(range(len(o2o3inst_list)))
    min = float('inf')
    answer_partition = []
    answer_list = []

    i=0
    for p in o4_partition(o2o3inst_list, number_list):
        i+=1
        partition_candidate = sorted(p)

        o2o3o4inst_list = []
        sum = 0
        for subset in partition_candidate:
            key = tuple(subset)
            if key in o4_objective_function_cache:
                val, o2o3o4inst = o4_objective_function_cache[key]
            else:
                new_o2o3inst_list = get_list_using_number_list(o2o3inst_list, subset)
                val, o2o3o4inst = o4_compute_obj_func(new_o2o3inst_list)
                o4_objective_function_cache[key] = (val, o2o3o4inst)

            sum += val
            o2o3o4inst_list.append(o2o3o4inst)
        
        if min > sum:
            min = sum
            answer_partition = partition_candidate
            answer_list = o2o3o4inst_list

    return answer_list

################# O4 greedy ################

def find_O3O4(o2o3inst_list):
    length = len(o2o3inst_list)
    for i in range(0, length):
        for j in range(0, length):
            if j <= i:
                continue
            if O3O4_merging_check([o2o3inst_list[i]] + [o2o3inst_list[j]]):
                o3o4inst = O3O4MergedSketchInstance(o2o3inst_list[i], o2o3inst_list[j])
                new_o2o3inst_list = []
                for k in range(0, length):
                    if i != k and j != k:
                        new_o2o3inst_list.append(o2o3inst_list[k])
                return o3o4inst, new_o2o3inst_list
    return None, o2o3inst_list

def find_O2O4_one_or_two_keys(o2inst_list):
    for_o4_o2inst_list = []
    remaining_o2inst_list = []
    
    big_o2inst = o2inst_list[0]
    for_o4_o2inst_list.append(big_o2inst)

    # try to find the same flowkey as much as possible
    for o2inst in o2inst_list[1:]:
        if big_o2inst.flowkey == big_o2inst.flowkey and O4_merging_check(for_o4_o2inst_list + [o2inst]):
            for_o4_o2inst_list += [o2inst]
        else:
            remaining_o2inst_list.append(o2inst)
    
    # try to find one more subset flowkey
    unique_flowkeys = get_unique_flowkeys(remaining_o2inst_list)
    relevant_flowkeys = get_relevant_flowkeys(big_o2inst.flowkey, unique_flowkeys)

    best_val = float('inf')
    best_additional_o2inst_list = []
    best_remaining_o2inst_list = []

    for flowkey in relevant_flowkeys:
        temp_o2inst_list = []
        temp_remaining_o2_list = []

        for o2inst in remaining_o2inst_list:
            if o2inst.flowkey == flowkey and O4_merging_check(for_o4_o2inst_list + temp_o2inst_list + [o2inst]):
                temp_o2inst_list += [o2inst]
            else:
                temp_remaining_o2_list.append(o2inst)

        candidate_list = for_o4_o2inst_list + temp_o2inst_list
        if len(candidate_list) > 1:
            o2o4inst = O4MergedSketchInstance(candidate_list)
            val = o2o4inst.objective_function()['overall']
            if best_val > val:
                best_val = val
                best_additional_o2inst_list = temp_o2inst_list
                best_remaining_o2inst_list = temp_remaining_o2_list
            

    if best_val != float('inf'):
        for_o4_o2inst_list += best_additional_o2inst_list
        remaining_o2inst_list = best_remaining_o2inst_list
    
    # fill up remaining slots with unrelated flowkeys
    remaining_o2inst_list_new = []
    remaining_o2inst_list = sort_o2a_inst_list_by_flowkey(remaining_o2inst_list)
    for o2inst in remaining_o2inst_list:
        if O4_merging_check(for_o4_o2inst_list + [o2inst]):
            for_o4_o2inst_list += [o2inst]
        else:
            remaining_o2inst_list_new.append(o2inst)

    if len(for_o4_o2inst_list) == 1:
        return float('inf'), None, o2inst_list

    o2o4inst = O4MergedSketchInstance(for_o4_o2inst_list)
    return o2o4inst.objective_function()['overall'], o2o4inst, remaining_o2inst_list_new


def find_O2O4_three_keys(o2inst_list):
    for_o4_o2inst_list = []
    remaining_o2inst_list = []
    
    big_o2inst = o2inst_list[0]
    base_flowkey = big_o2inst.flowkey
    for_o4_o2inst_list.append(big_o2inst)

    # try to find the same flowkey as much as possible
    for o2inst in o2inst_list[1:]:
        if o2inst.flowkey == base_flowkey and O4_merging_check(for_o4_o2inst_list + [o2inst]):
            for_o4_o2inst_list += [o2inst]
        else:
            remaining_o2inst_list.append(o2inst)
    
    # try to find one more subset flowkey
    unique_flowkeys = get_unique_flowkeys(remaining_o2inst_list)
    two_relevant_flowkeys = get_two_relevant_flowkeys(big_o2inst.flowkey, unique_flowkeys)

    best_val = float('inf')
    best_additional_o2inst_list = []
    best_remaining_o2inst_list = []

    for (flowkey1, flowkey2) in two_relevant_flowkeys:
        temp_o2inst_list = []
        temp_remaining_o2_list = []

        for o2inst in remaining_o2inst_list:
            if (o2inst.flowkey == base_flowkey or o2inst.flowkey == flowkey1 or o2inst.flowkey == flowkey2) and O4_merging_check(for_o4_o2inst_list + temp_o2inst_list + [o2inst]):
                temp_o2inst_list += [o2inst]
            else:
                temp_remaining_o2_list.append(o2inst)

        candidate_list = for_o4_o2inst_list + temp_o2inst_list
        if len(candidate_list) > 1:
            o2o4inst = O4MergedSketchInstance(candidate_list)
            val = o2o4inst.objective_function()['overall']
            if best_val > val:
                best_val = val
                best_additional_o2inst_list = temp_o2inst_list
                best_remaining_o2inst_list = temp_remaining_o2_list
    

    if best_val != float('inf'):
        for_o4_o2inst_list += best_additional_o2inst_list
        remaining_o2inst_list = best_remaining_o2inst_list
    
    # fill up remaining slots with unrelated flowkeys
    remaining_o2inst_list_new = []
    remaining_o2inst_list = sort_o2a_inst_list_by_flowkey(remaining_o2inst_list)
    for o2inst in remaining_o2inst_list:
        if O4_merging_check(for_o4_o2inst_list + [o2inst]):
            for_o4_o2inst_list += [o2inst]
        else:
            remaining_o2inst_list_new.append(o2inst)

    if len(for_o4_o2inst_list) == 1:
        return float('inf'), None, o2inst_list

    o2o4inst = O4MergedSketchInstance(for_o4_o2inst_list)
    return o2o4inst.objective_function()['overall'], o2o4inst, remaining_o2inst_list_new

def pull_out_o2o4inst(o2inst_list):
    if len(o2inst_list) == 1:
        return None, o2inst_list
    
    # candidate 1. all same flowkey or two flowkeys + anything remaining
    val_1, o2o4inst_1, new_o2inst_list_1 = find_O2O4_one_or_two_keys(o2inst_list)

    # candidate 2. two flowkeys, (subset relationship) + anything remaining
    val_2, o2o4inst_2, new_o2inst_list_2 = find_O2O4_three_keys(o2inst_list)

    minval = min(val_1, val_2)
    if minval == float('inf'):
        return None, o2inst_list
    elif minval == val_1:
        o2o4inst = o2o4inst_1
        new_o2inst_list = new_o2inst_list_1
    else:
        o2o4inst = o2o4inst_2
        new_o2inst_list = new_o2inst_list_2

    return o2o4inst, new_o2inst_list

def greedy_o4_greedy(input_list):
    print_msg(f"        [greedy O4 greedy start]", 6, "cyan")
    result_list = []

    # input_list: o2o3_list
    # result_list: o2o3o4_list

    # 1. get as much as O3/O4 first
    while True:
        o3o4inst, input_list = find_O3O4(input_list)
        if o3o4inst == None:
            break
        result_list.append(o3o4inst)
    

    # 2. don't care O3 anymore, add it to the result list
    o2inst_list = []
    for o2o3inst in input_list:
        if o2o3inst.__class__.__name__ == "SALUMergeSketchInstance":
            result_list.append(o2o3inst)
        elif o2o3inst.__class__.__name__ == "SALUReuseSketchInstance":
            if o2o3inst.sampling_compatible() == False:
                result_list.append(o2o3inst)
            else:
                o2inst_list.append(o2o3inst)
    
    # 3. do the similar process as greedy o3, but think of o1 (flowkey) as well
    o2inst_list = sort_o2a_inst_by_r(o2inst_list, False)

    count = 0
    while True:
        if len(o2inst_list) == 0:
            break
        if len(o2inst_list) == 1:
            result_list.append(o2inst_list[0])
            break
        o2o4inst, o2inst_list = pull_out_o2o4inst(o2inst_list)
        if o2o4inst == None:
            result_list.append(o2inst_list[0])
            o2inst_list = o2inst_list[1:]
        else:
            result_list.append(o2o4inst)

    print_msg(f"        [greedy O4 greedy end]", 6, "cyan")
    return result_list

def run_O4_bf(o2o3inst_list, return_dict):
    print_msg(f"        [greedy O4 bruteforce start]", 6, "cyan")
    o2o3o4inst_list = greedy_o4_bruteforce(o2o3inst_list)
    return_dict["o2o3o4inst_list"] = o2o3o4inst_list
    print_msg(f"        [greedy O4 bruteforce end]", 6, "cyan")

# # input: list of (o2inst or o3inst)
# # output: list of (o2inst or o3inst or o4inst or o3o4inst)
def greedy_O4(o2o3inst_list, timeout):
    print_msg(f"    [greedy O4 start]", 6, "cyan")

    o2o3o4inst_list = []

    timeout_manager = TimeoutManager(timeout, run_O4_bf, [o2o3inst_list])
    if timeout > 0 and timeout_manager.start():
        return_dict = timeout_manager.get_return_dict()
        o2o3o4inst_list = return_dict["o2o3o4inst_list"]
    else:
        o2o3o4inst_list = greedy_o4_greedy(o2o3inst_list)

    print_msg(f"    [greedy O4 end]", 6, "cyan")
    return o2o3o4inst_list

