import pandas as pd
import numpy as np
import os
import sys
import argparse
import matplotlib.pyplot as plt
import matplotlib

from python_lib.pkl_saver import PklSaver
from sketch_formats.sketch_instance import *
from lib.inst_list import *
from lib.obj_func import *

linest = "-"
markerst1 = 'x'
markerst2 = 'o'
markerst3 = '^'
markerst4 = '*'
markerst5 = '|'
markerst6 = 'v'
markersize = 5

matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

pd.set_option('display.max_rows', 5000)
pd.set_option('display.max_columns', 5000)
pd.set_option('display.width', 10000)
pd.set_option('display.expand_frame_repr', False)

def data_read(out, filename):
    print(f"[load output] {out} {filename}")
    out_saver = PklSaver(out, filename)
    if out_saver.file_exist():
        output_dict = out_saver.load()
        # for k, v in output_dict.items():
        #     print(k, len(v))
        print("[success]")
    else:
        print("No output file, exit")
        exit(1)
    return output_dict

def get_reduction_rate(baseline, opt):
    return (baseline - opt)/(baseline+0.000001) * 100

def data_parse_breakdown_time(data_dict):
    time_list = []
    for o1o4, o5 in zip(data_dict['o1o4'], data_dict['o5']):
        time_list.append(o1o4[0]+o5[0])
    print(sum(time_list)/len(time_list))
        # print()
    


def data_parse_breakdown(data_dict):

    count = 0
    o1o4_list = []
    for (time, data_sample, result) in data_dict['o1o4']:
        count += 1
        # if count == 11:
        #     break
        if count % 30 == 0:
            print(count)
        # baseline = compute_baseline(data_sample)
        # print(baseline)
        df = empty_df()
        for opt_inst in result:
            df += opt_inst.objective_function_breakdown()
        sanity_check(df)
        o1o4_list.append(df)
        # print(df)
        #             before      after        O1   O2         O3         O4
        # hashcall  86.111111  61.111111  5.555556  0.0   9.722222   9.722222
        # salu      81.250000  58.333333  0.000000  0.0  14.583333   8.333333
        # sram      30.104167  44.895833  0.000000  0.0  -3.958333 -10.833333
        # count += 1
        # if count >= 5:
        #     break

    count = 0
    o5_list = []
    for (time, data_sample, result) in data_dict['o5']:
        count += 1
        # if count == 11:
        #     break
        if count % 30 == 0:
            print(count)
        # print(count)
        before = compute_heavy_hitter_baseline(data_sample)
        if result == None:
            after = empty_series()
        else:
            after = result.objective_function()
        df = create_o3_df(before, after)
        o5_list.append(df)
        # print(df)
        #             before      after        O5 
        # hashcall  86.111111  61.111111  5.555556
        # salu      81.250000  58.333333  0.000000
        # sram      30.104167  44.895833  0.000000
        # count += 1
        # if count >= 5:
        #     break
        # break
    return o1o4_list, o5_list



# def data_parse_breakdown(bf_gd_gd_dict, o5_dict):
#     greedy_df_list_per_key = {}
#     for key, value in bf_gd_gd_dict.items():
#         print(key, len(value)) # key = 1,2,3,4,5,6,7
#         greedy_df_list_per_key[key] = []
#         count = 0
#         for (time, data_sample, result) in value:
#             # baseline = compute_baseline(data_sample)
#             # print(baseline)
#             df = empty_df()
#             for opt_inst in result:
#                 df += opt_inst.objective_function_breakdown()
#             sanity_check(df)
#             greedy_df_list_per_key[key].append(df)
#             # print(df)
#             #             before      after        O1   O2         O3         O4
#             # hashcall  86.111111  61.111111  5.555556  0.0   9.722222   9.722222
#             # salu      81.250000  58.333333  0.000000  0.0  14.583333   8.333333
#             # sram      30.104167  44.895833  0.000000  0.0  -3.958333 -10.833333
#             # count += 1
#             # if count >= 5:
#             #     break


