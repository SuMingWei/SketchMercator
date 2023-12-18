pcap_file_name="equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"

from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_hll_path
from python_lib.pkl_saver import PklSaver

from statistics import median
import matplotlib.pyplot as plt


row = 1
epoch = 1

size_normal = []
size_sketch_aug = []
epoch = 1
for width in [512, 1024, 2048, 4096]:
    cp_output_path = get_sketch_cp_hll_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    saver = PklSaver(cp_output_path, "data.pkl")
    data = saver.load()
    size_normal.append(median(data))

    cp_output_path = get_sketch_cp_hll_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
    saver = PklSaver(cp_output_path, "data.pkl")
    data = saver.load()
    size_sketch_aug.append(median(data))

print(size_normal)
print(size_sketch_aug)


fig_size = (4, 3)

fig, ax = plt.subplots(figsize=fig_size)

linest = "-"
markerst = 'o'

# x_label = ["4096", "8192", "12288", "16384", "20480"]
x_label = ["512", "1024", "2048", "4096"]
ax.plot(x_label, size_normal, label='ideal', color="C0", marker=markerst, linestyle=linest)
ax.plot(x_label, size_sketch_aug, label='simulation', color="C1", marker=markerst, linestyle=linest)
ax.set_ylabel('Average Relative Error (%)', fontsize=14)
ax.set_xlabel('array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('ideal vs simulation on array size', fontsize=15)

fig.tight_layout()
plt.legend()
plt.savefig("/Users/hnamkung/Desktop/plot2.png")
plt.show()
