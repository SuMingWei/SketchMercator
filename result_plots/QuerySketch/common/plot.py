import pickle
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random
import json

from result_plots.QuerySketch.common.common import read_data, get_metric_mapping

# get_data_from_pkl
# combine the flowkeys, datasets, epochs to a list
def get_result_from_pkl(algos = ['cm'], rows = [1, 2, 3, 4, 5], widths = [4096, 8192, 16384, 32768, 65536, 131072], level=1, seeds=[1, 2, 3], 
                           count=1, measure_list = ['hh', 'entropy'], flowkeys = ["dstIP,dstPort",], epochs = ['30'],
                     datasets = ['equinix-nyc.dirA.20180517-130900.UTC.anon.pcap/', 'equinix-nyc.dirA.20180517-131000.UTC.anon.pcap/']):
    
    mapping = get_metric_mapping()
    
    # key: seed, metric, row, width
    total_ret = {}
    for seed in seeds:
        total_ret[seed] = {}
        for m in measure_list:
            total_ret[seed][m] = {}
            for r in rows:
                total_ret[seed][m][r] = {}
                for w in widths:
                    total_ret[seed][m][r][w] = []

    for seed in seeds:
        for r in rows:
            for w in widths:
                for flowkey in flowkeys:
                    for dataset in datasets:
                        tmp = read_data(algos, r, w, level, seed, count, flowkey, epochs, dataset)
                        for algo in algos:
                            for measure in measure_list:
                                # epoch
                                for e in range(len(epochs)):
                                    # raw data
                                    for d in tmp[algo][e]:
                                        # ret[measure][r][w].append(d[mapping[algo][measure]])
                                        total_ret[seed][measure][r][w].append(d[mapping[algo][measure]])
                                    # print(w, flowkey, measure, epochs[e], np.mean(ll))
    # print(total_ret)
    # get mean/median from all seed results
    # key: metric, row, width
    final_ret = {}                                
    for m in measure_list:
        final_ret[m] = {}
        for r in rows:
            final_ret[m][r] = {}
            for w in widths:
                final_ret[m][r][w] = []
    
    for m in measure_list:
        for r in rows:
            for w in widths:
                arr = None
                for seed in seeds:
                    if arr is None:
                        arr = total_ret[seed][m][r][w]
                    else:
                        arr = np.vstack([arr, total_ret[seed][m][r][w]])
                final_ret[m][r][w] = np.mean(arr, axis=0).tolist()
                # print(f'm: {m} r: {r} w: {w}, {final_ret[m][r][w]}')
    # print(len(final_ret[m][r][w]))
    return final_ret

# # key: metric, row, width
# ret = get_result_from_pkl()
# print(ret['hh'][1][4096])


########################
# num_metric: how many ensemble/set/x-ticks
# num_solution: how many box in an ensemble
def get_x_position(num_metric=3, num_solution=4):
    ll = []
    for i in range(num_metric):
        padding = i * num_solution + 1
        val = -0.4
        for j in range(num_solution):
            val += 0.6
            ll.append(padding + val)
    return ll
def get_xtick_position(num_metric=3, num_solution=4):
    isOdd = 0
    if num_solution % 2 == 1:
        isOdd = 0.4
    total = num_metric * num_solution
    ll = []
    for i in range(num_metric):
        padding = i * num_solution
        val = num_solution/2
        ll.append(padding + val + isOdd)
    return ll
# get_x_position()
# get_xtick_position()

#######################