#     o5_df_list_per_key = {}
#     for key, value in o5_dict.items():
#         print(key, len(value)) # key = 1,2,3,4,5,6,7
#         o5_df_list_per_key[key] = []
#         count = 0
#         for (time, data_sample, result) in value:
#             before = compute_heavy_hitter_baseline(data_sample)
#             if result == None:
#                 after = empty_series()
#             else:
#                 after = result.objective_function()
#             df = create_o3_df(before, after)
#             o5_df_list_per_key[key].append(df)
#             # print(df)
#             #             before      after        O5 
#             # hashcall  86.111111  61.111111  5.555556
#             # salu      81.250000  58.333333  0.000000
#             # sram      30.104167  44.895833  0.000000
#             # count += 1
#             # if count >= 5:
#             #     break
#             # break
#     return greedy_df_list_per_key, o5_df_list_per_key


def process_breakdown(greedy_df_list_per_key, o5_df_list_per_key):
    key_list = list(greedy_df_list_per_key.keys())
    if '[0]' in key_list:
        key_list = ['[0]', '[0, 1]', '[1]']
    if '[2]' in key_list:
        key_list = ['[1, 2]', '[1]', '[2]']

    hashcall_data = {}
    salu_data = {}
    sram_data = {}

    before_list = {}
    before_list["hashcall"] = []
    before_list["salu"] = []
    before_list["sram"] = []

    after_list = {}
    after_list["hashcall"] = []
    after_list["salu"] = []
    after_list["sram"] = []

    ratio_list = {}
    ratio_list["hashcall"] = []
    ratio_list["salu"] = []
    ratio_list["sram"] = []

    for key in key_list:
        # print("KEY:", key)
        hashcall_data[key] = [] # O1, O2, O3, O4, O5 should be added
        salu_data[key] = []     # O1, O2, O3, O4, O5 should be added
        sram_data[key] = []     # O1, O2, O3, O4, O5 should be added

        df_list = []
        for greedy_df, o5_df in zip(greedy_df_list_per_key[key], o5_df_list_per_key[key]):
            df = merge_o1o2_o3(greedy_df, o5_df)
            df_list.append(df)
            # print(df)
            #               before      after        O1   O2         O3        O4         O5
            # hashcall  106.944444  73.611111  4.166667  0.0  13.888889  2.777778  12.500000
            # salu      127.083333  79.166667  0.000000  0.0  20.833333  8.333333  18.750000
            # sram       23.020833  31.250000  0.000000  0.0  -1.041667 -7.083333  -0.104167
        df = df_list[0]
        for i in range(1, len(df_list)):
            df += df_list[i]
        df /= len(df_list)


        before_list["hashcall"].append(df["before"]["hashcall"])
        before_list["salu"].append(df["before"]["salu"])
        before_list["sram"].append(df["before"]["sram"])

        after_list["hashcall"].append(df["after"]["hashcall"])
        after_list["salu"].append(df["after"]["salu"])
        after_list["sram"].append(df["after"]["sram"])

        # print(df)
        # print(ratio)
        ratio = get_reduction_rate(df["before"], df["after"])
        ratio_list["hashcall"].append(ratio["hashcall"])
        ratio_list["salu"].append(ratio["salu"])
        ratio_list["sram"].append(ratio["sram"])

        #             before      after        O1   O2         O3         O4         O5
        # hashcall   97.666667  67.555556  2.277778  0.0   8.888889   1.833333  17.111111
        # salu      125.125000  62.833333  0.000000  0.0  13.333333  23.291667  25.666667
        # sram       15.866667  26.916667  0.000000  0.0  -0.966667  -9.654167  -0.429167
        # print((df["before"]-df["after"])/df["before"]*100)

        for opt in ["O1", "O2", "O3", "O4", "O5"]:
            series = df[opt]/df["before"]*100
            hashcall_data[key].append(series['hashcall'])
            salu_data[key].append(series['salu'])
            sram_data[key].append(series['sram'])
        # print()
        # print()
        # break


    hashcall_df = pd.DataFrame(hashcall_data, index=["O1", "O2", "O3", "O4", "O5"])
    hashcall_df.loc["total"] = hashcall_df.sum(axis=0)

    salu_df = pd.DataFrame(salu_data, index=["O1", "O2", "O3", "O4", "O5"])
    salu_df.loc["total"] = salu_df.sum(axis=0)

    sram_df = pd.DataFrame(sram_data, index=["O1", "O2", "O3", "O4", "O5"])
    sram_df.loc["total"] = sram_df.sum(axis=0)

    ret = {}
    ret["hashcall_df"] = hashcall_df
    ret["salu_df"] = salu_df
    ret["sram_df"] = sram_df
    ret["before_list"] = before_list
    ret["after_list"] = after_list
    ret["ratio_list"] = ratio_list
    ret["key_list"] = key_list

    return ret









        #     for opt in ["O1", "O2", "O3", "O4", "O5"]:
        #         series = df[opt] / df["before"] * 100
        #         # print(series)
        #         # hashcall    3.658537
        #         # salu        0.000000
        #         # sram        0.000000
        #         # dtype: float64
        #         if opt not in df_dict.keys():
        #             df_dict[opt] = series
        #         else:
        #             df_dict[opt] = pd.concat([df_dict[opt], series], axis=1)
        #     # print("="*100)
        #     # print()
        #     # break
        # # print(df_dict["O1"])
        # # print(df_dict["O2"])
        # #                 0         1         0         0    0
        # # hashcall  3.896104  3.658537  1.298701  3.448276  0.0
        # # salu      0.000000  0.000000  0.000000  0.000000  0.0
        # # sram      0.000000  0.000000  0.000000  0.000000  0.0
        # for opt in ["O1", "O2", "O3", "O4", "O5"]:
        #     hashcall_data[key].append(df_dict[opt].loc["hashcall"].mean())
        #     salu_data[key].append(df_dict[opt].loc["salu"].mean())
        #     sram_data[key].append(df_dict[opt].loc["sram"].mean())










