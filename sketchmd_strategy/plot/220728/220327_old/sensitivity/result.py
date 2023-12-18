from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_generator import generate_sketch
from sketch_formats.sketch_instance import *
# from bruteforce import *
# from greedy import *

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
        # print(output_dict.keys())
        # print(output_dict['1'].keys())
        for key, value in output_dict.items():
            data[key] = {}
            for run in ["greedy", "o5", "greedy+o5"]:
                if run not in data[key]:
                    data[key][run] = {}
                data[key][run]["overall"] = []
                data[key][run]["hashcall"] = []
                data[key][run]["SALU"] = []
                data[key][run]["SRAM"] = []
            count = 0
            for ((baseline_g, min_val_g, input_g, result_g), (baseline_o5, min_val_o5, input_o5, result_o5)) in zip(value["greedy"], value["o5"]):
                # print("%.2f %.2f = %.2f%%" % (baseline, min_val, (baseline-min_val)/baseline*100))
                baseline = baseline_g + baseline_o5
                min_val = min_val_g + min_val_o5

                #TODO compute_baseline_individual is removed, fix here
                base_hashcall_g, base_SALU_g, base_SRAM_g = compute_baseline_individual(input_g)
                #TODO compute_heavy_hitter_baseline_individual is removed, fix here
                base_hashcall_o5, base_SALU_o5, base_SRAM_o5 = compute_heavy_hitter_baseline_individual(input_o5)
                
                base_hashcall = base_hashcall_g + base_hashcall_o5
                base_SALU = base_SALU_g + base_SALU_o5
                base_SRAM = base_SRAM_g + base_SRAM_o5

                hashcall_g = 0
                SALU_g = 0
                SRAM_g = 0


                for o2o3o4inst in result_g:
                    ret = o2o3o4inst.objective_function()
                    hashcall_g += ret['hashcall']
                    SALU_g += ret['salu']
                    SRAM_g += ret['sram']
                if result_o5 == None:
                    hashcall_o5 =0
                    SALU_o5 =0
                    SRAM_o5=0
                else:
                    ret = result_o5.objective_function()
                    hashcall_o5 = ret['hashcall']
                    SALU_o5 = ret['salu']
                    SRAM_o5 = ret['sram']

                hashcall = hashcall_g+hashcall_o5
                SALU = SALU_g + SALU_o5
                SRAM = SRAM_g + SRAM_o5
                
                # print(hashcall, SALU, SRAM)
                run = "greedy+o5"
                # print("greedy+o5", (baseline-min_val)/baseline*100)
                data[key][run]["overall"].append((baseline-min_val)/baseline*100)
                data[key][run]["hashcall"].append((base_hashcall-hashcall)/base_hashcall*100)
                data[key][run]["SALU"].append((base_SALU-SALU)/base_SALU*100)
                data[key][run]["SRAM"].append((base_SRAM-SRAM)/base_SRAM*100)
                # data[key][run]["overall"].append(baseline-min_val)
                # data[key][run]["hashcall"].append(base_hashcall-hashcall)
                # data[key][run]["SALU"].append(base_SALU-SALU)
                # data[key][run]["SRAM"].append(base_SRAM-SRAM)

                run = "greedy"
                # print("greedy", (baseline-(baseline_o5+min_val_g))/baseline*100)
                data[key][run]["overall"].append((baseline-baseline_o5-min_val_g)/baseline*100)
                data[key][run]["hashcall"].append((base_hashcall-base_hashcall_o5-hashcall_g)/base_hashcall*100)
                data[key][run]["SALU"].append((base_SALU-base_SALU_o5-SALU_g)/base_SALU*100)
                data[key][run]["SRAM"].append((base_SRAM-base_SRAM_o5-SRAM_g)/base_SRAM*100)

                run = "o5"
                # print("o5", (baseline-(baseline_g + min_val_o5))/baseline*100)
                data[key][run]["overall"].append((baseline-baseline_g-min_val_o5)/baseline*100)
                data[key][run]["hashcall"].append((base_hashcall-base_hashcall_g-hashcall_o5)/base_hashcall*100)
                data[key][run]["SALU"].append((base_SALU-base_SALU_g-SALU_o5)/base_SALU*100)
                data[key][run]["SRAM"].append((base_SRAM-base_SRAM_g-SRAM_o5)/base_SRAM*100)

                count += 1

            print(key, count)
            print("-" * 100)

    import statistics

    result = {}
    for key in data.keys():
        result[key] = {}
        for run in ["greedy", "o5", "greedy+o5"]:
            result[key][run] = {}
            result[key][run]["overall"] = statistics.mean(data[key][run]["overall"])
            result[key][run]["hashcall"] = statistics.mean(data[key][run]["hashcall"])
            result[key][run]["SALU"] = statistics.mean(data[key][run]["SALU"])
            result[key][run]["SRAM"] = statistics.mean(data[key][run]["SRAM"])


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


count = 0

