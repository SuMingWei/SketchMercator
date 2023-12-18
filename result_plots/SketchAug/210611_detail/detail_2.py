from data_helper.data_path_helper.pcap_path_helper import get_pcap_list_by_date_and_count, convert_to_ether_path
from python_lib.hun_timer import hun_timer

from parallel_run_script.data_plane.SketchAug.cmd import mrb_cmd, hll_cmd, cs_cmd, cm_cmd, univmon_cmd

from sketch_control_plane.SketchAug.main import sketch_cp
import importlib

from data_helper.data_path_helper.tofino_dp_path_helper import get_date_list
from data_helper.data_path_helper.sketch_cp_path_helper import sketch_cp_path
from data_helper.data_path_helper.tofino_dp_path_helper import get_pcounter_path, get_tofino_path
from data_helper.data_path_helper.sw_dp_path_helper import sw_dp_path_with_hash_name
from python_lib.pkl_saver import PklSaver
from statistics import median
from pcap_sender.SketchAug.configs.load import load_param_list

from time import sleep
API="cpp"


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



global_sim_error_list_dict = {}
import traceback



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

def cp_main_start(sketch_name, mode, epoch, array_size):
    tofino_error_list = []
    sim_error_list = []
    wrong_sum_list = []
    wrong_count_list = []
    total_array_size = 0

    for file_name in pcap_file_name_list:
        # print("sketch_name(%s) mode(%s) epoch(%d) array_size(%d) pcap(%s)" % (sketch_name, mode, epoch, array_size, file_name))
        global global_sim_error_list
        API = "cpp"
        try:
            date_list = get_date_list(sketch_name, mode, API, array_size, epoch, file_name)
            date = date_list[0]
            pkl_path = get_path(file_name, sketch_name, mode, array_size, epoch, date)
            # print(pkl_path)
            saver = PklSaver(pkl_path, "data.pkl")
            load_data = saver.load()
            if len(load_data) == 0:
                continue
            print(file_name)
            dcount = 0
            for (wrong_count, wrong_sum, total_array_size, true, sim, sim_error, tofino, tofino_error, sim_ARE_error, tofino_ARE_error) in load_data:
                # print(wrong_count, wrong_sum, total_array_size, true, sim, sim_error, tofino, tofino_error)
                # print("dcount: ", dcount)
                # if epoch == 30 and dcount == 2:
                #     continue
                sim_error = sim_ARE_error
                tofino_error = tofino_ARE_error

                sim_error_list.append(sim_error)
                global_sim_error_list_dict[array_size].append(sim_error)
                tofino_error_list.append(tofino_error)
                wrong_sum_list.append(wrong_sum)
                wrong_count_list.append(wrong_count)
                total_array_size = total_array_size
                dcount += 1
            print(dcount)

        except Exception as e:
            print("[except] FILE NOT FOUND %s " % pkl_path)

    tofino_error = median(tofino_error_list)
    sim_error = median(sim_error_list)
    wrong_sum = median(wrong_sum_list)
    wrong_count = median(wrong_count_list)

    # print(total_array_size)
    print("%20s %20s %20s %20s" % (("sim_error(%.2f)" % sim_error),
                              ("tofino_error(%.2f)" % tofino_error),
                              ("wrong_sum(%d)" % wrong_sum),
                              ("diff_rate(%.2f)" % (wrong_count/total_array_size*100))))
    return tofino_error, wrong_sum

sketch_list = ["cs"]
mode_list = ["baseline", "noreset", "sol3cpp", "pingpong"]

data = {}
data_wrong_sum = {}

sketch_name = "cs"

for mode in mode_list:
    data[mode] = []
    data_wrong_sum[mode] = []

for array_size in [1024, 2048, 4096, 8192, 16384]:
    global_sim_error_list_dict[array_size] = []

epoch = 1
for mode in mode_list:
    print("[mode %s]" % mode)
    for array_size in [1024, 2048, 4096, 8192, 16384]:
        print("[array_size %d]" % array_size)
        tofino_error, wrong_sum = cp_main_start(sketch_name, mode, epoch, array_size)
        data[mode].append(tofino_error)
        data_wrong_sum[mode].append(int(wrong_sum))
    print()
    print()