# -> these are impossible to debug, although it can do something, this code is not sustailable, I will comment this out for now
# def create_columns(data):
#     first_col = ['baseline']*4 + ['opt']*4 + ['reduction']*4
#     second_col = ['overall', 'hashcall', 'salu', 'sram'] * 3
#     df = pd.DataFrame(data, columns = [first_col, second_col])
#     return df

# def create_df(data): # data should be (6, 3, 4, 50)
#     avg_data = np.mean(data, axis=3) # (6, 3, 4)
#     avg_data = avg_data.reshape(avg_data.shape[0], avg_data.shape[1]*avg_data.shape[2]) # (6, 12)
#     avg_df = create_columns(avg_data)

#     min_data = np.min(data, axis=3) # (6, 3, 4)
#     min_data = min_data.reshape(min_data.shape[0], min_data.shape[1]*min_data.shape[2]) # (6, 12)
#     min_df = create_columns(min_data)

#     max_data = np.max(data, axis=3) # (6, 3, 4)
#     max_data = max_data.reshape(max_data.shape[0], max_data.shape[1]*max_data.shape[2]) # (6, 12)
#     max_df = create_columns(max_data)

#     ret = {}
#     ret["avg"] = avg_df
#     ret["min"] = min_df
#     ret["max"] = max_df
#     return ret

# def create_fraction_columns(data):
#     first_col = ['baseline']*4 + ['opt']*4 + ['reduction']*4 + ['o1o4_reduction']*4 + ['o5_reduction']*4
#     second_col = ['overall', 'hashcall', 'salu', 'sram'] * 5
#     df = pd.DataFrame(data, columns = [first_col, second_col])
#     return df

# def create_fraction_df(data): # data should be (6, 5, 4, 50)
#     avg_data = np.mean(data, axis=3) # (6, 5, 4)
#     avg_data = avg_data.reshape(avg_data.shape[0], avg_data.shape[1]*avg_data.shape[2]) # (6, 20)
#     avg_df = create_fraction_columns(avg_data)

#     min_data = np.min(data, axis=3) # (6, 5, 4)
#     min_data = min_data.reshape(min_data.shape[0], min_data.shape[1]*min_data.shape[2]) # (6, 20)
#     min_df = create_fraction_columns(min_data)

#     max_data = np.max(data, axis=3) # (6, 5, 4)
#     max_data = max_data.reshape(max_data.shape[0], max_data.shape[1]*max_data.shape[2]) # (6, 20)
#     max_df = create_fraction_columns(max_data)

