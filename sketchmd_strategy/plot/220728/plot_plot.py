import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import os
import sys
import gzip

from plot.plot_common import get_reduction_rate
from plot.plot_common import *

matplotlib.rcParams['hatch.linewidth'] = 0.1
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
width = 0.1

# colors = ['#b2182b', '#ef8a62', '#fddbc7', '#d1e5f0', '#67a9cf', '#2166ac']
# colors = ['C0', 'C1', 'C2', 'C3', 'C4', 'C5']
colors = ['C0', 'C0', 'C1', 'C1', 'C2', 'C2']

patterns = ('//////', '......', 'xxxxxx', '\\\\\\\\\\\\', '++++++')

def overall_bar_plot(key_list, main_data, o5_data):

    fig, ax = plt.subplots(figsize=(10, 5))

    print(key_list)
    length = len(key_list)
    xlabel = range(length)

    o1o4_list = main_data["o5sum"]["avg"]["o1o4_reduction"]["overall"]
    o5_list = main_data["o5sum"]["avg"]["o5_reduction"]["overall"]
    total_list = main_data["o5sum"]["avg"]["reduction"]["overall"]
    min_list = total_list - main_data["o5sum"]["min"]["reduction"]["overall"]
    max_list = main_data["o5sum"]["max"]["reduction"]["overall"] - total_list

    print(o1o4_list + o5_list)
    print(total_list)

    ax.bar(xlabel, o5_list, width, label="O5",
        # error_kw=dict(lw=0.5, capsize=1.,capthick=0.5),# ecolor=colors[0]),
        hatch='/', color="C1", edgecolor='black')

    ax.bar(xlabel, o1o4_list, width, label="O1-O4", error_kw=dict(lw=0.5, capsize=1.,
        capthick=0.5),# ecolor=colors[0]),
        hatch='x',
        lw=0.5, fill=True, color="C2", yerr = [min_list, max_list], edgecolor='#000000', bottom=o5_list)

    ax.yaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter('%d'))
    # fig.canvas.draw()
    ax.set_title('Overall Resource Reduction', fontsize=30)
    ax.set_xticks(np.arange(len(key_list)))
    ax.set_xticklabels(np.arange(len(key_list)), fontsize=20)
    ax.set_xlabel('Workloads', fontsize=20)
    ax.set_yticks(np.arange(0, 110, step=20))
    ax.tick_params(axis='y', labelsize=20)
    ax.set_ylabel('Resource Reduction ($\\%$)', fontsize=20)
    ax.set_ylim([0, 110])
    ax.legend(ncol=2, fontsize=20)
    # ax.legend(ncol=2, frameon=True, loc='best', borderaxespad=0.1,
    # handlelength=0.6, handletextpad=0.2, columnspacing=0.3, fontsize=20,
    # framealpha=0.5)
    ax.minorticks_off()
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    plt.tight_layout()

    plt.savefig("overall.png", format="png", bbox_inches='tight')
    # , pad_inches=0.02)
    # print("saved at b.pdf")
    plt.show()


# def resource_bar_plot(key_list, main_data, o5_data, xaxis_title):

#     result = {}

#     reduction_result = {}

#     length = len(key_list)
#     xlabel = np.arange(length)
#     for individual_resource in ["hashcall", "salu", "sram"]:
#         before_list = main_data["o5sum"]["avg"]["baseline"][individual_resource]
#         after_list = main_data["o5sum"]["avg"]["opt"][individual_resource]
#         result[individual_resource] = {}
#         result[individual_resource]["before"] = before_list
#         result[individual_resource]["after"] = after_list

#         reduction_list = get_reduction_rate(before_list, after_list)
#         reduction_list = np.absolute(reduction_list)
#         reduction_result[individual_resource] = reduction_list
#         # print(reduction_list)
#         # print(min(reduction_list))
#         # print(max(reduction_list))
    
#     fig, ax = plt.subplots(figsize=(10, 5))
#     # print(result[individual_resource]["before"])
#     # print(result[individual_resource]["after"])
#     i = 0

#     for individual_resource, offset in zip(["hashcall", "salu", "sram"], [-3, 0, 3]):
#         print(individual_resource + " before")
#         print(result[individual_resource]["before"])
#         print(individual_resource + " after")
#         print(result[individual_resource]["after"])
#         ax.bar(xlabel+(offset-1)*width, result[individual_resource]["before"], width, label="before " + individual_resource,
#             # error_kw=dict(lw=0.5, capsize=1.,capthick=0.5),# ecolor=colors[0]),
#             hatch='...', color=colors[i], edgecolor='black')

