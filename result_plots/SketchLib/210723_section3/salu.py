import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

label_font_size = 17
tick_font_size = 16
text_font_size = 17

rhhh_marker = 'x'
univmon_marker = 'o'
cs_marker = '^'
linesty = '-'

def SALUs():
    plt.figure(figsize=(4, 2.5))

    plt.xlabel('Number of counter rows (R)', fontsize = label_font_size)
    plt.ylabel('SALUs', fontsize = label_font_size)

    cs = []
    univmon = []
    rhhh = []
    for R in range(1, 6):
        cs.append(R)
        univmon.append(16*R)
        rhhh.append(25*R)
    print(rhhh)
    print(univmon)
    print(cs)

    # univmon = [17, 33, 49, 65, 81]
    # univmon_1 = [17, 33]
    #
    # plt.plot(['1', '2'], univmon_1, marker='o', linestyle=linesty, label='UnivMon', markersize=7, color="C1")
    # plt.plot(['1', '2', '3', '4', '5'], univmon, marker='x', linestyle="--", markersize=6, color="C1")
    #
    # rhhh = [26, 51, 76, 101, 126]
    #
    # rhhh_1 = [26]
    # plt.plot(['1'], rhhh_1, marker='s', linestyle=linesty, label='R-HHH', markersize=7, color="C0")
    # plt.plot(['1', '2', '3', '4', '5'], rhhh, marker='x', linestyle="--", markersize=6, color="C0")
    #
    # cs = [2, 3, 4, 5, 6]

    # plt.plot(['1', '2'], rhhh_1, marker=rhhh_marker, linestyle=linesty, label='R-HHH', markersize=8, color="C0")
    # plt.plot(['2', '3', '4', '5'], rhhh_2, marker=rhhh_marker, linestyle="--", markersize=8)
    #
    # plt.plot(['1', '2', '3'], univmon_1, marker=univmon_marker, linestyle=linesty, label='UnivMon', color="C1")
    # plt.plot(['3', '4', '5'], univmon_2, marker=univmon_marker, linestyle="--", color="C1")

    plt.plot(['1', '2', '3', '4', '5'], rhhh, marker=rhhh_marker, linestyle=linesty, markersize=6, label='RHHH', color="C0")
    plt.plot(['1', '2', '3', '4', '5'], univmon, marker=univmon_marker, linestyle=linesty, markersize=6, label='UnivMon', color="C1")
    plt.plot(['1', '2', '3', '4', '5'], cs, marker=cs_marker, linestyle=linesty, markersize=6, label='count-sketch', color="C2")


    plt.xticks(fontsize=tick_font_size)
    plt.yticks(fontsize=tick_font_size)
    # plt.xlim(-0.1, 4)
    plt.ylim(-10, 260)

    ax = plt.gca()
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)

    # ax.set_yticks([0, 10, 100, 150, 200, 250])
    # ax.set_yticks([10, 176, 250])
    # plt.setp(ax.get_ymajorticklabels(), visible=False)
    # plt.text(3.7,135, '125', fontsize = text_font_size)
    # plt.text(3.8,90, '80', fontsize = text_font_size)
    # plt.text(3.9,15, '5', fontsize = text_font_size)
    # plt.text(2,4, '250')
    # plt.text(2,4, '250')

    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(50))

    # ax.axhline(y=48, color='red', linestyle="--", linewidth=3)

    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    plt.legend(fontsize = 13, loc='upper left')
    plt.tight_layout()

    plt.savefig("/Users/hnamkung/Desktop/bot_salus.pdf")
    # plt.savefig("/Users/hnamkung/Desktop/bot_salus.png")
    plt.show()

SALUs()