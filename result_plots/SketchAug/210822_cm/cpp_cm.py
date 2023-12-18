pcap_file_name_list = ["equinix-chicago.dirA.20160121-130000.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130100.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130200.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130300.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130400.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130500.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130600.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130700.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130800.UTC.anon.pcap",
                       "equinix-chicago.dirA.20160121-130900.UTC.anon.pcap"]

# pcap_file_name_list = ["equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"]
#                        "equinix-chicago.dirA.20160121-130100.UTC.anon.pcap"]

from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path
from python_lib.pkl_saver import PklSaver
from data_helper.data_path_helper.tofino_dp_path_helper import get_date_list
from statistics import median

overall_data = []

depth = 4
level=1
API="cpp"
sketch_name = "cm"
mode = "baseline"

def get_path(pcap_file_name, sketch_name, mode, array_size, epoch, date):
    API = "cpp"
    if sketch_name == "mrb":
        width = array_size/16
        depth = 1
        level = 16
    if sketch_name == "hll":
        width = array_size
        depth = 1
        level = 1
    if sketch_name == "cs":
        width = array_size
        depth = 4
        level = 1
    if sketch_name == "cm":
        width = array_size
        depth = 4
        level = 1
    if sketch_name == "univmon":
        width = array_size/16
        depth = 4
        level = 16
    
    pkl_path = sketch_cp_path(sketch_name, epoch, width, depth, level, mode, crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, date=date, hash_set_num=1)
    
    return pkl_path

card_error_data = []
diff_error_data = []
for epoch in [1, 5, 10, 20, 30]:
    for p in [0]:
        # print("p = %d" % p)
        result1 = []
        result2 = []

        for array_size in [1024, 2048, 4096, 8192, 16384]:
        # for width in [1024, 2048, 4096]:
            sim_error_list = []
            tofino_error_list = []
            diff_error_list = []
            for file_name in pcap_file_name_list:
                date_list = get_date_list(sketch_name, mode, API, array_size, epoch, file_name)
                if len(date_list) == 0:
                    print("no data for %s" % file_name)
                    continue
                date = date_list[0]
                print(file_name, date)
                pkl_path = get_path(file_name, sketch_name, mode, array_size, epoch, date)
                # pkl_path = sketch_cp_path("mrb", epoch, width, depth, level, "baseline", crc=True, pcap_file_name=pcap_file_name, hardware=True, api=API, hash_set_num=1)
                # cp_output_path = get_sketch_cp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name, hardware=True, api="cpp")
                try:
                    saver = PklSaver(pkl_path, "data.pkl")
                    load_data = saver.load()

                    dcount = 0
                    count = 0
                    for (wrong_count, wrong_sum, total_array_size, sim_error, tofino_error) in load_data:
                        # print(wrong_count, wrong_sum, total_array_size, sim_error, tofino_error)
                        count += 1
                        # if count >= 60/epoch:
                        #     break
                        if total_array_size == 0:
                            continue
                        dcount += 1
                        sim_error_list.append(sim_error)
                        tofino_error_list.append(tofino_error)
                        diff_error_list.append(wrong_count/total_array_size*100)
                    print(dcount)
                except Exception as e:
                    import traceback
                    # print("except")
                    traceback.print_exc()

            # print(load_data)
            sim_error = median(sim_error_list)
            tofino_error = median(tofino_error_list)
            diff_percent = median(diff_error_list)


            error_increase = (tofino_error - sim_error) / sim_error * 100

            print("sim_error: ", sim_error)
            print("tofino_error: ", tofino_error)
            print("error_increase: ", error_increase)
            # print("epoch(%d) array_size(%d) sim_error(%.2f) tofino_error(%.2f) error_increase(%.2f) diff_error(%.2f)" %
            #     (epoch, array_size, sim_error, tofino_error, error_increase, diff_percent))

            print("epoch(%d) array_size(%d) diff_error(%.2f) error_increase(%.2f)" % (epoch, array_size, diff_percent, error_increase))
            print()

            result1.append(error_increase)
            result2.append(diff_percent)

        card_error_data.append(result1)
        diff_error_data.append(result2)

                # exit(1)
                # data.append(median(load_data[1:-1]))
    print()