#         ax.bar(xlabel+offset*width, result[individual_resource]["after"], width, label="after " + individual_resource, error_kw=dict(lw=0.5, capsize=1.,
#             capthick=0.5),# ecolor=colors[0]),
#             hatch='+++',
#             lw=0.5, fill=True, color=colors[i+1], edgecolor='#000000')
#         i += 2

#     ax.yaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter('%d'))
#     # fig.canvas.draw()
#     # ax.set_title(individual_resource + ' Usage ($\\%$) before vs after', fontsize=30)
#     ax.set_xticks(np.arange(len(key_list)))
#     ax.set_xticklabels(key_list, fontsize=20)
#     ax.set_xlabel(xaxis_title, fontsize=20)
#     ax.set_yticks(np.arange(0, 350, step=50))
#     ax.tick_params(axis='y', labelsize=20)
#     ax.set_ylabel('Resource  Usage ($\\%$)', fontsize=20)
#     ax.set_ylim([0, 250])
#     ax.legend(ncol=3, fontsize=15)
#     ax.axhline(y=100, color='red', linestyle="--", linewidth=2)
#     # ax.legend(ncol=2, frameon=True, loc='best', borderaxespad=0.1,
#     # handlelength=0.6, handletextpad=0.2, columnspacing=0.3, fontsize=20,
#     # framealpha=0.5)
#     ax.minorticks_off()
#     plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
#     plt.tight_layout()

#     # plt.savefig(individual_resource+".png", format="png", bbox_inches='tight')
#     # , pad_inches=0.02)
#     # print("saved at b.pdf")
#     plt.show()
#     plt.clf()

#     fig, ax = plt.subplots(figsize=(7, 5))
#     resource_list = ["hashcall", "salu", "sram"]
#     resource_name_list = ["hashcall reduction", "salu reduction", "sram overhead"]
#     color_list = ["C0", "C1", "C2"]
#     for i in range(3):
#         ax.plot(key_list, reduction_result[resource_list[i]], label=resource_name_list[i], color=color_list[i], marker=markerst2, markersize=7, linestyle=linest)
#     plt.legend(loc="upper left", fontsize=20, ncol=2)
#     ax.set_ylabel('Resource Reduction Rate ($\%$)', fontsize=20)
#     ax.set_xticklabels(key_list, fontsize=20)
#     ax.set_ylim([0, 110])
#     ax.set_yticks(np.arange(0,110, step=10))
#     ax.tick_params(axis='y', labelsize=20)
#     plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
#     ax.set_xlabel(xaxis_title, fontsize=20)
#     fig.tight_layout()
#     plt.show()
#     plt.clf()
    

