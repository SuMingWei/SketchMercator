pcap_file_name_list = ["equinix-chicago.dirA.20160121-130000.UTC.anon.pcap"]

from data_helper.data_path_helper.sketch_cp_path_helper import get_sketch_cp_mrb_path
from python_lib.pkl_saver import PklSaver

from statistics import median

overall_data = []

row = 1
level=16
# epoch = 1


for epoch in [1, 3, 5]:
    for p in [0, 1, 2, 3, 4, 6]:
        print("p = %d" % p)
        for width in [256, 512, 1024, 2048, 4096]:
            data = []
            for pcap_file_name in pcap_file_name_list:
                cp_output_path = get_sketch_cp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
                saver = PklSaver(cp_output_path, "data.pkl")
                load_data = saver.load()
                print("epoch(%d) width(%d) %.2f" % (epoch, width, median(load_data[1:-1])))
                # data.append(median(load_data[1:-1]))
    print()


for epoch in [1, 5]:
# for epoch in [1, 3, 5]:
    # print("p = %d" % p)
    p1=[]
    p2=[]
    p3=[]
    p4=[]
    p6=[]
    for width in [256, 512, 1024, 2048, 4096]:
        data = []
        for p in [0, 1, 2, 3, 4, 6]:
            for pcap_file_name in pcap_file_name_list:
                cp_output_path = get_sketch_cp_mrb_path(hash_set_num=1, w=width, d=row, l=level, problem=p, crc=True, epoch=epoch, pcap_file_name=pcap_file_name)
                saver = PklSaver(cp_output_path, "data.pkl")
                load_data = saver.load()
                # print("epoch(%d) width(%d) %.2f" % (epoch, width, median(load_data[1:-1])))
                data.append(median(load_data[1:-1]))

        print(data)
        p1.append((data[1] - data[0])/data[0]*100)
        p2.append((data[2] - data[0])/data[0]*100)
        p3.append((data[3] - data[0])/data[0]*100)
        p4.append((data[4] - data[0])/data[0]*100)
        p6.append((data[5] - data[0])/data[0]*100)

    print(p1)
    print(p2)
    print(p3)
    print(p4)
    print(p6)
    import matplotlib.pyplot as plt

    fig_size = (4.5, 3)

    fig, ax = plt.subplots(figsize=fig_size)

    linest = "-"
    markerst = 'o'
    
    markerst1 = 'x'
    markerst2 = 'o'
    markerst3 = '^'
    markerst4 = '*'
    markerst5 = '|'

    # x_label = ["512", "1024", "2048", "4096", "8192"]
    x_label = ["4K", "8K", "16K", "32K", "64K"]
    ax.plot(x_label, p6, label='D1-D4 Combined', color="C4", marker=markerst1, markersize=10, linestyle=linest)
    ax.plot(x_label, p1, label='D1. delay before read', color="C0", marker=markerst2, linestyle=linest)
    ax.plot(x_label, p3, label='D2. delay during read', color="C2", marker=markerst3, linestyle=linest)
    ax.plot(x_label, p2, label='D3. delay before reset', color="C1", marker=markerst4, linestyle=linest)
    ax.plot(x_label, p4, label='D4. delay during reset', color="C3", marker=markerst5, linestyle=linest)
    # ax.plot(x_label, overall_data[3], label='epoch 10s', color="C3", marker=markerst, linestyle=linest)
    ax.set_ylabel('Normalized\nError Increase (%)', fontsize=14)
    ax.set_xlabel('counter array size', fontsize=14)
    plt.tick_params(labelsize=14)
    plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
    # plt.xticks(x_label)
    ax.set_title('MRB (epoch %d second)' % epoch, fontsize=15)
    from matplotlib.ticker import MultipleLocator
    if epoch == 1:
        ax.yaxis.set_major_locator(MultipleLocator(200))
    if epoch == 3:
        ax.yaxis.set_major_locator(MultipleLocator(50))
    if epoch == 5:
        ax.yaxis.set_major_locator(MultipleLocator(50))


    fig.tight_layout()
    plt.legend(fontsize=10)
    # if (epoch == 1):
    plt.savefig("mrb_%d.pdf" % epoch)
    # plt.savefig("/Users/hnamkung/Desktop/mrb.png")
    plt.show()
    # break





