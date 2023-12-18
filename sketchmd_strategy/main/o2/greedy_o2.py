

from sketch_formats.sketch_instance import *
from lib.inst_list import *
from opt.salu_reuse import *
from opt.salu_merge import *

from lib.logging import *
from python_lib.timeout import TimeoutManager

################ O2B bruteforce ################

def o2b_partition(o2a_inst_list, number_list):
    if len(number_list) == 1:
        yield [ number_list ]
        return

    first = number_list[0]

    for smaller in o2b_partition(o2a_inst_list, number_list[1:]):
        for n, subset in enumerate(smaller):
            check_o2a_inst_list = get_list_using_number_list(o2a_inst_list, [ first ] + subset)
            if SALU_merge_check(check_o2a_inst_list):
                yield smaller[:n] + [[ first ] + subset]  + smaller[n+1:]

        yield [[first]] + smaller


# input: list of o2a_inst with the same flowkey and the same index type
# output: list of o2a_inst and o2b_inst
# constraint: find out the best partition to minimize obj func
def greedy_o2b_bruteforce(o2a_inst_list):
    o2b_objective_function_cache = {}

    o2a_inst_list = sort_o2a_inst_by_r(o2a_inst_list)

    o2b_inst_list = []

    number_list = list(range(len(o2a_inst_list)))
    min = float('inf')
    answer_partition = []
    for i, p in enumerate(o2b_partition(o2a_inst_list, number_list), 1):
        partition_candidate = sorted(p)

        sum = 0
        for subset in partition_candidate:
            key = tuple(subset)
            if key in o2b_objective_function_cache:
                val = o2b_objective_function_cache[key]
            else:
                if len(subset) == 1:
                    val = o2a_inst_list[subset[0]].objective_function()['overall']
                else:
                    temp_o2a_inst_list = get_list_using_number_list(o2a_inst_list, subset)
                    o2b_inst = SALUMergeSketchInstance(temp_o2a_inst_list)
                    val =  o2b_inst.objective_function()['overall']

                o2b_objective_function_cache[key] = val
            sum += val

        if min > sum:
            min = sum
            answer_partition = partition_candidate

    for subset in answer_partition:
        if len(subset) == 1:
            o2b_inst_list.append(o2a_inst_list[subset[0]])
        else:
            new_o2a_inst_list = get_list_using_number_list(o2a_inst_list, subset)
            o2b_inst = SALUMergeSketchInstance(new_o2a_inst_list)
            o2b_inst_list.append(o2b_inst)

    return o2b_inst_list

################ O2B greedy ################

def pull_out_o2b_inst(o2a_inst_list):
    if len(o2a_inst_list) == 1:
        return None, o2a_inst_list
    
    for_o2b_inst_list = []
    remaining_o2a_inst_list = []
    
    big_o2a_inst = o2a_inst_list[0]

    for_o2b_inst_list.append(big_o2a_inst)

    if big_o2a_inst.get_counter_dp_type() == True:
        for o2a_inst in o2a_inst_list[1:]:
            if SALU_merge_check(for_o2b_inst_list + [o2a_inst]):
                for_o2b_inst_list += [o2a_inst]
            else:
                remaining_o2a_inst_list.append(o2a_inst)
    else:
        for o2a_inst in o2a_inst_list[1:]:
            if o2a_inst.get_counter_dp_type() == True:
                if SALU_merge_check(for_o2b_inst_list + [o2a_inst]):
                    for_o2b_inst_list += [o2a_inst]
                else:
                    remaining_o2a_inst_list.append(o2a_inst)
        for o2a_inst in o2a_inst_list[1:]:
            if o2a_inst.get_counter_dp_type() == False:
                if SALU_merge_check(for_o2b_inst_list + [o2a_inst]):
                    for_o2b_inst_list += [o2a_inst]
                else:
                    remaining_o2a_inst_list.append(o2a_inst)

    
    if len(for_o2b_inst_list) == 1:
        return None, o2a_inst_list
        
    o2b_inst = SALUMergeSketchInstance(for_o2b_inst_list)

    return o2b_inst, remaining_o2a_inst_list

def greedy_o2b_greedy(o2a_inst_list):
    o2a_inst_list = sort_o2a_inst_by_r(o2a_inst_list, False)

    o2b_inst_list = []
    new_o2a_inst_list = []

    count = 0
    while True:
        count += 1
        # print(count)
        if len(o2a_inst_list) == 0:
            break
        if len(o2a_inst_list) == 1:
            new_o2a_inst_list.append(o2a_inst_list[0])
            break
        o2b_inst, o2a_inst_list = pull_out_o2b_inst(o2a_inst_list)
        if o2b_inst == None:
            new_o2a_inst_list.append(o2a_inst_list[0])
            o2a_inst_list = o2a_inst_list[1:]
        else:
            o2b_inst_list.append(o2b_inst)

    return o2b_inst_list + new_o2a_inst_list

################ main ################

# input: list of o2a_inst
# output: list of o2a_inst or o2b_inst

def run_O2B_bf(clusters, return_dict):
    print_msg(f"        [greedy O2B bruteforce start]", 6, "cyan")

    o2inst_list = []
    for cluster in clusters:
        result = greedy_o2b_bruteforce(cluster)
        o2inst_list += result

    return_dict["o2inst_list"] = o2inst_list
    print_msg(f"        [greedy O2B bruteforce end]", 6, "cyan")

def run_O2B_greedy(clusters):
    print_msg(f"        [greedy O2B greedy start]", 6, "cyan")
    o2inst_list = []
    for cluster in clusters:
        result = greedy_o2b_greedy(cluster)
        o2inst_list += result
    print_msg(f"        [greedy O2B greedy end]", 6, "cyan")
    return o2inst_list

def greedy_O2B(o2inst_list, timeout):
    print_msg(f"    [greedy O2B start]", 6, "cyan")

    clusters = get_O2B_cluster(o2inst_list)
    timeout_manager = TimeoutManager(timeout, run_O2B_bf, [clusters])
    if timeout > 0 and timeout_manager.start():
        return_dict = timeout_manager.get_return_dict()
        o2inst_list = return_dict["o2inst_list"]
    else:
        o2inst_list = run_O2B_greedy(clusters)

    print_msg(f"    [greedy O2B end]", 6, "cyan")
    return o2inst_list
