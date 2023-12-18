import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

import math


def count_sketch_plot(data, title, labels, colors, figsize):
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
    # box = plt.boxplot(box_plot_data, patch_artist=True, labels=labels, widths=0.4, positions=positions, showfliers=True)
    # box = plt.boxplot(box_plot_data, patch_artist=True, labels=labels, widths=0.4, positions=positions, whis=1.5, showfliers=False)

    # ax.legend()
    # plt.legend(box, labels)

    for patch, color in zip(box['boxes'], colors):
        patch.set_facecolor(color)

    for median in box['medians']:
        median.set(color='black', linewidth=2)

    plt.tick_params(labelsize=13)

    # plt.axis('off')

    ax = plt.gca()
#     ax.axvline(x=2.5, color='black', linestyle="-", linewidth=1)
#     ax.axvline(x=5.5, color='black', linestyle="-", linewidth=1)
#     ax.axvline(x=8.5, color='black', linestyle="-", linewidth=1)

#     ax.legend([box["boxes"][0], box["boxes"][1], box["boxes"][2]], ['Width=1024', 'Width=2048', 'Width=4096'], loc='upper right', fontsize=14)

    plt.ylabel("Relative Error ($\%$)", fontsize = 14)
    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(1))
    # plt.legend([box['boxes'][0], box['boxes'][1]], ['original', 'with optimization'], loc=1, bbox_to_anchor=(1,1.5), fontsize=12)
#     plt.xticks([1, 4, 7, 10],
#                ["Row=3",
#                 "Row=4",
#                 "Row=5",
#                 "Row=6"])

    plt.title("HLL cardinality", fontsize=14)

    ax.tick_params(axis=u'both', which=u'both',length=0)

    # plt.legend(prop={'size': 15})
    # plt.xlabel('traces', fontsize = 15)

    plt.grid(color='gray', linestyle='--', linewidth=1)
    ax.xaxis.grid(False)
#     ax.axhline(y=5, color='red', linestyle="--", linewidth=2, zorder=3)
    plt.tight_layout()
#     plt.savefig("/Users/hnamkung/Desktop/univmon-entropy-bottleneck.pdf")

    plt.show()
    plt.close()
