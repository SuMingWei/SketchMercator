import os


def print_tab(f, j):
    for k in range(1, j+1):
        f.write('\t')

# for i in range(1, 21):
for i in [32]:
    folder_name = "p414_original_pcsa_level_%02d" % i
    print(folder_name)
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    # cmd = 'cp original/original_pcsa_level_X.p4 %s/%s.p4' % (folder_name, folder_name)
    # os.system(cmd)

    f = open(os.path.join(folder_name, folder_name+".p4"), "w+")
    f.write('\
#include "../common_library/defines.p4"\n\
#include "../common_library/headers.p4"\n\
#include "../common_library/parsers.p4"\n\
\n\
control ingress {\n\
    pcsa();\n\
}\n\
\n\
control egress {\n\
}\n\
#define COL_SIZE 32 \n\
#include "../library/1_metadata.p4" \n\
#include "../library/2_set_level.p4" \n\
#include "../library/3_mem_update.p4" \n\
#include "../apis/API0.p4" \n\
field_list key_fields { \n\
    ipv4.srcAddr; \n\
} \n\
ORIGINAL_METADATA_STAGE(1)\n\n\
API0_HASH_INIT(pcsa_alpha, key_fields, 0x1798f10d3, md_1.alpha, 256)\n \
\n\n')
    for j in range(1, 21):
        f.write('API0_HASH_INIT(hll_h%d, key_fields, 0x1798f10%x1, md_1.h%d, 2)\n' % (j, j, j))
    f.write('\n')

    for j in range(1, 21):
        f.write('SET_LEVEL(1, %d)\n' % j)
    f.write('\n')

    for j in range(1, i+1):
        f.write('ROW_SKETCH(1, %d)\n' % j)
    f.write('\n')

    f.write('control pcsa {\n')
    f.write('\t')
    f.write('API0_HASH_CALL(pcsa_alpha)\n\n')


    for j in range(1, 20):
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

    for j in reversed(range(1, 20)):
        print_tab(f, j)
        f.write('}\n')


    f.write('\n')
    for j in range(1, i+1):
        f.write('\tif(md_1.alpha == %d) {\n' % j)
        f.write('\t\tapply(sketching_1_%d_table);\n' % j)
        f.write('\t}\n')
    f.write("}")