## Plot raw result
def plot_raw(ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us, \
             name, all_metrics = ['hh', 'change_det', 'entropy', 'card', 'fsd'], isSaveFig = False):
    ## comparison version plot
    # box plot 
    # https://www.geeksforgeeks.org/box-plot-in-python-using-matplotlib/
    # Box plots with custom fill colors
    # https://matplotlib.org/stable/gallery/statistics/boxplot_color.html

    import matplotlib.patches as mpatches
    
    metric_to_label = {}
    metric_to_label['hh'] = 'H'
    metric_to_label['entropy'] = 'E'
    metric_to_label['card'] = 'C'
    metric_to_label['fsd'] = 'F'
    metric_to_label['change_det'] = 'D'

    xlabels = []
    for m in all_metrics:
        xlabels.append(metric_to_label[m])
    
    colors = ['deeppink', 'darkred', 'royalblue', 'darkblue', 'darkgreen']
    colors = colors * len(xlabels)

    fig = plt.figure(figsize = (10, 6))
    # Creating axes instance
    ax = fig.add_axes([0, 0, 1, 1])

    plot_list = []
    for m in all_metrics:
        plot_list.append(ret_sol1[m])
        plot_list.append(ret_sol2[m])
        plot_list.append(ret_sol3[m])
        plot_list.append(ret_sol4[m])
        plot_list.append(ret_us[m])

    # Creating plot
    bplot = ax.boxplot(x=plot_list, 
                       positions = get_x_position(len(all_metrics), 5),
                       patch_artist=True)
    # ax.set_xlim(0, 1)
    ax.set_ylim([0, 105])

    for patch, color in zip(bplot['boxes'], colors):
        patch.set_facecolor(color)
        
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    plt.ylabel("Error (%)", fontsize=30)
    plt.xlabel("Available metrics", fontsize=30)
    plt.xticks(get_xtick_position(len(all_metrics), 5), xlabels, fontsize=26)
    plt.yticks(fontsize=26)

    # plt.title(f"Error - {name}", fontsize=18)

    # create legends
    legend_patch = []
    legend_patch.append(mpatches.Patch(color=colors[0], label='Random-Uniform'))
    legend_patch.append(mpatches.Patch(color=colors[1], label='Random-Proportional'))
    legend_patch.append(mpatches.Patch(color=colors[2], label='Lazy-Uniform'))
    legend_patch.append(mpatches.Patch(color=colors[3], label='Lazy-Proportional'))
    legend_patch.append(mpatches.Patch(color=colors[4], label='Bruteforce'))
    plt.legend(handles=legend_patch, fontsize=14) # , loc="upper right"

    # import pickle
    # with open(f'pickles/{name}.pkl', 'wb') as fout:
    #     pickle.dump(fig, fout)
    # plt.savefig(f'figures/individual_metric/{name}.png', format='png', bbox_inches='tight')
    # plt.savefig('test.eps', format='eps', bbox_inches='tight')

    # show plot
    plt.show()
    
###########################

def get_gain(estimate, true):
    # if true.any() == 0:
        # return 0

    # res = np.zeros(len(true))
    # for i in range(len(true)):
    #     res[i] = (estimate[i] - true[i]) / max(true[i], estimate[i])
    #     if res[i] < -0.4:
    #         print(res[i], estimate[i], true[i])
    # return res
    
    # return estimate - true
    return ((estimate - true) / np.maximum(estimate, true)) * 100

def gain_over_strawman(ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us, \
                       name, all_metrics = ['hh', 'change_det', 'entropy', 'card', 'fsd'], isSaveFig = False):
    gain_result = {}

    for m in all_metrics:
        gain_result[m] = []
    for m in all_metrics:
        # gain_result[m].append(np.array(ret_sol1[m]) - np.array(ret_us[m]))
        # gain_result[m].append(np.array(ret_sol2[m]) - np.array(ret_us[m]))
        # gain_result[m].append(np.array(ret_sol3[m]) - np.array(ret_us[m]))
        # gain_result[m].append(np.array(ret_sol4[m]) - np.array(ret_us[m]))
        gain_result[m].append(get_gain(np.array(ret_sol1[m]), np.array(ret_us[m])))
        gain_result[m].append(get_gain(np.array(ret_sol2[m]), np.array(ret_us[m])))
        gain_result[m].append(get_gain(np.array(ret_sol3[m]), np.array(ret_us[m])))
        gain_result[m].append(get_gain(np.array(ret_sol4[m]), np.array(ret_us[m])))
        
    ## comparison version plot
    # box plot 
    # https://www.geeksforgeeks.org/box-plot-in-python-using-matplotlib/
    # Box plots with custom fill colors
    # https://matplotlib.org/stable/gallery/statistics/boxplot_color.html

    import matplotlib.patches as mpatches

#     metric_to_label = {}
#     metric_to_label['hh'] = 'H'
#     metric_to_label['entropy'] = 'E'
#     metric_to_label['card'] = 'C'
#     metric_to_label['fsd'] = 'F'
#     metric_to_label['change_det'] = 'D'

#     xlabels = []
#     for m in all_metrics:
#         xlabels.append(metric_to_label[m])
    xlabels = all_metrics

    colors = ['deeppink', 'darkred', 'royalblue', 'darkblue']
    colors = colors * len(xlabels)
    
    legend_label = ['Over Random-Uniform', 'Over Random-Proportional', 'Over Lazy-Uniform', 'Over Lazy-Proportional', ]

    fig = plt.figure(figsize = (10, 6))
    # Creating axes instance
    ax = fig.add_axes([0, 0, 1, 1])
    
    ax.set_ylim(bottom=-100, top=100)

    plot_list = []
    for m in all_metrics:
        plot_list.append(gain_result[m][0])
        plot_list.append(gain_result[m][1])
        plot_list.append(gain_result[m][2])
        plot_list.append(gain_result[m][3])

    # Creating plot
    bplot = ax.boxplot(x=plot_list, 
                       positions = get_x_position(len(all_metrics), len(gain_result[m])),
                       patch_artist=True)
    # ax.set_xlim(0, 1)

    for patch, color in zip(bplot['boxes'], colors):
        patch.set_facecolor(color)
        
    plt.axhline(y = 0, color = 'r', linestyle = '--')

    plt.ylabel("Gain", fontsize=16)
    plt.xticks(get_xtick_position(len(all_metrics), len(gain_result[m])), xlabels, fontsize=16)
    plt.yticks(fontsize=14)

    plt.title(f"Gain - {name}", fontsize=18)

    # create legends
    # xlabels = ['Best algorithms', "General algorithm"]
    legend_patch = []
    legend_patch.append(mpatches.Patch(color=colors[0], label=legend_label[0]))
    legend_patch.append(mpatches.Patch(color=colors[1], label=legend_label[1]))
    legend_patch.append(mpatches.Patch(color=colors[2], label=legend_label[2]))
    legend_patch.append(mpatches.Patch(color=colors[3], label=legend_label[3]))
    plt.legend(handles=legend_patch, fontsize=16) # , loc="upper right"

    # plt.savefig('test.png', format='png', bbox_inches='tight')
    # plt.savefig('test.eps', format='eps', bbox_inches='tight')

    # show plot
    plt.show()
    
    return gain_result


