from env_setting.env_module import result_resource_path
import os
import matplotlib.pyplot as plt
import matplotlib
from matplotlib.ticker import MultipleLocator
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

data = []
data.append([33.2, 21.56, 13.27, 7.33, 5.61])
data.append([20.86, 11.2, 6.41, 3.05, 1.53])
data.append([16.5, 8.53, 4.44, 1.93, 0.96])
data.append([12.94, 6.2, 3.85, 1.48, 0.74])
data.append([10.87, 5.69, 3.17, 1.32, 0.67])

import numpy as np
nparray = np.array(data)
data2 = np.transpose(nparray)

x = [1, 2, 3, 4, 5]
labels = ['1', '3', '5', '7', '9']

fig, ax = plt.subplots(figsize=(3.5, 3))
plt.xticks(x, labels)
# plt.xlim([0.5, 5.5])
linest = "-"
markerst = '.'

ax.plot(x, data2[1], label='W=2K', color="C0", marker="^", linestyle=linest)
ax.plot(x, data2[2], label='W=4K', color="C1", marker="s", linestyle=linest)
ax.plot(x, data2[3], label='W=8K', color="C2", marker=".", linestyle=linest)

ax.yaxis.set_major_locator(MultipleLocator(5))
ax.axhline(y=3, color='red', linestyle="--", linewidth=1)
# plt.ylim([40,120])
ax.set_ylabel('ARE (\%)', fontsize=16)
ax.set_xlabel('Number of Rows (R)', fontsize=16)

plt.tick_params(labelsize=16)
# plt.legend(fontsize=14, loc="lower left", bbox_to_anchor = (-0.0, 1.02, 1, 0.4), ncol=2)
# plt.legend(fontsize=14, loc="lower left", bbox_to_anchor = (-0.0, 1.02, 1, 0.4), ncol=2)
plt.legend(fontsize=14, loc="lower left", bbox_to_anchor = (-0.1, 1), ncol=2)
# plt.legend(fontsize=14, bbox_to_anchor = (1.0, 1.5), ncol=2)
plt.tight_layout()
# plt.show()
# plt.savefig("countsketch_accuracy.png")
plt.savefig("/Users/hnamkung/hun-latex/multi-dim-latex/sigcomm22/figures/3_bottleneck/countsketch_accuracy.pdf", bbox_inches='tight')
# plt.savefig("countsketch_accuracy.pdf", bbox_inches='tight')
