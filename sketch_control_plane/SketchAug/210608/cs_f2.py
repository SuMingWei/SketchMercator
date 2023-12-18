from python_lib.pkl_saver import PklSaver
# from sw_dp_simulator.file_io.py.read_ground_truth import load_ground_truth
from sw_dp_simulator.file_io.py.read_cs import load_cs

import os

def get_f2(counter, width, row):
    a = []
    for r in range(0, row):
        sum = 0
        for w in range(0, width):
            sum += counter[width*r + w] * counter[width*r + w]
        a.append(sum)
    # print(a)
    # print(a.sort())
    return int((a[1] + a[2]) / 2)

def relative_error(true, estimate):
    return abs(true-estimate)/true*100

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
    diff_sum = 0
    for a, b in zip(counter1, counter2):
        if a == b:
            correct += 1
        else:
            wrong += 1

        diff_sum += abs(a - b)

    # print("wrong: %d" % wrong)
    # print("diff_sum: %d" % diff_sum)
    # if wrong != 0:
    #     print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    return wrong / (correct+wrong) * 100, wrong, diff_sum

def get_counter_diff(tofino_counters, previous_counter, width, row):
    diff_counter = []
    for i in range(0, width*row):
        diff_counter.append(tofino_counters[i] - previous_counter[i])
    return diff_counter

def cs_f2_sketchaug_main(tofino_path, input_path, output_path, width, row, level, isDiff):
    print(tofino_path)
    print(input_path)
    print(output_path)

    tofino_dir = []
    for dir in sorted(os.listdir(tofino_path)):
        p = os.path.join(tofino_path, dir)
        if os.path.isdir(p):
            tofino_dir.append(dir)

    tofino_full_path = os.path.join(tofino_path, tofino_dir[0], "result.txt")
    previous_counter = get_tofino_counter(tofino_full_path)

    tofino_dir = tofino_dir[1:]
    print(len(tofino_dir))

    sim_dir = []
    for dir in sorted(os.listdir(input_path)):
        p = os.path.join(input_path, dir)
        if os.path.isdir(p):
            sim_dir.append(dir)

    sim_full_path = os.path.join(input_path, sim_dir[0])
    
    sim_dir = sim_dir[1:]
    print(len(sim_dir))

    saver = PklSaver(output_path, "data.pkl")
    result_list=[]

    count = 0

    for i in range(0, width*row):
        previous_counter.append(0)

    for (a, b) in zip(tofino_dir, sim_dir):
        # print(a, b)
        tofino_full_path = os.path.join(tofino_path, a, "result.txt")
        tofino_counters = get_tofino_counter(tofino_full_path)
        # print(len(tofino_counters))

        sim_full_path = os.path.join(input_path, b)
        cs_result = load_cs(sim_full_path, width, row)
        sketch_array_list = cs_result["sketch_array_list"]
        # print(len(sketch_array_list[0]))
        counter = []
        for array in sketch_array_list:
            for elem in array:
                counter.append(elem)
        # print(len(counter))

        true_f2 = cs_result["f2"]
        sim_f2 = get_f2(counter, width, row)
        sim_error = relative_error(true_f2, sim_f2)
        if isDiff:
            diff_counter = get_counter_diff(tofino_counters, previous_counter, width, row)
        else:
            diff_counter = tofino_counters

        tofino_f2 = get_f2(diff_counter, width, row)
        tofino_error = relative_error(true_f2, tofino_f2)

        # print(true_f2, sim_f2, tofino_f2)


        diff_percent, wrong_count, diff_sum = get_diff(counter, diff_counter)
        # count += 1
        # if count == 10:
        #     break

        previous_counter = tofino_counters

        tuple = (true_f2, sim_f2, sim_error, tofino_f2, tofino_error, diff_percent, wrong_count, diff_sum)
        print("true(%d) sim(%d) sim_error(%.2f) tofino(%d) tofino_error(%.2f) count_diff(%.2f) wrong_count(%d) diff_sum(%d)" % tuple)
#         # print(true_cardinality, tofino_cardinality, sim_cardinality, diff_percent)

        result_list.append(tuple)

    saver.save(result_list)



# def mrb_counter_main(mrb_path, cpp_path, mrb_output_path, width, row, level):
#     print()
#     print(mrb_path)
#     specific_mrb_path = os.path.join(mrb_path, "01")
#     mrb_result = load_mrb(specific_mrb_path, width, row, level)
#     sketch_array_list = mrb_result["sketch_array_list"]
#     print(len(sketch_array_list))
#     counter = []
#     for array in sketch_array_list:
#         for elem in array:
#             counter.append(elem)

#     # print(len(counter))
#     f = open(cpp_path, "r")
#     counter2 = []
#     for a in f:
#         b = a.strip()
#         # print(b)
#         counter2.append(int(b))

#     # print(len(counter2))

#     index = 0
#     wrong_count = 0
#     # for a, b in zip(counter, counter2):
#     #     if a != b:
#     #         # print(index)
#     #         wrong_count += 1
#     #     index += 1
#     # print(wrong_count)

#     for a, b in zip(counter, counter2):
#         if a != b:
#             str = "wrong"
#             # print(index)
#             wrong_count += 1
#             print("%d %d %d %s" %(index, a, b, str))
#         else:
#             str = "correct"

#         # print("%d %d %d %s" %(index, a, b, str))
#         index += 1
#     print("wrong count: %d" % wrong_count)

#     # print(f.read(5))
#     # for readline in f:
#     #     print(readline)
#     # for a in sorted(os.listdir(mrb_path)):
#     #     print(a)

#     # print(cpp_path)

#     # print(mrb_output_path)
