import matplotlib.pyplot as plt
from statistics import median
import numpy as np

label_font_size = 15
tick_font_size = 14
text_font_size = 14

def bf_plot_again():
    plt.figure(figsize=(4, 2.5))
    # plt.figure(figsize=(6, 4))
    # plt.figure(figsize=(8, 5))

    plt.xlabel('Number of heavy flowkeys', fontsize = label_font_size)
    plt.ylabel('Bloomfilter\nSpace (MB)', fontsize = label_font_size)
    plt.yscale("log")

    label = ['1K', '2K', '3K', '4K', '5K']

    three_hash_3 = [16 / 1024, 33 / 1024, 50 / 1024, 67/1024, 84 / 1024]
    three_hash_6 = [169/1024, 339/1024, 509/1024, 679/1024, 848/1024]
    three_hash_9 = [1.66, 3.32, 4.98, 6.64, 8.3]

    plt.plot(label, three_hash_9, marker='.', markersize=10, color='C3', label="Miss rate 10^(-9) %")
    plt.plot(label, three_hash_6, marker='.', markersize=10, color='C4', label="Miss rate 10^(-6) %")
    plt.plot(label, three_hash_3, marker='.', markersize=10, color='C5', label="Miss rate 10^(-3) %")


    ax = plt.gca()
    ax.set_ylim([0, 99])
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)

    plt.xticks(fontsize=tick_font_size)
    plt.yticks(fontsize=tick_font_size)

    plt.grid(color='gray', linestyle='--', linewidth=1)
    # plt.legend(fontsize = 10, ncol=3, prop={'size': 6})
    # plt.legend(ncol=1, prop={'size': 10}, bbox_to_anchor=(1.1, 1.3))
    plt.legend(ncol=1, prop={'size': 10}, bbox_to_anchor=(0.5, 1.0), loc='center')

    plt.tight_layout()
    plt.show()

    plt.savefig("/Users/hnamkung/Desktop/bot_memspace_bf.pdf")
    # plt.show()

bf_plot_again()
