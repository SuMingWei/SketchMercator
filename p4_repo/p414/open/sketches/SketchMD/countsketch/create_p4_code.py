import os

# def print_tab(f, j):
#     for k in range(1, j+1):
#         f.write('\t')

for row, bit, width in zip([3, 5], [13, 14], [8192, 16384]):
    for instance in range(1, 10):
        p4_file_name = "opt_countsketch_row_%d_width_%d_instance_%d.p4" % (row, width, instance)
        print(p4_file_name)
        f = open(p4_file_name, "w+")
        f.write('\
#include "common_library/defines.p4"\n\
#include "common_library/headers.p4"\n\
#include "common_library/parsers.p4"\n\
control ingress {\n\
    start();\n\
}\n\
control egress {\n\
}\n\
')
        f.write('\
#define CS_HASH_WIDTH %d\n\
#define COL_SIZE %d\n\
' % (bit, width))
        f.write('\
#include "library/0_hash_params.p4"\n\
#include "library/1_metadata.p4"\n\
#include "library/2_compute_hash.p4"\n\
#include "library/3_sketching.p4"\n\
#include "API/API_hash.p4"\n\
#include "API/API_flowkey.p4"\n\
field_list key_fields {\n\
    ipv4.srcAddr;\n\
}\n\
#define DIM_SETUP(D) \\ \n\
    METADATA_STAGE(D) \\ \n\
    SKETCHING_STAGE_5(D) \\ \n\
    hash_consolidate_and_split_5_init(cs_##D, key_fields, 0x149cf87##D##1, md_##D.temp, 32, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, 1, 1, 1, 1, 1, 2, 3, 4) \\ \n\
    heavy_flowkey_storage_step1_5_init(th_##D, md_##D.est_1, md_##D.est_2, md_##D.est_3, md_##D.est_4, md_##D.est_5, md_##D.comp_1, md_##D.comp_2, md_##D.comp_3, md_##D.comp_4, md_##D.comp_5, md_##D.threshold) \\ \n\
    heavy_flowkey_storage_step2_5_init(sum_##D, md_##D.comp_1, md_##D.comp_2, md_##D.comp_3, md_##D.comp_4, md_##D.comp_5, md_##D.above_threshold, key_fields, ipv4.srcAddr, 0x11ba201##D##1, 65536, md_##D.hash_entry, md_##D.match_hit) \n\
\n\
DIM_SETUP(1)\n\
DIM_SETUP(2)\n\
DIM_SETUP(3)\n\
DIM_SETUP(4)\n\
DIM_SETUP(5)\n\
DIM_SETUP(6)\n\
DIM_SETUP(7)\n\
DIM_SETUP(8)\n\
DIM_SETUP(9)\n\
\n\
#define SKETCHING(D) \\ \n\
')
        for r in range(1, row+1):
            f.write('\
	apply(sketching_##D##_%d_table); \\ \n' % r)

        f.write('\
\n\
#define MAIN(D) \\ \n\
    hash_consolidate_and_split_5_call(cs_##D) \\ \n\
	SKETCHING(D) \\ \n\
    heavy_flowkey_storage_step1_5_call(th_##D) \\ \n\
    heavy_flowkey_storage_step2_5_call(sum_##D, md_##D.above_threshold, md_##D.hash_entry, ipv4.srcAddr) \n\
\n\
control start {\n\
')
        for i in range(1, instance+1):
            f.write('\
	MAIN(%d) \n' % i)
        f.write('}\n')