# for filename in ["workload2.pkl"]:
# for item in ["SRAM"]:

# for item in ["overall", "hashcall", "SALU", "SRAM"]:
# for item in ["overall"]:
# for item in ["hashcall"]:
for item in ["SALU"]:
# for item in ["SRAM"]:
    filename = args.filename
    result = get_result(filename)
    key_list = list(result.keys())

    o5_list = []
    greedy_list = []
    greedy_o5_list = []

    for k1, v1 in result.items():
        greedy_list.append(result[k1]["greedy"][item])
        o5_list.append(result[k1]["o5"][item])
        greedy_o5_list.append(result[k1]["greedy+o5"][item])

        # for k2, v2 in .items():
        #     print(k2)
        #     # 
        # for k2, v2 in result[k1]["o5"].items():
        #     pass
        #     # o5_list.append(v2[item])
    # exit(1)
    # exit(1)
    color1 = "C" + str(count)
    color2 = "C" + str(count+1)
    color3 = "C" + str(count+2)


    if args.filename == "workload_varing_flowkey.pkl":
        fig_size = (5, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_flowsize.pkl":
        fig_size = (3, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_epoch.pkl":
        fig_size = (4, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_sketch_parameter.pkl":
        fig_size = (3, 4)
        fig, ax = plt.subplots(figsize=fig_size)



    if args.filename == "workload_varing_counter_update_type.pkl":
        fig_size = (4, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_index_couputing_type.pkl":
        fig_size = (3, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_counter_value_in_dp.pkl":
        fig_size = (3, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_sampling_compatible.pkl":
        fig_size = (3, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    if args.filename == "workload_varing_heavy_flowkey.pkl":
        fig_size = (3, 4)
        fig, ax = plt.subplots(figsize=fig_size)

    ax.plot(key_list, greedy_o5_list, label='total (O1-O5)', color=color3, marker=markerst3, markersize=7, linestyle=linest)
    ax.plot(key_list, greedy_list, label='greedy (O1-O4)', color=color2, marker=markerst1, markersize=7, linestyle=linest)
    ax.plot(key_list, o5_list, label='O5', color=color1, marker=markerst2, markersize=markersize, linestyle=linest)
    count += 1

    if args.filename == "workload_varing_flowkey.pkl":
        ax.set_xlabel('I1. $\#$ of flowkeys', fontsize=14)
        png = "flowkey.png"
        plt.legend(loc="lower right", fontsize=12, ncol=2)

    if args.filename == "workload_varing_flowsize.pkl":
        ax.set_xlabel('I2. $\#$ of flowsize definition', fontsize=14)
        png = "flowsize.png"
        plt.legend(loc="lower right", fontsize=12, ncol=1)

    if args.filename == "workload_varing_epoch.pkl":
        ax.set_xlabel('I3. $\#$ of epochs', fontsize=14)
        png = "epoch.png"
        plt.legend(loc="lower right", fontsize=12, ncol=2)

    if args.filename == "workload_varing_sketch_parameter.pkl":
        ax.set_xlabel('I4. sketch parameters($\#$ of rows)', fontsize=14)
        png = "rows.png"
        plt.legend(loc="lower right", fontsize=12, ncol=2)



    if args.filename == "workload_varing_counter_update_type.pkl":
        ax.set_xlabel('B2. $\#$ of counter update types', fontsize=14)
        png = "counter_update_type.png"
        plt.legend(loc="lower right", fontsize=12, ncol=2)

    if args.filename == "workload_varing_index_couputing_type.pkl":
        ax.set_xlabel('B1. index update type', fontsize=14)
        png = "index_type.png"
        plt.legend(loc="lower right", fontsize=12, ncol=2)

    if args.filename == "workload_varing_counter_value_in_dp.pkl":
        ax.set_xlabel('B3. counter value in dp', fontsize=14)
        png = "counter_value_in_dp.png"
        plt.legend(loc="upper right", fontsize=12, ncol=2)

    if args.filename == "workload_varing_sampling_compatible.pkl":
        ax.set_xlabel('B4. sampling compatible', fontsize=14)
        png = "sampling.png"
        plt.legend(loc="upper right", fontsize=12, ncol=2)

    if args.filename == "workload_varing_heavy_flowkey.pkl":
        ax.set_xlabel('B5. heavy flowkey storage', fontsize=14)
        png = "heavyflowkey.png"
        plt.legend(loc="upper right", fontsize=12, ncol=2)

    # plt.yscale("log")
    ax.set_ylabel('Resource Reduction ($\%$)', fontsize=14)
    plt.tick_params(labelsize=14)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # plt.xticks(x_label)
    # ax.set_title('# of flowkeys', fontsize=15)
    ax.set_ylim([0, 70])
    from matplotlib.ticker import MultipleLocator
    # if item == "overall":
    fig.tight_layout()
    plt.savefig(png)
    # plt.savefig("/Users/hnamkung/Desktop/mrb.png")
    # plt.show()
    plt.clf()