def resource_bar_plot_breakdown(ret, xaxis_title):

    result = {}

    reduction_result = {}
    key_list = ret["key_list"]
    print(key_list)
    # key_list = ['No HFS\nstorage', 'mix', 'ALL HF\nstorage']
    length = len(key_list)
    xlabel = np.arange(length)
    for individual_resource in ["hashcall", "salu", "sram"]:
        result[individual_resource] = {}
        result[individual_resource]["before"] = ret["before_list"][individual_resource]
        result[individual_resource]["after"] = ret["after_list"][individual_resource]

        # reduction_list = get_reduction_rate(before_list, after_list)
        # print(reduction_result[individual_resource])

        # print(ret["ratio_list"][individual_resource])
        if individual_resource == "sram":
            reduction_result[individual_resource] = np.multiply(ret["ratio_list"][individual_resource], -1)
        else:
            reduction_result[individual_resource] = ret["ratio_list"][individual_resource]
        # print(reduction_result[individual_resource])

        # reduction_list = np.absolute(reduction_list)
        # print(reduction_list)
        # print(min(reduction_list))
        # print(max(reduction_list))
    
    fig, ax = plt.subplots(figsize=(10, 5))
    # print(result[individual_resource]["before"])
    # print(result[individual_resource]["after"])
    i = 0

    for individual_resource, offset in zip(["hashcall", "salu", "sram"], [-3, 0, 3]):
        # print(individual_resource + " before")
        # print(result[individual_resource]["before"])
        # print(individual_resource + " after")
        # print(result[individual_resource]["after"])
        ax.bar(xlabel+(offset-1)*width, result[individual_resource]["before"], width, label="before " + individual_resource,
            # error_kw=dict(lw=0.5, capsize=1.,capthick=0.5),# ecolor=colors[0]),
            hatch='...', color=colors[i], edgecolor='black')

        ax.bar(xlabel+offset*width, result[individual_resource]["after"], width, label="after " + individual_resource, error_kw=dict(lw=0.5, capsize=1.,
            capthick=0.5),# ecolor=colors[0]),
            hatch='+++',
            lw=0.5, fill=True, color=colors[i+1], edgecolor='#000000')
        i += 2

    ax.yaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter('%d'))
    # fig.canvas.draw()
    # ax.set_title(individual_resource + ' Usage ($\\%$) before vs after', fontsize=30)
    ax.set_xticks(np.arange(len(key_list)))
    ax.set_xticklabels(key_list, fontsize=20)
    ax.set_xlabel(xaxis_title, fontsize=20)
    ax.set_yticks(np.arange(0, 350, step=50))
    ax.tick_params(axis='y', labelsize=20)
    ax.set_ylabel('Resource  Usage ($\\%$)', fontsize=20)
    ax.set_ylim([0, 250])
    ax.legend(ncol=3, fontsize=15)
    ax.axhline(y=100, color='red', linestyle="--", linewidth=2)
    # ax.legend(ncol=2, frameon=True, loc='best', borderaxespad=0.1,
    # handlelength=0.6, handletextpad=0.2, columnspacing=0.3, fontsize=20,
    # framealpha=0.5)
    ax.minorticks_off()
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    plt.tight_layout()

    # plt.savefig(individual_resource+".png", format="png", bbox_inches='tight')
    # , pad_inches=0.02)
    # print("saved at b.pdf")
    plt.savefig("beforeafter.png", format="png", bbox_inches='tight')
    plt.show()
    plt.clf()

    fig, ax = plt.subplots(figsize=(7, 5))
    resource_list = ["hashcall", "salu", "sram"]
    resource_name_list = ["hashcall reduction", "salu reduction", "sram overhead"]
    color_list = ["C0", "C1", "C2"]
    for i in range(3):
        ax.plot(key_list, reduction_result[resource_list[i]], label=resource_name_list[i], color=color_list[i], marker=markerst2, markersize=7, linestyle=linest)
    plt.legend(loc="upper left", fontsize=20, ncol=2)
    ax.set_ylabel('Resource Reduction Rate ($\%$)', fontsize=20)
    ax.set_xticks(key_list)
    ax.set_xticklabels(key_list, fontsize=20)

    # ax.set_ylim([0, 80])
    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(10))

    # ax.set_ylim([0, 130])
    # ax.set_yticks(np.arange(0,130, step=10))

    ax.tick_params(axis='y', labelsize=20)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    ax.set_xlabel(xaxis_title, fontsize=20)
    fig.tight_layout()
    plt.savefig("rate.png", format="png", bbox_inches='tight')
    plt.show()
    plt.clf()

    import pandas as pd
    pd.options.display.float_format = '{:.2f}'.format

    print("="*10 + " Hash Call Reduction " + "="*10)
    print(ret["hashcall_df"])
    print("="*40)
    print()

    fig, ax = plt.subplots(figsize=(5, 5))

    color_list = ["C3", "C4", "C5", "C6", "C7", "C0"]
    marker_set = [markerst1, 'v', markerst3, markerst4, markerst5, markerst2]

    for i, opt in enumerate(["O1", "O2", "O3", "O4", "O5", "total"]):
        ax.plot(key_list, ret["hashcall_df"].loc[opt], label=opt, color=color_list[i], marker=marker_set[i], markersize=7, linestyle=linest)
    plt.legend(loc="upper left", fontsize=13, ncol=3)
    ax.set_ylabel('Hash Call Reduction', fontsize=20)
    ax.set_xticks(key_list)
    ax.set_xticklabels(key_list, fontsize=20)

    # ax.set_ylim([-40, 130])
    # ax.set_yticks(np.arange(-40,130, step=10))

    # ax.set_ylim([-10, 70])
    # ax.set_yticks(np.arange(-20,110, step=20))

    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(20))

    ax.tick_params(axis='y', labelsize=20)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # ax.set_xlabel(xaxis_title, fontsize=20)
    fig.tight_layout()
    plt.savefig("hashcall_detail.png", format="png", bbox_inches='tight')
    plt.show()
    plt.clf()

    print("="*10 + " SALU Reduction " + "="*10)
    print(ret["salu_df"])
    print("="*40)
    print()

    fig, ax = plt.subplots(figsize=(5, 5))

    color_list = ["C3", "C4", "C5", "C6", "C7", "C1"]
    marker_set = [markerst1, 'v', markerst3, markerst4, markerst5, markerst2]

    for i, opt in enumerate(["O1", "O2", "O3", "O4", "O5", "total"]):
        ax.plot(key_list, ret["salu_df"].loc[opt], label=opt, color=color_list[i], marker=marker_set[i], markersize=7, linestyle=linest)
    plt.legend(loc="upper left", fontsize=13, ncol=3)
    ax.set_ylabel('SALU Reduction', fontsize=20)
    ax.set_xticks(key_list)
    ax.set_xticklabels(key_list, fontsize=20)

    # ax.set_ylim([-40, 130])
    # ax.set_yticks(np.arange(-40,130, step=10))

    # ax.set_ylim([-10, 70])
    # ax.set_yticks(np.arange(-20,110, step=20))

    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(20))

    ax.tick_params(axis='y', labelsize=20)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # ax.set_xlabel(xaxis_title, fontsize=20)
    fig.tight_layout()
    plt.savefig("salu_detail.png", format="png", bbox_inches='tight')
    plt.show()
    plt.clf()


    print("="*10 + " SRAM Reduction " + "="*10)
    print(ret["sram_df"])
    print("="*40)
    print()

    fig, ax = plt.subplots(figsize=(5, 5))

    color_list = ["C3", "C4", "C5", "C6", "C7", "C2"]
    marker_set = [markerst1, 'v', markerst3, markerst4, markerst5, markerst2]

    for i, opt in enumerate(["O1", "O2", "O3", "O4", "O5", "total"]):
        ax.plot(key_list, np.multiply(ret["sram_df"].loc[opt], -1), label=opt, color=color_list[i], marker=marker_set[i], markersize=7, linestyle=linest)
    plt.legend(loc="upper left", fontsize=13, ncol=3)
    ax.set_ylabel('SRAM Overhead', fontsize=20)
    ax.set_xticks(key_list)
    ax.set_xticklabels(key_list, fontsize=20)

    # ax.set_ylim([-40, 130])
    # ax.set_yticks(np.arange(-40,130, step=10))

    # ax.set_ylim([-10, 70])
    # ax.set_yticks(np.arange(-20,110, step=20))

    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(20))

    ax.tick_params(axis='y', labelsize=20)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # ax.set_xlabel(xaxis_title, fontsize=20)
    fig.tight_layout()
    plt.savefig("sram_detail.png", format="png", bbox_inches='tight')
    plt.show()
    plt.clf()

