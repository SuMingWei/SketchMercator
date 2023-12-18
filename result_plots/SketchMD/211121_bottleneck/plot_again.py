from env_setting.env_module import result_resource_path
import os
import matplotlib.pyplot as plt
import matplotlib
from matplotlib.ticker import MultipleLocator
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

PS = [5, 6, 7, 8, 9, 10, 11]
SALU = [2, 6, 10, 14, 18, 23, 30]
hashcall = [2, 6, 10, 14, 18, 23, 30]
SRAM = [10, 27, 44, 61, 77, 93, 123]

print(PS)
print(SALU)
print(hashcall)
print(SRAM)

PS_P = []
SALU_P = []
hashcall_P = []
SRAM_P = []
for d in range(0, 7):
    PS_P.append(PS[d]/12*100)
    SALU_P.append(SALU[d]/(4*12)*100)
    hashcall_P.append(hashcall[d]/(6*12)*100)
    SRAM_P.append(SRAM[d]/(80*12)*100)

print(PS_P)
print(SALU_P)
print(hashcall_P)
print(SRAM_P)


x = [1, 2, 3, 4, 5, 6, 7]
labels = ['1', '2', '3', '4', '5', '6', '7']

fig, ax = plt.subplots(figsize=(4.8, 2))
plt.xticks(x, labels)
# plt.xlim([0.5, 5.5])
linest = "-"
markerst = '.'

# ax.plot(x, data2[0], label='1K', color="C0", marker=markerst, linestyle=linest)
ax.plot(x, PS_P, label='Pipeline Stages', color="C3", marker=".", linestyle=linest)
ax.plot(x, hashcall_P, label='Hash Calls', color="C4", marker="x", linestyle=linest)
ax.plot(x, SALU_P, label='SALUs', color="C5", marker="^", linestyle=linest)
ax.plot(x, SRAM_P, label='SRAM', color="C6", marker="|", linestyle=linest)
# ax.plot(x, data2[2], label='Width=4K', color="C2", marker=markerst, linestyle=linest)
# ax.plot(x, data2[3], label='Width=8K', color="C3", marker=markerst, linestyle=linest)
# ax.plot(x, data2[4], label='16K', color="C4", marker=markerst, linestyle=linest)

ax.yaxis.set_major_locator(MultipleLocator(25))
ax.axhline(y=100, color='red', linestyle="--", linewidth=1)
plt.ylim([-5, 105])
ax.set_ylabel('Resource Use (\%)', fontsize=16)
ax.set_xlabel('Number of Sketch Instances', fontsize=16)

plt.tick_params(labelsize=16)
plt.legend()

# plt.legend(bbox_to_anchor = (1.0, 1.4), ncol=2)
plt.legend(fontsize=14, bbox_to_anchor = (1, 0.8, 0.3, 0.2), ncol=1)
# plt.legend(fontsize=14, loc="lower left", bbox_to_anchor = (-0.4, 0.98), ncol=2)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
fig.tight_layout()
# plt.show()
# plt.savefig("bottleneck.pdf", bbox_inches='tight')
plt.savefig("/Users/hnamkung/hun-latex/Hun-multi-dim-sketches/nsdi23/figures/3_bottleneck/bottleneck.pdf", bbox_inches='tight')
