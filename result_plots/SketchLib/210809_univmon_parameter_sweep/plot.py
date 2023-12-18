from env_setting.env_module import result_cp_path
from python_lib.pkl_saver import PklSaver
import os

import matplotlib.pyplot as plt
import math

outptu_path = os.path.join(result_cp_path, "SketchLib", "fcm_eval", "cm")

cm_miss_rate = []
cm_ARE = []

for fn in sorted(os.listdir(outptu_path)):
    pkl_path = os.path.join(outptu_path, fn)
    saver = PklSaver(pkl_path, "data.pkl")
    data = saver.load()
    cm_miss_rate.append(data[0][0])
    cm_miss_rate.append(data[1][0])
    cm_ARE.append(data[0][1])
    cm_ARE.append(data[1][1])

# print(cm_miss_rate)
# print(cm_ARE)


outptu_path = os.path.join(result_cp_path, "SketchLib", "fcm_eval", "fcm")

fcm_miss_rate = []
fcm_ARE = []

fcm_topk_miss_rate = []
fcm_topk_ARE = []

for fn in sorted(os.listdir(outptu_path)):
    pkl_path = os.path.join(outptu_path, fn)
    saver = PklSaver(pkl_path, "data.pkl")
    data = saver.load()

    fcm_miss_rate.append(data[0][0])
    fcm_miss_rate.append(data[1][0])
    fcm_ARE.append(data[0][1])
    fcm_ARE.append(data[1][1])

    fcm_topk_miss_rate.append(data[0][2])
    fcm_topk_miss_rate.append(data[1][2])
    fcm_topk_ARE.append(data[0][3])
    fcm_topk_ARE.append(data[1][3])


def count_sketch_plot(data, ylabel, labels, colors, figsize):
    values = []

    position = 0
    positions = []

    for i, v in enumerate(data):
        # labels.append("%d.txt" % (i+1))
        values.append(v)
        # colors.append('C'+str(int(i)))
        positions.append(position)
        position += 1


    plt.figure(figsize=figsize)

    box_plot_data = values
    box = plt.boxplot(box_plot_data, patch_artist=True, labels=labels, widths=0.4, positions=positions, showfliers=False)

    for patch, color in zip(box['boxes'], colors):
        patch.set_facecolor(color)

    for median in box['medians']:
        median.set(color='black', linewidth=2)

    plt.tick_params(labelsize=12)

    # plt.axis('off')

    ax = plt.gca()
    ax.tick_params(axis=u'both', which=u'both',length=0)
    # ax.axvline(x=1.5, color='black', linestyle="-", linewidth=1)
    # ax.axvline(x=3.5, color='black', linestyle="-", linewidth=1)
    # ax.axvline(x=5.5, color='black', linestyle="-", linewidth=1)
    # ax.axvline(x=7.5, color='black', linestyle="-", linewidth=1)

    # plt.title(title)
    plt.ylabel(ylabel, fontsize = 12)
    # plt.ylim([1.5, 4.5])
    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(2))
    # plt.legend([box['boxes'][0], box['boxes'][1]], ['original', 'with optimization'], loc=1, bbox_to_anchor=(1,1.5), fontsize=12)
    # plt.xticks([0.5, 2.5, 4.5],
    #            ["trace1",
    #             "trace2",
    #             "trace3"])

    # if title == "count-sketch":
    # if title == "univmon-cardinality":
    #     from matplotlib.ticker import MultipleLocator
    #     ax.yaxis.set_major_locator(MultipleLocator(5))
    #     plt.ylabel("RE (%)", fontsize = 12)
    #     plt.xticks([0.5, 2.5, 4.5, 6.5, 8.5],
    #                ["trace1",
    #                 "trace2",
    #                 "trace3",
    #                 "trace4",
    #                 "trace5"])
    # if title == "univmon-entropy":
    #     plt.ylabel("RE (%)", fontsize = 12)
    #     plt.xticks([0.5, 2.5, 4.5, 6.5, 8.5],
    #                ["trace1",
    #                 "trace2",
    #                 "trace3",
    #                 "trace4",
    #                 "trace5"])

    # plt.legend(prop={'size': 15})
    # plt.xlabel('traces', fontsize = 15)

    plt.grid(color='gray', linestyle='--', linewidth=1)
    ax.xaxis.grid(False)
    plt.tight_layout()
    plt.savefig("/Users/hnamkung/Desktop/cs.pdf")
    plt.show()
    plt.close()


# count_sketch_plot([cm_miss_rate, fcm_miss_rate, fcm_topk_miss_rate],
#     "miss rate (%)",
#     ["CM+O6", "FCM+O6", "FCM+topK"],
#     ["C0", "C1", "C2"],
#     (3.5,2))


# count_sketch_plot([cm_ARE, fcm_ARE, fcm_topk_ARE],
#     "ARE (%)",
#     ["CM+O6", "FCM+O6", "FCM+topK"],
#     ["C0", "C1", "C2"],
#     (3.5,2))


def ninety(data):
    data.sort()
    length = int(len(data)*0.9)
    return data[length:length+1]

from statistics import median
print("median case")
print(median(cm_miss_rate))
print(median(fcm_miss_rate))
print(median(fcm_topk_miss_rate))

print(median(cm_ARE))
print(median(fcm_ARE))
print(median(fcm_topk_ARE))

print("90% case")
print(ninety(cm_miss_rate))
print(ninety(fcm_miss_rate))
print(ninety(fcm_topk_miss_rate))

print(ninety(cm_ARE))
print(ninety(fcm_ARE))
print(ninety(fcm_topk_ARE))


# print("miss-rate (%) %f %f %f" % (median(cm_miss_rate), median(cm_miss_rate), median(cm_miss_rate)))
# print("ARE (%) %f %f %f" % (median(cm_ARE), median(fcm_ARE), median(fcm_topk_ARE)))

