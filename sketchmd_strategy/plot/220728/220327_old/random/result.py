from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_generator import generate_sketch
from sketch_formats.sketch_instance import *
from bruteforce import *
from greedy import *

import os
import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--out', type=str)
argparser.add_argument('--filename', type=str)
args = argparser.parse_args()


def get_result(filename):
    data = {}

    print("[load output]")
    out_saver = PklSaver(args.out, filename)
    if out_saver.file_exist():
        output_dict = out_saver.load()
        print("[success]")
        for run in ["greedy", "bruteforce"]:
            print(run)
            data[run] = {}

            data2 = data[run]
            for key, value in output_dict[run].items():
                if run == "greedy":
                    if key > 30:
                        break
                else:
                    if key > 12:
                        break

                # if key != 6:
                #     continue

                # print(key)
                data2[key] = {}
                data2[key]["overall"] = []
                data2[key]["hashcall"] = []
                data2[key]["SALU"] = []
                data2[key]["SRAM"] = []

                count = 0
                for (baseline, min_val, input, result) in value:
                    # print("%.2f %.2f = %.2f%%" % (baseline, min_val, (baseline-min_val)/baseline*100))
                    #TODO compute_baseline_individual is removed, fix here
                    base_hashcall, base_SALU, base_SRAM = compute_baseline_individual(input)

                    hashcall = 0
                    SALU = 0
                    SRAM = 0
                    for o2o3o4inst in result:
                        ret = o2o3o4inst.objective_function()
                        hashcall += ret['hashcall']
                        SALU += ret['salu']
                        SRAM += ret['sram']
                    # print(hashcall, SALU, SRAM)
                    data2[key]["overall"].append((baseline-min_val)/baseline*100)
                    data2[key]["hashcall"].append((base_hashcall-hashcall)/base_hashcall*100)
                    data2[key]["SALU"].append((base_SALU-SALU)/base_SALU*100)
                    data2[key]["SRAM"].append((base_SRAM-SRAM)/base_SRAM*100)
                    count += 1
                    if count >= 30:
                        break
                print(key, count)
            print("-" * 100)
    else:
        print("No output file, create one")

    import statistics

    result = {}
    for run in ["greedy", "bruteforce"]:
        result[run] = {}
        # print(data[run])
        for key in data[run].keys():
            result[run][key] = {}
            result[run][key]["overall"] = statistics.mean(data[run][key]["overall"])
            result[run][key]["hashcall"] = statistics.mean(data[run][key]["hashcall"])
            result[run][key]["SALU"] = statistics.mean(data[run][key]["SALU"])
            result[run][key]["SRAM"] = statistics.mean(data[run][key]["SRAM"])

    return result

# exit(1)
linest = "-"
markerst1 = 'x'
markerst2 = 'o'
markerst3 = '^'
markerst4 = '*'
markerst5 = '|'

markersize = 5

import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

# print(key_list)
# print(greedy_list)


fig_size = (7, 5)

fig, ax = plt.subplots(figsize=fig_size)

count = 0

# for filename in ["workload2.pkl"]:
# for item in ["SRAM"]:

# for item in ["overall", "hashcall", "SALU", "SRAM"]:
# for item in ["overall"]:
for item in ["hashcall"]:
# for item in ["SALU"]:
# for item in ["SRAM"]:
    for filename in ["workload1.pkl", "workload2.pkl", "workload3.pkl", "workload4.pkl", "workload5.pkl"]:
    # for filename in ["workload1.pkl"]:
        result = get_result(filename)
        key_list = list(result["greedy"].keys())
        bf_key_list = list(result["bruteforce"].keys())

        greedy_list = []
        for k, v in result["greedy"].items():
            greedy_list.append(v[item])

        bf_list = []
        for k, v in result["bruteforce"].items():
            bf_list.append(v[item])

        print(key_list)
        print(greedy_list)

        print(bf_key_list)
        print(bf_list)
        # exit(1)
        color1 = "C" + str(count)
        color2 = "C" + str(count)

        ax.plot(key_list, greedy_list, label='[W%d] greedy' % (count+1), color=color1, marker=markerst2, markersize=markersize, linestyle=linest)
        ax.plot(bf_key_list, bf_list, label='[W%d] bruteforce' % (count+1), color=color2, marker=markerst1, markersize=7, linestyle=linest)
        count += 1


    # plt.yscale("log")
    ax.set_ylabel('Resource Reduction Rate ($\%$)', fontsize=14)
    ax.set_xlabel('$\#$ of sketches', fontsize=14)
    plt.tick_params(labelsize=14)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # plt.xticks(x_label)
    ax.set_title('%s' % item, fontsize=15)
    # ax.set_ylim([0, 60])
    from matplotlib.ticker import MultipleLocator
    if item == "overall":
        plt.legend(loc="upper left", fontsize=12, ncol=3)
    fig.tight_layout()
    plt.savefig("%s.png" % item)
    # plt.savefig("overall.pdf")
    # plt.savefig("/Users/hnamkung/Desktop/mrb.png")
    plt.show()
    plt.clf()