#     ret = {}
#     ret["avg"] = avg_df
#     ret["min"] = min_df
#     ret["max"] = max_df
#     return ret

# def create_time_df(data): # data should be (6, 50)
#     avg_data = np.mean(data, axis=1) # (6)
#     avg_df = pd.DataFrame(avg_data, columns = ["time"])

#     min_data = np.min(data, axis=1) # (6)
#     min_df = pd.DataFrame(min_data, columns = ["time"])

#     max_data = np.max(data, axis=1) # (6)
#     max_df = pd.DataFrame(max_data, columns = ["time"])

#     ret = {}
#     ret["avg"] = avg_df
#     ret["min"] = min_df
#     ret["max"] = max_df
#     return ret

# def data_parse_search(candidate_list, name_list, workload):
#     from lib.obj_func import compute_objective_function

#     length = len(candidate_list[0][workload])

#     perf_list = []

#     for count in range(length):
#         time_0, data_sample, result_0 = candidate_list[0][workload][count]
#         time_1, data_sample, result_1 = candidate_list[1][workload][count]

#         # print_inst_list(data_sample)
#         # print_answer_list(result_0)

#         baseline_series_0 = compute_baseline(data_sample)
#         opt_series_0 = compute_objective_function(result_0)

#         baseline_series_1 = compute_heavy_hitter_baseline(data_sample)
#         if result_1 != None:
#             opt_series_1 = result_1.objective_function()
#         else:
#             opt_series_1 = pd.Series([0, 0, 0, 0], index=['overall', 'salu', 'hashcall', 'sram'])

#         # print(baseline_series_0)
#         # print(opt_series_0)
#         # print(baseline_series_1)
#         # print(opt_series_1)
#         reduction = get_reduction_rate(baseline_series_0 + baseline_series_1, opt_series_0 + opt_series_1)
#         # print(reduction)
#         # print(reduction["overall"])
#         perf_list.append(reduction["overall"])
#     np_perf_array = np.array(perf_list)
#     # print(np_perf_array)
#     print("avg performance:", np.mean(np_perf_array))
#     print("median performance:", np.median(np_perf_array))
#     medIdx = perf_list.index(np.percentile(perf_list,50,interpolation='nearest'))
#     print(medIdx)
#     print(perf_list[medIdx])

#     time_0, data_sample, result_0 = candidate_list[0][workload][medIdx]
#     time_1, data_sample, result_1 = candidate_list[1][workload][medIdx]


#     baseline_series_0 = compute_baseline(data_sample)
#     opt_series_0 = compute_objective_function(result_0)

#     baseline_series_1 = compute_heavy_hitter_baseline(data_sample)
#     if result_1 != None:
#         opt_series_1 = result_1.objective_function()
#     else:
#         opt_series_1 = pd.Series([0, 0, 0, 0], index=['overall', 'salu', 'hashcall', 'sram'])

#     print(baseline_series_0)
#     print(opt_series_0)
#     print(baseline_series_1)
#     print(opt_series_1)
#     reduction = get_reduction_rate(baseline_series_0 + baseline_series_1, opt_series_0 + opt_series_1)
#     print(reduction)
#     print_inst_list(data_sample)
#     print_answer_list(result_0)


# def data_parse_min_max(candidate_list, name_list):
#     from lib.obj_func import compute_objective_function

#     core_data_dict = {}
#     time_data_dict = {}
#     key_list_dict = {}
#     for candidate, name in zip(candidate_list, name_list):
#         core_data = []
#         time_data = []
#         key_list_dict[name] = list(candidate.keys())
#         for key, value in candidate.items():
#             print(key, len(value))

#             time_list = []
#             base_list = []
#             opt_list = []
#             reduction_list = []

#             for (time, data_sample, result) in value:
#                 time_list.append(time)
                
#                 if name == "o5":
#                     baseline_series = compute_heavy_hitter_baseline(data_sample)
#                     if result != None:
#                         opt_series = result.objective_function()
#                     else:
#                         opt_series = pd.Series([0, 0, 0, 0], index=['overall', 'salu', 'hashcall', 'sram'])

#                 else:
#                     baseline_series = compute_baseline(data_sample)
#                     opt_series = compute_objective_function(result)
                
#                 base_list.append(baseline_series.tolist())
#                 opt_list.append(opt_series.tolist())