def overall_bar_plot_custom(key_list, main_data, o5_data, size, xaxis, fn):
    fig, ax = plt.subplots(figsize=size)

    print(key_list)
    length = len(key_list)
    xlabel = range(length)

    o1o4_list = main_data["o5sum"]["avg"]["o1o4_reduction"]["overall"]
    o5_list = main_data["o5sum"]["avg"]["o5_reduction"]["overall"]
    total_list = main_data["o5sum"]["avg"]["reduction"]["overall"]
    min_list = total_list - main_data["o5sum"]["min"]["reduction"]["overall"]
    max_list = main_data["o5sum"]["max"]["reduction"]["overall"] - total_list

    print(o1o4_list + o5_list)
    print(total_list)

    ax.bar(xlabel, o5_list, width, label="O5",
        # error_kw=dict(lw=0.5, capsize=1.,capthick=0.5),# ecolor=colors[0]),
        hatch='/', color="C1", edgecolor='black')

    ax.bar(xlabel, o1o4_list, width, label="O1-O4", error_kw=dict(lw=0.5, capsize=1.,
        capthick=0.5),# ecolor=colors[0]),
        hatch='x',
        lw=0.5, fill=True, color="C2", yerr = [min_list, max_list], edgecolor='#000000', bottom=o5_list)

    ax.yaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter('%d'))
    # fig.canvas.draw()
    # ax.set_title('Overall Resource Reduction', fontsize=30)
    ax.set_xticks(np.arange(len(key_list)))
    ax.set_xticklabels(np.arange(len(key_list)), fontsize=20)
    # print(key_list)
    ax.set_xticklabels(key_list, fontsize=20)
    # ax.set_xlabel('Workloads', fontsize=20)
    ax.set_xlabel(xaxis, fontsize=20)
    
    # ax.set_yticks(np.arange(0, 110, step=20))
    ax.set_yticks(np.arange(0, 80, step=20))
    ax.tick_params(axis='y', labelsize=20)
    ax.set_ylabel('Resource Reduction ($\\%$)', fontsize=20)
    ax.set_ylim([0, 80])
    ax.legend(ncol=2, fontsize=20)
    # ax.legend(ncol=2, frameon=True, loc='best', borderaxespad=0.1,
    # handlelength=0.6, handletextpad=0.2, columnspacing=0.3, fontsize=20,
    # framealpha=0.5)
    ax.minorticks_off()
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    plt.tight_layout()

    plt.savefig(fn, format="png", bbox_inches='tight')
    # , pad_inches=0.02)
    # print("saved at b.pdf")
    plt.show()