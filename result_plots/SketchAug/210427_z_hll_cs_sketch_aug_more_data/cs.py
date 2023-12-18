pcap_file_name="equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"
pcap_file_name_list = ["equinix-chicago.dirA.20160121-130000.UTC.anon.pcap",
                        "equinix-chicago.dirA.20160121-130100.UTC.anon.pcap",
                        "equinix-chicago.dirA.20160121-130200.UTC.anon.pcap",
                        "equinix-chicago.dirA.20160121-130300.UTC.anon.pcap",
                        "equinix-chicago.dirA.20160121-130400.UTC.anon.pcap"]

from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_cs_path
from python_lib.pkl_saver import PklSaver

from statistics import median

width = 4096
overall_data = []

for epoch in [1,3,5,10]:
for epoch in [1,3,5,10]:
    epoch_data = []
    for row in [1, 2, 3, 4, 5]:

        data_normal = []
        data_aug = []

        for pcap_file_name in pcap_file_name_list:
            cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            saver = PklSaver(cp_output_path, "data.pkl")
            load_data = saver.load()
            data_normal += load_data

            cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
            saver = PklSaver(cp_output_path, "data.pkl")
            load_data = saver.load()
            data_aug += load_data

        metric = (median(data_aug)-median(data_normal)) / median(data_normal) * 100
        print("epoch(%d) row(%d) %.2f - %.2f = %.2f " % (epoch, row, median(data_aug), median(data_normal), median(data_aug) -median(data_normal)))
        
        epoch_data.append(metric)

    overall_data.append(epoch_data)

# print(overall_data)
print(overall_data[0])
print(overall_data[1])
print(overall_data[2])
print(overall_data[3])

import matplotlib.pyplot as plt

fig_size = (4.5, 3)

fig, ax = plt.subplots(figsize=fig_size)

linest = "-"
markerst = 'o'

x_label = ["4096", "8192", "12288", "16384", "20480"]
ax.plot(x_label, overall_data[0], label='epoch 1s', color="C0", marker=markerst, linestyle=linest)
ax.plot(x_label, overall_data[1], label='epoch 3s', color="C1", marker=markerst, linestyle=linest)
ax.plot(x_label, overall_data[2], label='epoch 5s', color="C2", marker=markerst, linestyle=linest)
ax.plot(x_label, overall_data[3], label='epoch 10s', color="C3", marker=markerst, linestyle=linest)
ax.set_ylabel('Normalized\nError Increase (%)', fontsize=14)
ax.set_xlabel('array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('Count-sketch', fontsize=15)
from matplotlib.ticker import MultipleLocator
ax.yaxis.set_major_locator(MultipleLocator(100))

fig.tight_layout()
plt.legend()
plt.savefig("/Users/hnamkung/Desktop/cs.png")
plt.show()