#                 reduction_series = get_reduction_rate(baseline_series, opt_series)
#                 reduction_list.append(reduction_series.tolist())

#             data = []
#             data.append(base_list)
#             data.append(opt_list)
#             data.append(reduction_list)

#             core_data.append(data)
#             time_data.append(time_list)
#             break
        
#         print(name)
#         np_core_data = np.array(core_data) # (6, 3, 50, 4)
#         np_core_data = np.swapaxes(np_core_data, 2, 3) # (6, 3, 4, 50)
#         core_data_dict[name] = np_core_data

#         print(np_core_data.shape)
#         np_time_data = np.array(time_data) # (6, 50)
#         time_data_dict[name] = np_time_data
#         print(np_time_data.shape)

#     ret_core_data_dict = {}
#     ret_time_data_dict = {}

#     for name in ["o5"] + name_list:
#         ret_core_data_dict[name] = {}
#         ret_time_data_dict[name] = {}

#         ret_core_data_dict[name]["alone"] = {}
#         ret_time_data_dict[name]["alone"] = {}

#         ret = create_df(core_data_dict[name])
#         ret_core_data_dict[name]["alone"]["avg"] = ret["avg"]
#         ret_core_data_dict[name]["alone"]["min"] = ret["min"]
#         ret_core_data_dict[name]["alone"]["max"] = ret["max"]

#         ret = create_time_df(time_data_dict[name])
#         ret_time_data_dict[name]["alone"]["avg"] = ret["avg"]
#         ret_time_data_dict[name]["alone"]["min"] = ret["min"]
#         ret_time_data_dict[name]["alone"]["max"] = ret["max"]

#         if name != "o5":
#             ret_core_data_dict[name]["o5sum"] = {}
#             ret_time_data_dict[name]["o5sum"] = {}

#             # there is "baseline", "opt", "reduction", you should be careful about "reduction".
#             # basically, I need to recalculate reduction again. - (6, 3, 4, 50) + (6, 3, 4, 50)
#             prev_data_1 = core_data_dict[name]
#             prev_data_2 = core_data_dict["o5"]

#             prev_data_1 = np.swapaxes(prev_data_1, 0, 1) # (3, 6, 4, 50)
#             prev_data_2 = np.swapaxes(prev_data_2, 0, 1) # (3, 6, 4, 50)
#             new_data = prev_data_1 + prev_data_2 # (3, 6, 4, 50)
            
#             new_data[2] = get_reduction_rate(new_data[0], new_data[1])
#             print(new_data.shape)

#             o1o4_data = get_reduction_rate(new_data[0], prev_data_1[1]+prev_data_2[0]) # O1-O4 
#             o5_data = get_reduction_rate(new_data[0], prev_data_2[1]+prev_data_1[0]) # O5

#             o1o4_data = np.expand_dims(o1o4_data, axis=0) # (1, 6, 4, 50)
#             o5_data = np.expand_dims(o5_data, axis=0)     # (1, 6, 4, 50)
#             concat_data = np.concatenate([o1o4_data, o5_data], axis=0) # (2, 6, 4, 50)
#             new_data = np.concatenate([new_data, concat_data], axis=0) # (5, 6, 4, 50)
#             new_data = np.swapaxes(new_data, 0, 1) # (6, 5, 4, 50)

#             ret = create_fraction_df(new_data)
#             ret_core_data_dict[name]["o5sum"]["avg"] = ret["avg"]
#             ret_core_data_dict[name]["o5sum"]["min"] = ret["min"]
#             ret_core_data_dict[name]["o5sum"]["max"] = ret["max"]

#             new_data = time_data_dict[name] + time_data_dict["o5"]

#             ret = create_time_df(new_data)
#             ret_time_data_dict[name]["o5sum"]["avg"] = ret["avg"]
#             ret_time_data_dict[name]["o5sum"]["min"] = ret["min"]
#             ret_time_data_dict[name]["o5sum"]["max"] = ret["max"]

#     ret = {}
#     ret["core_data_dict"] = ret_core_data_dict
#     ret["time_data_dict"] = ret_time_data_dict
#     ret["key_list_dict"] = key_list_dict
#     return ret
