import pandas as pd
import numpy as np
pd.set_option('display.max_rows', 5000)
pd.set_option('display.max_columns', 5000)
pd.set_option('display.width', 10000)
pd.set_option('display.expand_frame_repr', False)

from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_instance import *
from plot.plot_common import *

import os
import sys
import argparse

argparser = argparse.ArgumentParser(description="data generator")
argparser.add_argument('--folder', type=str)
argparser.add_argument('--out', type=str)
argparser.add_argument('--filename', type=str)
args = argparser.parse_args()

print("[load output]")
out_saver = PklSaver(args.out, args.filename)
if out_saver.file_exist():
    output_dict = out_saver.load()
    print("[success]")
else:
    print("No output file, exit")
    exit(1)

candidate_list = [output_dict["bf"], output_dict["o5"]]
name_list = ["bf", "o5"]

core_data_dict = {}
time_data_dict = {}

for candidate, name in zip(candidate_list, name_list):
    core_data = []
    time_data = []

    for key, value in candidate.items():
        print(key, len(value))

        time_list = []
        base_list = []
        opt_list = []
        reduction_list = []

        for (time, data_sample, result) in value:
            time_list.append(time)
            
            if name == "o5":
                baseline_series = compute_heavy_hitter_baseline(data_sample)
                if result != None:
                    opt_series = result.objective_function()
                else:
                    opt_series = pd.Series([0, 0, 0, 0], index=['overall', 'salu', 'hashcall', 'sram'])

            else:
                baseline_series = compute_baseline(data_sample)
                opt_series = compute_objective_function(result)
            
            base_list.append(baseline_series.tolist())
            opt_list.append(opt_series.tolist())
            
            reduction_series = (baseline_series - opt_series)/(baseline_series+0.000001) * 100
            reduction_list.append(reduction_series.tolist())

        data = []
        data.append(base_list)
        data.append(opt_list)
        data.append(reduction_list)

        core_data.append(data)
        time_data.append(time_list)

    np_core_data = np.array(core_data) # (6, 3, 50, 4)
    np_core_data = np.swapaxes(np_core_data, 2, 3) # (6, 3, 4, 50)
    avg_data = np.mean(np_core_data, axis=3) # (6, 3, 4)
    avg_data = avg_data.reshape(avg_data.shape[0], avg_data.shape[1]*avg_data.shape[2]) # (6, 12)
    first_col = ['baseline']*4 + ['opt']*4 + ['reduction']*4
    second_col = ['overall', 'hashcall', 'salu', 'sram'] * 3
    df = pd.DataFrame(avg_data, columns = [first_col, second_col])
    core_data_dict[name] = df

    np_time_data = np.array(time_data) # (6, 50)
    avg_data = np.mean(np_time_data, axis=1) # (6)
    df = pd.DataFrame(avg_data, columns = ["time"])
    time_data_dict[name] = df

bf_base_df = core_data_dict["bf"]["baseline"]["overall"]
o5_base_df = core_data_dict["o5"]["baseline"]["overall"]
total_base = bf_base_df+o5_base_df

bf_opt_df = core_data_dict["bf"]["opt"]["overall"]
o5_opt_df = core_data_dict["o5"]["opt"]["overall"]
total_opt = bf_opt_df+o5_opt_df

bf_result = (total_base - total_opt) / total_base * 100

# color1 = "C" + str(count)
# color2 = "C" + str(count)

fig_size = (7, 5)
fig, ax = plt.subplots(figsize=fig_size)
ax.plot(bf_result, label='bruteforce', color="C1", marker=markerst1, markersize=7, linestyle=linest)
# ax.plot(key_list, greedy_list, label='[W%d] greedy' % (count+1), color=color1, marker=markerst2, markersize=markersize, linestyle=linest)
# count += 1


ax.set_ylabel('Resource Reduction Rate ($\%$)', fontsize=14)
ax.set_xlabel('$\#$ of sketches', fontsize=14)
plt.tick_params(labelsize=14)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
# ax.set_title('%s' % item, fontsize=15)
# ax.set_ylim([0, 60])
from matplotlib.ticker import MultipleLocator
# if item == "overall":
plt.legend(loc="upper left", fontsize=12, ncol=3)
fig.tight_layout()
# plt.savefig("%s.png" % item)
# plt.savefig("overall.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()
plt.clf()
