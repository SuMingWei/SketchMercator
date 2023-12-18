pcap_file_name_list = ["equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"]

from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_mrb_path
from python_lib.pkl_saver import PklSaver

from statistics import median

overall_data = []

row = 1
level=16
# epoch = 1


card_error_data = []
diff_error_data = []
for epoch in [10, 20, 30]:
    for p in [0]:
        # print("p = %d" % p)
        result1 = []
        result2 = []

        for width in [256, 512, 1024]:
            data = []
            for pcap_file_name in pcap_file_name_list:
                cp_output_path = get_sketch_cp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name, hardware=True)
                saver = PklSaver(cp_output_path, "data.pkl")
                load_data = saver.load()

                sim_error_list = []
                tofino_error_list = []
                diff_error_list = []

                for (true_cardinality, sim_cardinality, sim_error, tofino_cardinality, tofino_error, diff_percent) in load_data:
                    sim_error_list.append(sim_error)
                    tofino_error_list.append(tofino_error)
                    diff_error_list.append(diff_percent)

                # print(load_data)
                sim_error = median(sim_error_list)
                tofino_error = median(tofino_error_list)
                diff_percent = median(diff_error_list)

                print("epoch(%d) width(%d) sim_error(%.2f) tofino_error(%.2f) diff_error(%.2f)" %
                    (epoch, width, sim_error, tofino_error, diff_percent))
                result1.append((tofino_error - sim_error) / sim_error * 100)
                result2.append(diff_percent)

        card_error_data.append(result1)
        diff_error_data.append(result2)

                # exit(1)
                # data.append(median(load_data[1:-1]))
    print()

import matplotlib.pyplot as plt

fig_size = (3.5, 2.5)

fig, ax = plt.subplots(figsize=fig_size)

linest = "-"
markerst = 'o'

x_label = ["4096", "8192", "16384"]
ax.plot(x_label, card_error_data[0], label='epoch 10s', color="C0", marker=markerst, linestyle=linest)
ax.plot(x_label, card_error_data[1], label='epoch 20s', color="C1", marker=markerst, linestyle=linest)
ax.plot(x_label, card_error_data[2], label='epoch 30s', color="C2", marker=markerst, linestyle=linest)
# ax.plot(x_label, overall_data[3], label='epoch 10s', color="C3", marker=markerst, linestyle=linest)
ax.set_ylabel('Normalized\nError Increase (%)', fontsize=14)
ax.set_xlabel('counter array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('MRB python API', fontsize=13)
from matplotlib.ticker import MultipleLocator
# if epoch == 1:
#     ax.yaxis.set_major_locator(MultipleLocator(200))
# if epoch == 3:
#     ax.yaxis.set_major_locator(MultipleLocator(50))
# if epoch == 5:
ax.yaxis.set_major_locator(MultipleLocator(500))


fig.tight_layout()
# plt.yscale("log")
plt.legend()
plt.savefig("mrb_python_acc.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()



fig_size = (3.5, 2.5)

fig, ax = plt.subplots(figsize=fig_size)

linest = "-"
markerst = 'o'

x_label = ["4096", "8192", "16384"]
ax.plot(x_label, diff_error_data[0], label='epoch 10s', color="C0", marker=markerst, linestyle=linest)
ax.plot(x_label, diff_error_data[1], label='epoch 20s', color="C1", marker=markerst, linestyle=linest)
ax.plot(x_label, diff_error_data[2], label='epoch 30s', color="C2", marker=markerst, linestyle=linest)
# ax.plot(x_label, overall_data[3], label='epoch 10s', color="C3", marker=markerst, linestyle=linest)
ax.set_ylabel('% of Incorrect\nCounters', fontsize=14)
ax.set_xlabel('counter array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('MRB python API', fontsize=13)
from matplotlib.ticker import MultipleLocator
# if epoch == 1:
#     ax.yaxis.set_major_locator(MultipleLocator(200))
# if epoch == 3:
#     ax.yaxis.set_major_locator(MultipleLocator(50))
# if epoch == 5:
ax.yaxis.set_major_locator(MultipleLocator(2))


fig.tight_layout()
plt.legend()
plt.savefig("mrb_python_counter.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()





