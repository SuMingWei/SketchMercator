from python_lib.pkl_saver import PklSaver
from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth
from sw_dp_simulator.file_io.py.read_mrb import load_mrb

import os

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

# def get_cardinality(sketch_array_list, level, width):
#     for base in reversed(range(0, level-1)):
#         if bitset(sketch_array_list[base]) > width/4:
#             break
#         # print()

#     base = base + 1
#     print("selected base:", base)

#     m = 0
#     for i in range(base, level):
#         # level = M[i*width:(i+1)*width]
#         z = bitzero(sketch_array_list[i])
#         import math
#         m = m + width * (math.log(width/z))
#     card = m*2**(base)
#     # print(card)
#     return int(card)


def get_cardinality(M, level, width):
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
        import math
        m = m + width * (math.log(width/z))
    card = m*2**(base)
    return int(card)



def relative_error(true, estimate):
    return abs(true-estimate)/true*100

# def compute_cardinality(gt_result, mrb_result, row, width, level):
#     sketch_array_list = mrb_result["sketch_array_list"]
#     est_cardinality = get_cardinality(sketch_array_list, level, width)

#     # print(sketch_array_list[0][0:width])
#     # print(len(sketch_array_list[0][0:width]))
#     true_cardinality = len(gt_result)
#     re = relative_error(true_cardinality, int(est_cardinality))
#     print(true_cardinality, int(est_cardinality), re)
#     return re

def get_tofino_counter(tofino_full_path):
    f = open(tofino_full_path, "r")
    counter = []
    for a in f:
        b = a.strip()
        counter.append(int(b))
    return counter

def get_diff(counter1, counter2):
    wrong = 0
    correct = 0
    for a, b in zip(counter1, counter2):
        if a == b:
            correct += 1
        else:
            wrong += 1
    # print("wrong: %d", wrong)
    # if wrong != 0:
    #     print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    return wrong / (correct+wrong) * 100

def mrb_sketchaug_main(tofino_path, mrb_path, mrb_output_path, width, row, level):
    print(tofino_path)
    print(mrb_path)
    print(mrb_output_path)

    tofino_dir = []
    for dir in sorted(os.listdir(tofino_path)):
        p = os.path.join(tofino_path, dir)
        if os.path.isdir(p):
            tofino_dir.append(dir)
    tofino_dir = tofino_dir[1:]
    print(len(tofino_dir))

    sim_dir = []
    for dir in sorted(os.listdir(mrb_path)):
        p = os.path.join(mrb_path, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)

    sim_dir = sim_dir[1:]

    print(len(sim_dir))

    saver = PklSaver(mrb_output_path, "data.pkl")
    result_list=[]

    for (a, b) in zip(tofino_dir, sim_dir):
        # print(a, b)
        tofino_full_path = os.path.join(tofino_path, a, "result.txt")
        tofino_counters = get_tofino_counter(tofino_full_path)
        # print(len(tofino_counters))

        sim_full_path = os.path.join(mrb_path, b)
        mrb_result = load_mrb(sim_full_path, width, row, level)
        sketch_array_list = mrb_result["sketch_array_list"]
        # print(len(sketch_array_list))
        counter = []
        for array in sketch_array_list:
            for elem in array:
                counter.append(elem)

        true_cardinality = mrb_result["cardinality"]

        sim_cardinality = get_cardinality(counter, level, width)
        sim_error = relative_error(true_cardinality, sim_cardinality)

        tofino_cardinality = get_cardinality(tofino_counters, level, width)
        tofino_error = relative_error(true_cardinality, tofino_cardinality)

        diff_percent = get_diff(counter, tofino_counters)
        tuple = (true_cardinality, sim_cardinality, sim_error, tofino_cardinality, tofino_error, diff_percent)

        print("true(%d) sim(%d) sim_error(%.2f) tofino(%d) tofino_error(%.2f) count_diff(%.2f)" % tuple)
        # print(true_cardinality, tofino_cardinality, sim_cardinality, diff_percent)

        result_list.append(tuple)

    saver.save(result_list)

def mrb_main(gt_path, mrb_path, mrb_output_path, width, row, level):
    saver = PklSaver(mrb_output_path, "data.pkl")
    result_list=[]
    for (a, b) in zip (sorted(os.listdir(gt_path)), sorted(os.listdir(mrb_path))):
        # print(gt_path, mrb_path)
        # print(a, b)
        specific_gt_path = os.path.join(gt_path, a)
        gt_result = load_ground_truth(specific_gt_path)

        specific_mrb_path = os.path.join(mrb_path, b)
        mrb_result = load_mrb(specific_mrb_path, width, row, level)

        result = compute_cardinality(gt_result, mrb_result, row, width, level)
        result_list.append(result)
        # break

    saver.save(result_list)


def mrb_counter_main(mrb_path, cpp_path, mrb_output_path, width, row, level):
    print()
    print(mrb_path)
    specific_mrb_path = os.path.join(mrb_path, "01")
    mrb_result = load_mrb(specific_mrb_path, width, row, level)
    sketch_array_list = mrb_result["sketch_array_list"]
    print(len(sketch_array_list))
    counter = []
    for array in sketch_array_list:
        for elem in array:
            counter.append(elem)

    # print(len(counter))
    f = open(cpp_path, "r")
    counter2 = []
    for a in f:
        b = a.strip()
        # print(b)
        counter2.append(int(b))

    # print(len(counter2))

    index = 0
    wrong_count = 0
    # for a, b in zip(counter, counter2):
    #     if a != b:
    #         # print(index)
    #         wrong_count += 1
    #     index += 1
    # print(wrong_count)

    for a, b in zip(counter, counter2):
        if a != b:
            str = "wrong"
            # print(index)
            wrong_count += 1
            print("%d %d %d %s" %(index, a, b, str))
        else:
            str = "correct"

        # print("%d %d %d %s" %(index, a, b, str))
        index += 1
    print("wrong count: %d" % wrong_count)

    # print(f.read(5))
    # for readline in f:
    #     print(readline)
    # for a in sorted(os.listdir(mrb_path)):
    #     print(a)

    # print(cpp_path)

    # print(mrb_output_path)
