from sketch_formats.sketch_instance import *
from lib.inst_list import *
from opt.salu_reuse import *
from opt.salu_merge import *
from opt.o4 import *
from opt.o3o4 import *

from lib.logging import *
from python_lib.timeout import TimeoutManager

################ O3 bruteforce ################

def o3_partition(o2inst_list, number_list):
    if len(number_list) == 1:
        yield [ number_list ]
        return

    first = number_list[0]

    for smaller in o3_partition(o2inst_list, number_list[1:]):
        for n, subset in enumerate(smaller):
            check_o2inst_list = get_list_using_number_list(o2inst_list, [ first ] + subset)
            if SALU_merge_check(check_o2inst_list):
                yield smaller[:n] + [[ first ] + subset]  + smaller[n+1:]

        yield [[first]] + smaller


# input: list of o2inst with the same flowkey and the same index type
# output: list of o2inst and o3 inst
# constraint: find out the best partition to minimize obj func
def greedy_o3_bruteforce(o2inst_list):
    o3_objective_function_cache = {}

    o2inst_list = sort_o2a_inst_by_r(o2inst_list)

    o2o3inst_list = []

    number_list = list(range(len(o2inst_list)))
    min = float('inf')
    answer_partition = []
    for i, p in enumerate(o3_partition(o2inst_list, number_list), 1):
        partition_candidate = sorted(p)

        sum = 0
        for subset in partition_candidate:
            key = tuple(subset)
            if key in o3_objective_function_cache:
                val = o3_objective_function_cache[key]
            else:
                if len(subset) == 1:
                    val = o2inst_list[subset[0]].objective_function()['overall']
                else:
                    temp_o2inst_list = get_list_using_number_list(o2inst_list, subset)
                    o2o3inst = SALUMergeSketchInstance(temp_o2inst_list)
                    val =  o2o3inst.objective_function()['overall']

                o3_objective_function_cache[key] = val
            sum += val

        if min > sum:
            min = sum
            answer_partition = partition_candidate

    for subset in answer_partition:
        if len(subset) == 1:
            o2o3inst_list.append(o2inst_list[subset[0]])
        else:
            new_o2inst_list = get_list_using_number_list(o2inst_list, subset)
            o2o3inst = SALUMergeSketchInstance(new_o2inst_list)
            o2o3inst_list.append(o2o3inst)

    return o2o3inst_list

################ O3 greedy ################

def pull_out_o2o3inst(o2inst_list):
    if len(o2inst_list) == 1:
        return None, o2inst_list
    
    for_o3_o2inst_list = []
    remaining_o2inst_list = []
    
    big_o2inst = o2inst_list[0]

    for_o3_o2inst_list.append(big_o2inst)

    if big_o2inst.get_counter_dp_type() == True:
        for o2inst in o2inst_list[1:]:
            if SALU_merge_check(for_o3_o2inst_list + [o2inst]):
                for_o3_o2inst_list += [o2inst]
            else:
                remaining_o2inst_list.append(o2inst)
    else:
        for o2inst in o2inst_list[1:]:
            if o2inst.get_counter_dp_type() == True:
                if SALU_merge_check(for_o3_o2inst_list + [o2inst]):
                    for_o3_o2inst_list += [o2inst]
                else:
                    remaining_o2inst_list.append(o2inst)
        for o2inst in o2inst_list[1:]:
            if o2inst.get_counter_dp_type() == False:
                if SALU_merge_check(for_o3_o2inst_list + [o2inst]):
                    for_o3_o2inst_list += [o2inst]
                else:
                    remaining_o2inst_list.append(o2inst)

    
    if len(for_o3_o2inst_list) == 1:
        return None, o2inst_list
        
    o2o3inst = SALUMergeSketchInstance(for_o3_o2inst_list)

    return o2o3inst, remaining_o2inst_list

def greedy_o3_greedy(o2inst_list):
    o2inst_list = sort_o2a_inst_by_r(o2inst_list, False)

    o2o3inst_list = []
    new_o2inst_list = []

    count = 0
    while True:
        count += 1
        # print(count)
        if len(o2inst_list) == 0:
            break
        if len(o2inst_list) == 1:
            new_o2inst_list.append(o2inst_list[0])
            break
        o2o3inst, o2inst_list = pull_out_o2o3inst(o2inst_list)
        if o2o3inst == None:
            new_o2inst_list.append(o2inst_list[0])
            o2inst_list = o2inst_list[1:]
        else:
            o2o3inst_list.append(o2o3inst)

    return o2o3inst_list + new_o2inst_list

################ main ################

# input: list of o2inst
# output: list of o2inst or o3inst

def run_O3_bf(clusters, return_dict):
    print_msg(f"        [greedy O3 bruteforce start]", 6, "cyan")

    o2o3inst_list = []
    for cluster in clusters:
        result = greedy_o3_bruteforce(cluster)
        o2o3inst_list += result

    return_dict["o2o3inst_list"] = o2o3inst_list
    print_msg(f"        [greedy O3 bruteforce end]", 6, "cyan")

def run_O3_greedy(clusters):
    print_msg(f"        [greedy O3 greedy start]", 6, "cyan")
    o2o3inst_list = []
    for cluster in clusters:
        result = greedy_o3_greedy(cluster)
        o2o3inst_list += result
    print_msg(f"        [greedy O3 greedy end]", 6, "cyan")
    return o2o3inst_list

def greedy_O2B(o2inst_list, timeout):
    print_msg(f"    [greedy O3 start]", 6, "cyan")

    clusters = get_O2B_cluster(o2inst_list)
    timeout_manager = TimeoutManager(timeout, run_O3_bf, [clusters])
    if timeout > 0 and timeout_manager.start():
        return_dict = timeout_manager.get_return_dict()
        o2o3inst_list = return_dict["o2o3inst_list"]
    else:
        o2o3inst_list = run_O3_greedy(clusters)

    print_msg(f"    [greedy O3 end]", 6, "cyan")
    return o2o3inst_list