print()
for e in diff_error_data:
    print(e)

print()
for e in card_error_data:
    print(e)

import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

# fig_size = (4.5, 3.5)

linest = "-"

markerst1 = 'x'
markerst2 = 'o'
markerst3 = '^'
markerst4 = '*'
markerst5 = '|'


markersize = 5

# fig_size = (4.5, 3.5)
# fig_size = (2.5, 2.5)
fig_size = (3.5, 2.5)

fig, ax = plt.subplots(figsize=fig_size)

x_label = ["4K", "8K", "16K", "32K", "64K"]
ax.plot(x_label, diff_error_data[0], label='epoch 1s', color="C0", marker=markerst1, markersize=markersize, linestyle=linest)
ax.plot(x_label, diff_error_data[1], label='epoch 5s', color="C1", marker=markerst2, markersize=markersize, linestyle=linest)
ax.plot(x_label, diff_error_data[2], label='epoch 10s', color="C2", marker=markerst3, markersize=markersize, linestyle=linest)
ax.plot(x_label, diff_error_data[3], label='epoch 20s', color="C3", marker=markerst4, markersize=markersize, linestyle=linest)
ax.plot(x_label, diff_error_data[4], label='epoch 30s', color="C4", marker=markerst5, markersize=markersize, linestyle=linest)

ax.set_ylabel('$\%$ of Different\nCounters', fontsize=14)
ax.set_xlabel('counter array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('Different Counters', fontsize=13)
from matplotlib.ticker import MultipleLocator
# if epoch == 1:
#     ax.yaxis.set_major_locator(MultipleLocator(200))
# if epoch == 3:
#     ax.yaxis.set_major_locator(MultipleLocator(50))
# if epoch == 5:
# ax.yaxis.set_major_locator(MultipleLocator(1))
ax.yaxis.set_major_locator(MultipleLocator(20))
ax.set_ylim([0, 100])

fig.tight_layout()
plt.legend(loc="lower left", fontsize=9)
plt.savefig("mrb_cpp_counter.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()


fig, ax = plt.subplots(figsize=fig_size)
x_label = ["4K", "8K", "16K", "32K", "64K"]

# x_label = ["4096", "8192", "16384", "32768", "65536"]
# x_label = [r"$2^{12}$", r"$2^{13}$", r"$2^{14}$", r"$2^{15}$", r"$2^{16}$"]
# x_label = ["16384", "32768", "65536"]
ax.plot(x_label, card_error_data[0], label='epoch 1s', color="C0", marker=markerst1, markersize=markersize, linestyle=linest)
ax.plot(x_label, card_error_data[1], label='epoch 5s', color="C1", marker=markerst2, markersize=markersize, linestyle=linest)
ax.plot(x_label, card_error_data[2], label='epoch 10s', color="C2", marker=markerst3, markersize=markersize, linestyle=linest)
ax.plot(x_label, card_error_data[3], label='epoch 20s', color="C3", marker=markerst4, markersize=markersize, linestyle=linest)
ax.plot(x_label, card_error_data[4], label='epoch 30s', color="C4", marker=markerst5, markersize=markersize, linestyle=linest)

# ax.plot(x_label, overall_data[3], label='epoch 10s', color="C3", marker=markerst, linestyle=linest)
ax.set_ylabel('Normalized\nError Increase ($\%$)', fontsize=14)
ax.set_xlabel('counter array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('Error Increase', fontsize=13)
from matplotlib.ticker import MultipleLocator
# if epoch == 1:
#     ax.yaxis.set_major_locator(MultipleLocator(200))
# if epoch == 3:
#     ax.yaxis.set_major_locator(MultipleLocator(50))
# if epoch == 5:
ax.yaxis.set_major_locator(MultipleLocator(2000))
ax.set_ylim([-500, 10000])

fig.tight_layout()
# plt.yscale("log")
plt.legend(fontsize=9)
plt.savefig("mrb_cpp_acc.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()



