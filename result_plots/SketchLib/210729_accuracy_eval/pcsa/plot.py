import matplotlib.pyplot as plt
import math
import matplotlib
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42


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

    for patch, color in zip(box['boxes'], colors):
        patch.set_facecolor(color)

    for median in box['medians']:
        median.set(color='black', linewidth=2)

    plt.tick_params(labelsize=14)

    # plt.axis('off')

    ax = plt.gca()
    ax.tick_params(axis=u'both', which=u'both',length=0)
    ax.axvline(x=1.5, color='black', linestyle="-", linewidth=1)
    ax.axvline(x=3.5, color='black', linestyle="-", linewidth=1)
    ax.axvline(x=5.5, color='black', linestyle="-", linewidth=1)
    ax.axvline(x=7.5, color='black', linestyle="-", linewidth=1)

    plt.title("PCSA", fontsize = 14)
    plt.ylabel("RE ($\%$)", fontsize = 14)
    # plt.ylim([1.5, 4.5])
    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(10))
    # plt.legend([box['boxes'][0], box['boxes'][1]], ['original', 'with optimization'], loc=1, bbox_to_anchor=(1,1.5), fontsize=12)
    plt.xticks([0.5, 2.5, 4.5, 6.5, 8.5],
               ["trace1",
                "trace2",
                "trace3",
                "trace4",
                "trace5"])

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
    plt.savefig("/Users/hnamkung/Desktop/pcsa.pdf")
    plt.show()
    plt.close()
