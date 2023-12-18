# seed_list = [1, 2, 3, 4, 5]

# key = "srcIP,dstIP,srcPort,dstPort,proto"
# key_list = []

# epoch = 60
# epoch_list = []

# level = 1
# level_list = []

# row_list = []
# width_list = []

# for row in [1,3,5,7,9]:
#     for width in [1024, 2048, 4096, 8192, 16384]:
# # for row in [9]:
# #     for width in [16384]:
#         key_list.append(key)
#         epoch_list.append(epoch)
#         level_list.append(level)
#         row_list.append(row)
#         width_list.append(width)

# seed_list = [1, 2, 3, 4, 5]
# seed_list = [1, 2, 3]
# seed_list = [1, 2, 3]
seed_list = [1, 2, 3, 4, 5, 6]

key = "srcIP,dstIP,srcPort,dstPort"
key_list = []

epoch = 10
epoch_list = []

level = 1
level_list = []

row_list = []
width_list = []
xor_hash_type_list = []

row = 1
# for row in [1, 2]:
for row in [2]:
    if row == 1:
        hash_type_candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    if row == 2:
        hash_type_candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    for hash_type in hash_type_candidates:
        for width in [16384]:
        # for width in [1024, 2048, 4096]:
            xor_hash_type_list.append(hash_type)
            key_list.append(key)
            epoch_list.append(epoch)
            level_list.append(level)
            row_list.append(row)
            width_list.append(width)
