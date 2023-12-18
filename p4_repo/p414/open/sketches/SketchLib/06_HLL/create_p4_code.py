import os


def print_tab(f, j):
    for k in range(1, j+1):
        f.write('\t')

for i in range(1, 21):
    folder_name = "p414_original_hll_level_%02d" % i
    print(folder_name)
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    # cmd = 'cp original/main.p4 %s/main.p4' % (folder_name)
    # os.system(cmd)

    f = open(os.path.join(folder_name, folder_name+".p4"), "w+")
    f.write('\
#include "../common_library/defines.p4"\n\
#include "../common_library/headers.p4"\n\
#include "../common_library/parsers.p4"\n\
\n\
control ingress {\n\
    sketch();\n\
}\n\
\n\
control egress {\n\
}\n\
#define COL_SIZE 2048 \n\
#include "../library/1_metadata.p4" \n\
#include "../library/2_set_level.p4" \n\
#include "../library/3_mem_update.p4" \n\
#include "../apis/API0.p4" \n\
field_list key_fields { \n\
    ipv4.srcAddr; \n\
} \n\
ORIGINAL_METADATA_STAGE(1)\n\
ROW_SKETCH(1)\n\n')
    for j in range(1, i+1):
        f.write('API0_HASH_INIT(hll_h%d, key_fields, 0x1798f10%x1, md_1.h%d, 2)\n' % (j, j, j))
    f.write('\n')

    for j in range(1, i+1):
        f.write('SET_LEVEL(1, %d)\n' % j)
    f.write('\n')

    f.write('control sketch {\n')


    if i == 1:
        # f.write('\t')
        # f.write('API0_HASH_CALL(hll_h%d)\n' % i)
        f.write('\t')
        f.write('apply(set_level_1_1_table);\n')
    else :
        for j in range(1, i):
            print_tab(f, j)
            f.write('API0_HASH_CALL(hll_h%d)\n' % j)
            f.write('\n')

            print_tab(f, j)
            f.write('if (md_1.h%d == 0) {\n' % j)

            print_tab(f, j)
            f.write('\t')
            f.write('apply(set_level_1_%d_table);\n' % j)

            print_tab(f, j)
            f.write('}\n\n')

            print_tab(f, j)
            f.write('if (md_1.h%d == 1) {\n' % j)

        print_tab(f, j)
        f.write('\t')
        f.write('apply(set_level_1_%d_table);\n' % (j+1))

        # print_tab(f, j)
        # f.write('\t')
        # f.write('API0_HASH_CALL(hll_h%d)\n' % (j+1))

        for j in reversed(range(1, i)):
            print_tab(f, j)
            f.write('}\n')


    f.write('\tapply(sketching_1_table);\n')
    f.write('}\n')
