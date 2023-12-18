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


# x = [1, 2, 3, 4, 5]
# labels = ['1K', '2K', '4K', '8K', '16K']

# fig, ax = plt.subplots(figsize=(4, 3))
# plt.xticks(x, labels, rotation='vertical')
# # plt.xlim([0.5, 5.5])
# linest = "-"
# markerst = '.'

# ax.plot(x, data[0], label='ROW=1', color="C0", marker=markerst, linestyle=linest)
# ax.plot(x, data[1], label='ROW=3', color="C1", marker=markerst, linestyle=linest)
# ax.plot(x, data[2], label='ROW=5', color="C2", marker=markerst, linestyle=linest)
# ax.plot(x, data[3], label='ROW=7', color="C3", marker=markerst, linestyle=linest)
# ax.plot(x, data[4], label='ROW=9', color="C4", marker=markerst, linestyle=linest)

# ax.yaxis.set_major_locator(MultipleLocator(5))
# ax.axhline(y=5, color='red', linestyle="--", linewidth=1)
# # plt.ylim([40,120])
# ax.set_ylabel('Accuracy (%)', fontsize=14)

# plt.tick_params(labelsize=12)
# fig.tight_layout()
# plt.legend()
# # plt.show()
# plt.savefig("a.png")
# # plt.savefig(name)


x = [1, 2, 3, 4, 5]
# labels = ['ROW=1', 'ROW=3', 'ROW=5', 'ROW=7', 'ROW=9']
labels = ['1', '3', '5', '7', '9']

fig, ax = plt.subplots(figsize=(3, 3))
plt.xticks(x, labels)
# plt.xlim([0.5, 5.5])
linest = "-"
markerst = '.'

# ax.plot(x, data2[0], label='1K', color="C0", marker=markerst, linestyle=linest)
ax.plot(x, data2[1], label='Width=2K', color="C1", marker=markerst, linestyle=linest)
ax.plot(x, data2[2], label='Width=4K', color="C2", marker=markerst, linestyle=linest)
ax.plot(x, data2[3], label='Width=8K', color="C3", marker=markerst, linestyle=linest)
# ax.plot(x, data2[4], label='16K', color="C4", marker=markerst, linestyle=linest)

ax.yaxis.set_major_locator(MultipleLocator(5))
ax.axhline(y=3, color='red', linestyle="--", linewidth=1)
# plt.ylim([40,120])
ax.set_ylabel('ARE (\%)', fontsize=14)
ax.set_xlabel('Row', fontsize=14)

plt.tick_params(labelsize=12)
fig.tight_layout()
plt.legend()
# plt.show()
# plt.savefig("countsketch_accuracy.png")
plt.savefig("countsketch_accuracy.pdf")