#############################

## Consolidate all metrics with gain over result
def consolidate_gain_over_strawman(gain_result, name, all_metrics = ['hh', 'change_det', 'entropy', 'card', 'fsd'], isSaveFig = False):
    # merge_gain_result = [[], [], [], []]
    merge_gain_result = np.zeros((4, len(gain_result[all_metrics[0]][0]))) # 4 strawman

    for m in all_metrics:
        # concatenate gains from all metrics
        # merge_gain_result[0] = np.concatenate((merge_gain_result[0], gain_result[m][0]))
        # merge_gain_result[1] = np.concatenate((merge_gain_result[1], gain_result[m][1]))
        # merge_gain_result[2] = np.concatenate((merge_gain_result[2], gain_result[m][2]))
        # merge_gain_result[3] = np.concatenate((merge_gain_result[3], gain_result[m][3]))
        # get mean gain from all metrics (measure it as an ensemble)
        merge_gain_result[0] += np.array(gain_result[m][0]) / len(all_metrics)
        merge_gain_result[1] += np.array(gain_result[m][1]) / len(all_metrics)
        merge_gain_result[2] += np.array(gain_result[m][2]) / len(all_metrics)
        merge_gain_result[3] += np.array(gain_result[m][3]) / len(all_metrics)

    # print(len(merge_gain_result[0]))
    # print(len(gain_result[m][0]))
    # print(merge_gain_result)
    
    
    ## comparison version plot
    # box plot 
    # https://www.geeksforgeeks.org/box-plot-in-python-using-matplotlib/
    # Box plots with custom fill colors
    # https://matplotlib.org/stable/gallery/statistics/boxplot_color.html

    import matplotlib.patches as mpatches

    xlabels = ['set1']
    colors = ['deeppink', 'darkred', 'royalblue', 'darkblue']
    colors = colors * len(xlabels)
    
    legend_label = ['Over Random-Uniform', 'Over Random-Proportional', 'Over Lazy-Uniform', 'Over Lazy-Proportional', ]

    fig = plt.figure(figsize = (10, 6))
    # Creating axes instance
    ax = fig.add_axes([0, 0, 1, 1])
    
    ax.set_ylim([0, 100])

    plot_list = []
    for d in merge_gain_result:
        plot_list.append(d)

    # Creating plot
    bplot = ax.boxplot(x=plot_list, 
                       positions = get_x_position(len(xlabels), len(merge_gain_result)),
                       patch_artist=True)
    # ax.set_xlim(0, 1)

    for patch, color in zip(bplot['boxes'], colors):
        patch.set_facecolor(color)

    # plt.axhline(y = 0, color = 'r', linestyle = '--')
        
    plt.ylabel("Gain", fontsize=16)
    plt.xticks(get_xtick_position(len(xlabels), len(merge_gain_result)), xlabels, fontsize=16)
    plt.yticks(fontsize=14)

    # plt.title("Figure 7 - Gain over with merge metrics", fontsize=18)
    plt.title(f"Merge gain - {name}", fontsize=18)

    # create legends
    # xlabels = ['Best algorithms', "General algorithm"]
    legend_patch = []
    legend_patch.append(mpatches.Patch(color='deeppink', label=legend_label[0]))
    legend_patch.append(mpatches.Patch(color='darkred', label=legend_label[1]))
    legend_patch.append(mpatches.Patch(color='royalblue', label=legend_label[2]))
    legend_patch.append(mpatches.Patch(color='darkblue', label=legend_label[3]))
    plt.legend(handles=legend_patch, fontsize=16) # , loc="upper right"

    # plt.savefig('test.png', format='png', bbox_inches='tight')
    # plt.savefig('test.eps', format='eps', bbox_inches='tight')

    # show plot
    plt.show()
    
    return merge_gain_result