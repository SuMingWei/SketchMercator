
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import os
import sys
import gzip

# raw_data_filename = sys.argv[1]
# fig_filename = sys.argv[2]

raw_data_filename = "input.txt"

matplotlib.rcParams['hatch.linewidth'] = 0.1
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

colors = ['#b2182b', '#ef8a62', '#fddbc7', '#d1e5f0', '#67a9cf', '#2166ac']
patterns = ('//////', '......', 'xxxxxx', '\\\\\\\\\\\\', '++++++')
line_style = ('-','--','-.',':')
marker_style = ('x','o','d','^')
percentile = [10, 50, 90, 99]
pkt_sizes = [64, 128, 256, 512, 1024, 1280, 1518]

width = 0.3
fig, ax = plt.subplots(figsize=(2.*1.35,1.2*1.35))
ax.minorticks_off()

def plot_tput (filename):
    res_file = open(filename, 'r')
    tx_rates = {}
    rx_rates = {}
    median = {"tx": [], "rx": []} 
    err_hi = {"tx": [], "rx": []} 
    err_lo = {"tx": [], "rx": []} 

    for line in res_file:
        line = line.rstrip('\r\n')
        tmp = line.split('\t')
        pkt_size = int(tmp[0])
        tx_rate = float(tmp[1])
        rx_rate = float(tmp[2])
        if pkt_size not in tx_rates:
            tx_rates[pkt_size] = []
            rx_rates[pkt_size] = []

        tx_rates[pkt_size].append(tx_rate)
        rx_rates[pkt_size].append(rx_rate)
    
    for pkt_size in pkt_sizes:
        med = np.percentile(np.array(tx_rates[pkt_size]), 50)
        high = np.percentile(np.array(tx_rates[pkt_size]), 90)
        low = np.percentile(np.array(tx_rates[pkt_size]), 10)

        median['tx'].append(med)
        err_hi['tx'].append(abs(med-high))
        err_lo['tx'].append(abs(med-low))
        
        med = np.percentile(np.array(rx_rates[pkt_size]), 50)
        high = np.percentile(np.array(rx_rates[pkt_size]), 90)
        low = np.percentile(np.array(rx_rates[pkt_size]), 10)

        median['rx'].append(med)
        err_hi['rx'].append(abs(med-high))
        err_lo['rx'].append(abs(med-low))
    
    print ("Median values")
    print (median['tx'])
    print (median['rx'])
    
    ax.bar(np.arange(len(pkt_sizes)), median['tx'], width, yerr =
        [err_lo['tx'],err_hi['tx']], label="Tx", error_kw=dict(lw=0.5, capsize=1.,
        capthick=0.5),# ecolor=colors[0]),
        #hatch=patterns[cnt],
        lw=0.5, fill=True, color=colors[0], edgecolor='#000000')
    
    ax.bar(np.arange(len(pkt_sizes))+width, median['rx'], width, yerr =
        [err_lo['rx'],err_hi['rx']], label="Fwd", error_kw=dict(lw=0.5, capsize=1.,
        capthick=0.5),# ecolor=colors[0]),
        #hatch=patterns[cnt],
        lw=0.5, fill=True, color=colors[1], edgecolor='#000000')

plot_tput(raw_data_filename)

#ax.set_ylim([0,15])
ax.yaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter('%d'))
fig.canvas.draw()
ax.set_xticks(np.arange(len(pkt_sizes))+width/2)
ax.set_xticklabels(pkt_sizes, fontsize=8)
ax.set_xlabel('Packet size (B)', fontsize=8)
ax.set_yticks(np.arange(0, 110, step=20))
ax.tick_params(axis='y', labelsize=8)
ax.set_ylabel('Tput (Gbps)', fontsize=8)
ax.legend(ncol=2, frameon=True, loc='best', borderaxespad=0.1,
handlelength=0.6, handletextpad=0.2, columnspacing=0.3, fontsize=8,
framealpha=0.5)
ax.minorticks_off()
plt.tight_layout()
# plt.savefig(fig_filename, format="pdf", bbox_inches='tight', pad_inches=0.02)
plt.show()
