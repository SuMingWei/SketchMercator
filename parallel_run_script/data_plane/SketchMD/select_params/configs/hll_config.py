seed_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

key = "srcIP,dstIP,srcPort,dstPort,proto"
key_list = []

epoch = 60
epoch_list = []

row = 1
row_list = []

level = 1
level_list = []

for width in [1024, 4096, 16384, 65536, 262144]:
    key_list.append(key)
    epoch_list.append(epoch)
    row_list.append(row)
    level_list.append(level)
    width_list.append(width)