import matplotlib.pyplot as plt

label_font_size = 15
tick_font_size = 14
text_font_size = 15

rhhh_marker = 'x'
univmon_marker = 'o'
cs_marker = '^'
linesty = '-'

def pipeline_stages_levels_r5():
    plt.figure(figsize=(4, 2.5))

    plt.xlabel('Number of levels (L)', fontsize = label_font_size)
    plt.ylabel('Pipeline Stages\n(Normalized)', fontsize = label_font_size)

    cs_base = 3
    univmon = [8/cs_base, 15/cs_base, 23/cs_base, 30/cs_base, 38/cs_base]
    rhhh = [7/cs_base, 14/cs_base, 21/cs_base, 28/cs_base, 34/cs_base]


    plt.plot(['4', '8', '12', '16', '20'], rhhh, marker=rhhh_marker, linestyle=linesty, label='R-HHH', markersize=8)
    plt.plot(['4', '8', '12', '16', '20'], univmon, marker=univmon_marker, linestyle=linesty, label='UnivMon')
    # plt.plot(['1', '2', '3', '4', '5'], cs, marker=cs_marker, linestyle=linesty, label='count-sketch')

    plt.xticks(fontsize=tick_font_size)
    plt.yticks(fontsize=tick_font_size)
    # plt.xlim(-0.1, 4)
    # plt.ylim(0, 8)

    ax = plt.gca()
    # ax.axhline(y=4, color='red', linestyle="--", linewidth=3)
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
    ax.yaxis.set_major_locator(MultipleLocator(3))
    # ax.yaxis.set_minor_locator(MultipleLocator(1))

    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # plt.legend(fontsize = 10, loc='upper left')
    plt.legend(fontsize = 13, loc='upper left')
    plt.tight_layout()

    plt.savefig("/Users/hnamkung/Desktop/bot_pipeline.pdf")
    # plt.savefig("/Users/hnamkung/Desktop/bot_pipeline.png")
    plt.show()

pipeline_stages_levels_r5()