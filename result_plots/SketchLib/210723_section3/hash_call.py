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

def hash_calls():
    plt.figure(figsize=(4, 2.5))

    plt.xlabel('Number of counter rows (R)', fontsize = label_font_size)
    plt.ylabel('Hash Calls', fontsize = label_font_size)

    cs = []
    univmon = []
    rhhh = []
    for R in range(1, 6):
        cs.append(2*R)
        univmon.append(16*(2*R+1))
        rhhh.append(25*2*R)
    print(rhhh)
    print(univmon)
    print(cs)

    plt.plot(['1', '2', '3', '4', '5'], rhhh, marker=rhhh_marker, linestyle=linesty, label='R-HHH', markersize=8)
    plt.plot(['1', '2', '3', '4', '5'], univmon, marker=univmon_marker, linestyle=linesty, label='UnivMon')
    plt.plot(['1', '2', '3', '4', '5'], cs, marker=cs_marker, linestyle=linesty, label='count-sketch')

    plt.xticks(fontsize=tick_font_size)
    plt.yticks(fontsize=tick_font_size)
    # plt.xlim(-0.1, 4)
    # plt.ylim(-10, 250)

    ax = plt.gca()
    # ax.axhline(y=72, color='red', linestyle="--", linewidth=3)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)

    # ax.set_yticks([0, 10, 100, 150, 200, 250])
    # ax.set_yticks([10, 176, 250])
    # plt.setp(ax.get_ymajorticklabels(), visible=False)
    # plt.text(3.7,215, '250', fontsize = text_font_size)
    # plt.text(3.7,130, '176', fontsize = text_font_size)
    # plt.text(3.9,20, '10', fontsize = text_font_size)
    # plt.text(2,4, '250')
    # plt.text(2,4, '250')

    from matplotlib.ticker import MultipleLocator
    ax.yaxis.set_major_locator(MultipleLocator(50))
    # ax.yaxis.set_minor_locator(MultipleLocator(50))

    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # plt.grid(color='gray', linestyle='--', linewidth=1, which='minor')
    # plt.legend(fontsize = 10)
    plt.tight_layout()

    plt.savefig("/Users/hnamkung/Desktop/bot_hashcall.pdf")
    # plt.savefig("/Users/hnamkung/Desktop/bot_hashcall.png")
    plt.show()

hash_calls()