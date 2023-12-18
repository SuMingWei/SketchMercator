import os

def print_tab(f, j):
    for k in range(1, j+1):
        f.write('\t')

row_list = [3,3,3,3,3,3,3,3   , 5,5,5,5,5, 1,2,3,4,5,      5,5,5,5,   3,3,3 , 3, 3]
level_list = [1,2,3,4,5,6,7,8 , 1,2,3,4,5, 16,16,16,16,16, 4,8,12,20, 4,8,12,16,20]

for row, level in zip(row_list, level_list):
# for row in [3, 5]:
#     if row == 3:
#         level_list = [1,2,3,4,5,6,7,8]
#     if row == 5:
#         level_list = [1,2,3,4,5]
#     for level in level_list:

# for row in [1, 2, 3, 4, 5]:
#     for level in [16]:
        folder_name = "p414_original_univmon_simple_row_%02d_level_%02d" % (row, level)
        print(folder_name)
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)
        f = open(os.path.join(folder_name, folder_name+".p4"), "w+")
        f.write('\
#include "../common_library/defines.p4"\n\
#include "../common_library/headers.p4"\n\
#include "../common_library/parsers.p4"\n\
\n\
control ingress {\n\
    start();\n\
}\n\
\n\
control egress {\n\
}\n\
\n\
#define CS_HASH_WIDTH 11\n\
#define COL_SIZE 2048\n\
\n\
#include "../library/0_hash_params.p4"\n\
#include "../library/1_metadata.p4"\n\
#include "../library/2_compute_hash.p4"\n\
#include "../library/3_sketching.p4"\n\
#include "../library/4_logging.p4"\n\
metadata original_md_t md;\n\
\n\
field_list key_fields {\n\
    ipv4.srcAddr;\n\
}\n\
\n')
        f.write('\
#define DIM_SETUP(D) \\\n\
    ORIGINAL_METADATA_STAGE(D) \\\n\
    COMPUTE_SAMPLING(D) \\\n\
    COMPUTE_RES_%d(D) \\\n\
    SKETCHING_STAGE_%d(D)\n' % (row, row))
        f.write('\n')

        for k in range(1, level+1):
            f.write('DIM_SETUP(%d)\n' % k)
        f.write('\n')

        f.write('#define RES_SETUP(D) \\\n')
        for k in range(1, row):
            f.write('\tapply(res_##D##_%d_table); \\\n' % k)
        f.write('\tapply(res_##D##_%d_table);\n\n' % row)

        f.write('#define SKETCHING(D) \\\n')
        for k in range(1, row):
            f.write('\tapply(sketching_##D##_%d_table); \\\n' % k)
        f.write('\tapply(sketching_##D##_%d_table);\n\n' % row)

        f.write('control start {\n')
        f.write('\n')

        for k in range(1, level+1):
            f.write('\tRES_SETUP(%d)\n' % k)
        f.write('\n')
        
        f.write('\tSKETCHING(1)\n')

        # for k in range(1, row+1):
        #     f.write('\tif (md.est_%d > HH_THRESHOLD) {\n' % k)
        # f.write('\t\tapply(above_threshold_table_1);\n')
        # for k in range(1, row+1):
        #     f.write('\t}\n')

        f.write('\tapply(sampling_1_table);\n');

        for k in range(2, level+1):
            print_tab(f, k-1)
            f.write('if (md_%d.sampling == 1) {\n' % (k-1))

            print_tab(f, k)
            f.write('SKETCHING(%d)\n' % k)
            # for l in range(1, row+1):
            #     print_tab(f, k)
            #     f.write('if (md_%d.est_%d > HH_THRESHOLD) {\n' % (k, l))
            # print_tab(f, k)
            # f.write('\tapply(above_threshold_table_%d);\n' % k)
            # for l in range(1, row+1):
            #     print_tab(f, k)
            #     f.write('}\n')
            print_tab(f, k)
            f.write('apply(sampling_%d_table);\n' % k)

        for j in reversed(range(1, level)):
            print_tab(f, j)
            f.write('}\n')

        # for k in range(1, level+1):
        #     for l in range(1, row+1):
        #         f.write('\tif (md_%d.est_%d > HH_THRESHOLD) {\n' % (k, l))
        # f.write('\
        # apply(minus_table);\n\
        # if(md.a == 0) {\n\
        #     apply(shift_table);\n\
        #     if(md.b == 0) {\n\
        #         apply(sum_table);\n\
        #         if(md.c == 0) {\n\
        #             apply(hh_bf_1);\n\
        #             if (md.bf == 0) {\n\
        #                 apply(clone_to_controller);\n\
        #             }\n\
        #         }\n\
        #     }\n\
        # }\n')
        # # f.write('\t\tapply(above_threshold_table_%d);\n' % k)
        # for k in range(1, level+1):
        #     for l in range(1, row+1):
        #         f.write('\t}\n')

    #     f.write('\
    # if (md.above_threshold == 1) {\n\
    #     apply(hh_bf_1);\n\
    #     if (md.bf == 0) {\n\
    #         apply(clone_to_controller);\n\
    #     }\n\
    # }\n')

        for j in reversed(range(0, 1)):
            print_tab(f, j)
            f.write('}\n')