linest = "-"
markerst1 = 'x'
markerst2 = 'o'
markerst3 = '^'
markerst4 = '*'
markerst5 = '|'

markersize = 5

import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

# fig_size = (4.5, 3.5)
fig_size = (3.5, 2.5)

fig, ax = plt.subplots(figsize=fig_size)

x_label = ["4K", "8K", "16K", "32K", "64K"]
expected = []
for array_size in [1024, 2048, 4096, 8192, 16384]:
    expected.append(median(global_sim_error_list_dict[array_size]))

print("expected:", expected)
print("unoptimized:", data["baseline"])
print("pingpong:", data["pingpong"])
print("noreset:", data["noreset"])
print("sol3cpp:", data["sol3cpp"])
print()
print()

ax.plot(x_label, data["baseline"], label='Unopt', color="C1", marker=markerst2, markersize=markersize, linestyle=linest)
ax.plot(x_label, data["pingpong"], label='Sol 1', color="C4", marker=markerst3, markersize=markersize, linestyle=linest)
ax.plot(x_label, data["noreset"], label='Sol 2', color="C2", marker=markerst3, markersize=markersize, linestyle=linest)
ax.plot(x_label, data["sol3cpp"], label='Sol 3', color="C3", marker=markerst4, markersize=markersize, linestyle=linest)
ax.plot(x_label, expected, label='Expected', color="C0", marker=markerst1, markersize=markersize+2, linestyle=linest)

ax.set_ylabel('ARE ($\%$)', fontsize=14)
ax.set_xlabel('array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('CS (epoch length 1s)', fontsize=13)
from matplotlib.ticker import MultipleLocator
# if epoch == 1:
#     ax.yaxis.set_major_locator(MultipleLocator(200))
# if epoch == 3:
#     ax.yaxis.set_major_locator(MultipleLocator(50))
# if epoch == 5:
ax.yaxis.set_major_locator(MultipleLocator(10))
# ax.yaxis.set_major_locator(MultipleLocator(0.02))
# ax.set_ylim([0, 1000])

plt.legend(loc="upper left", fontsize=9, ncol=2)
fig.tight_layout()
plt.savefig("cs_array_size_re.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()



print("unoptimized", data_wrong_sum["baseline"])
print("pingpong", data_wrong_sum["pingpong"])
print("noreset", data_wrong_sum["noreset"])
print("sol3cpp", data_wrong_sum["sol3cpp"])

# fig_size = (4.5, 3.5)
fig_size = (3.5, 2.5)

fig, ax = plt.subplots(figsize=fig_size)

x_label = ["4K", "8K", "16K", "32K", "64K"]


ax.plot(x_label, data_wrong_sum["baseline"], label='Unopt', color="C1", marker=markerst2, markersize=markersize, linestyle=linest)
# ax.plot(x_label, data_wrong_sum["pingpong"], label='Sol 1', color="C2", marker=markerst2, markersize=markersize, linestyle=linest)
ax.plot(x_label, data_wrong_sum["noreset"], label='Sol 2', color="C2", marker=markerst3, markersize=markersize, linestyle=linest)
ax.plot(x_label, data_wrong_sum["sol3cpp"], label='Sol 3', color="C3", marker=markerst4, markersize=markersize, linestyle=linest)

plt.yscale("log")

ax.set_ylabel('Total Counter\nValue Difference', fontsize=14)
ax.set_xlabel('array size', fontsize=14)
plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label)
ax.set_title('CS (epoch length 1s)', fontsize=13)
from matplotlib.ticker import MultipleLocator
# if epoch == 1:
#     ax.yaxis.set_major_locator(MultipleLocator(200))
# if epoch == 3:
#     ax.yaxis.set_major_locator(MultipleLocator(50))
# if epoch == 5:
# ax.yaxis.set_major_locator(MultipleLocator(10))
# ax.yaxis.set_major_locator(MultipleLocator(0.02))
ax.set_ylim([0, 1000000])

plt.legend(loc="upper left", fontsize=9, ncol=1)
fig.tight_layout()
plt.savefig("cs_array_size_diff.pdf")
# plt.savefig("/Users/hnamkung/Desktop/mrb.png")
plt.show()

