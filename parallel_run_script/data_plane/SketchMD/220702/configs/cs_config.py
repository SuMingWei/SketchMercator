seed_list = [1, 2, 3, 4, 5]

key = "srcIP,dstIP,srcPort,dstPort,proto"
key_list = []

epoch = 60
epoch_list = []

level = 1
level_list = []

row_list = []
width_list = []

for row in [1,3,5,7,9]:
    for width in [1024, 2048, 4096, 8192, 16384]:
        key_list.append(key)
        epoch_list.append(epoch)
        level_list.append(level)
        row_list.append(row)
        width_list.append(width)