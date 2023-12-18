# pcap_file_name="equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"

# from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_cs_path
# from python_lib.pkl_saver import PklSaver

# from statistics import median

# row = 5
# width = 4096
# epoch = 1

# epoch_normal = []
# epoch_sketch_aug = []
# for epoch in [1,3,5,10]:
# # for epoch in [10,5,3,1]:
#     cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=False, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
#     saver = PklSaver(cp_output_path, "data.pkl")
#     data = saver.load()
#     epoch_normal.append(median(data))

#     cp_output_path = get_sketch_cp_cs_path(hash_set_num=1, w=width, d=row, l=1, sketch_aug=True, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
#     saver = PklSaver(cp_output_path, "data.pkl")
#     data = saver.load()
#     epoch_sketch_aug.append(median(data))
#     # print(data)

# print(epoch_normal)
# print(epoch_sketch_aug)

# import matplotlib.pyplot as plt

# fig_size = (4, 3)

# fig, ax = plt.subplots(figsize=fig_size)


# # x_label = ["10", "5", "3", "1"]
# # x_label = [1, 3, 5, 10]
# x = [1,2,3,4]
# x_label = ['naive', 'naive', 'naive', 'naive']
# epoch_normal=[5,6,7,8]
# epoch_sketch_aug=[9,10,11,12]
# ax.plot(x, epoch_normal, label='ideal', color="C0", marker=markerst, linestyle=linest)
# ax.plot(x, epoch_sketch_aug, label='simulation', color="C1", marker=markerst, linestyle=linest)

# plt.xticks(x, x_label)
# # ax.set_xticklabels(x, x_label)

# ax.set_ylabel('Average Relative Error (%)', fontsize=14)
# ax.set_xlabel('epoch size (s)', fontsize=14)
# plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
# plt.xticks(x_label, x_label)
# ax.set_title('ideal vs simulation on epoch size', fontsize=15)

# plt.savefig("/Users/hnamkung/Desktop/plot1.png")
# plt.show()

from env_setting.env_module import result_resource_path
import os

print(result_resource_path)

template = "RmtTofino45_p414_set_%d_4dim_%s.txt"

Pipeline = []
HASHs = []
SALUs = []
SRAM = []

for set in [1,2,3]:
    Pipeline_list = []
    HASHs_list = []
    SALUs_list = []
    SRAM_list = []
    for method in ["naive", "idea1", "idea2", "idea3", "idea4"]:
        filename = template % (set, method)
        # print(filename)
        full_path = os.path.join(result_resource_path, "SketchMD/jose/dim4/maximumStage",filename)
        f = open(full_path)
        pipeline = int(f.readline().strip().split("maximum_stage ")[1])
        hash = int(f.readline().strip().split("hash_dist_unit ")[1])
        salu = int(f.readline().strip().split("salu ")[1])
        map_ram = int(f.readline().strip().split("map_ram ")[1])

        Pipeline_list.append(pipeline)
        HASHs_list.append(hash)
        SALUs_list.append(salu)
        SRAM_list.append(map_ram)
    # print(Pipeline_list)
    Pipeline.append(Pipeline_list)

    # print(HASHs_list)
    HASHs.append(HASHs_list)

    # print(SALUs_list)
    SALUs.append(SALUs_list)

    # print(SRAM_list)
    SRAM.append(SRAM_list)


print(Pipeline)
print(SALUs)
print(HASHs)
print(SRAM)


import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator

x = [1, 2, 3, 4, 5]
labels = ['Naive', 'idea1', 'idea1-2', 'idea1-3', 'idea1-4']

for data, name in zip([SALUs, HASHs, SRAM, Pipeline], ["salu.png", "hash.png", "sram.png", "pipeline.png"]):
    fig, ax = plt.subplots(figsize=(4, 3))
    plt.xticks(x, labels, rotation='vertical')
    plt.xlim([0.5, 5.5])
    linest = "-"
    markerst = 'o'
    ax.plot(x, data[0], label='set1', color="C0", marker=markerst, linestyle=linest)
    ax.plot(x, data[1], label='set2', color="C1", marker=markerst, linestyle=linest)
    ax.plot(x, data[2], label='set3', color="C2", marker=markerst, linestyle=linest)

    if name == "salu.png":
        ax.yaxis.set_major_locator(MultipleLocator(10))
        ax.axhline(y=48, color='red', linestyle="--", linewidth=2)
        plt.ylim([40,120])
        ax.set_ylabel('SALU usage', fontsize=14)
    if name == "hash.png":
        ax.yaxis.set_major_locator(MultipleLocator(10))
        ax.axhline(y=72, color='red', linestyle="--", linewidth=2)
        plt.ylim([60,150])
        ax.set_ylabel('Hash Call usage', fontsize=14)
    if name == "sram.png":
        ax.yaxis.set_major_locator(MultipleLocator(100))
        ax.axhline(y=576, color='red', linestyle="--", linewidth=2)
        plt.ylim([50,600])
        ax.set_ylabel('SRAM usage', fontsize=14)
    if name == "pipeline.png":
        ax.yaxis.set_major_locator(MultipleLocator(2))
        ax.axhline(y=12, color='red', linestyle="--", linewidth=2)
        plt.ylim([10,30])
        ax.set_ylabel('Pipeline Stage usage', fontsize=14)

    plt.tick_params(labelsize=12)
    fig.tight_layout()
    plt.legend()
    # plt.show()
    plt.savefig(name)


