pcap_file_name="equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"

from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_cs_path
from python_lib.pkl_saver import PklSaver

from statistics import median

row = 5
width = 4096
epoch = 1

epoch_normal = []
epoch_sketch_aug = []
diff = []
for epoch in [1,3,5,10]:
# for epoch in [10,5,3,1]:
    cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    saver = PklSaver(cp_output_path, "data.pkl")
    data = saver.load()
    a = median(data)
    epoch_normal.append(a)

    cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    saver = PklSaver(cp_output_path, "data.pkl")
    data = saver.load()
    b = median(data)
    epoch_sketch_aug.append(b)

    diff.append(b - a)
    # print(data)

print(epoch_normal)
print(epoch_sketch_aug)

import matplotlib.pyplot as plt

fig_size = (4.5, 3)

fig, ax = plt.subplots(figsize=fig_size)

linest = "-"
markerst = 'o'

# x_label = ["10", "5", "3", "1"]
x_label = [1, 3, 5, 10]
ax.plot(x_label, diff, label='Error(delay)-Error(baseline)', color="C0", marker=markerst, linestyle=linest)
# ax.plot(x_label, epoch_sketch_aug, label='simulation', color="C1", marker=markerst, linestyle=linest)
ax.set_ylabel('Absolute Error Increase (%)', fontsize=14)
ax.set_xlabel('epoch size (s)', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
plt.xticks(x_label, x_label)
ax.set_title('Count-sketch on different epoch sizes', fontsize=15)

from matplotlib.ticker import MultipleLocator
ax.yaxis.set_major_locator(MultipleLocator(2))

fig.tight_layout()
plt.legend()
plt.savefig("/Users/hnamkung/Desktop/plot3.png")
plt.show()







