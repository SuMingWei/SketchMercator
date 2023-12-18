#include "common_library/defines.p4"
#include "common_library/headers.p4"
#include "common_library/parsers.p4"
control ingress {
    start();
}
control egress {
}
#define CS_HASH_WIDTH 14
#define COL_SIZE 16384
#include "library/0_hash_params.p4"
#include "library/1_metadata.p4"
#include "library/2_compute_hash.p4"
#include "library/3_sketching.p4"
#include "API/API_hash.p4"
#include "API/API_flowkey.p4"
field_list key_fields {
    ipv4.srcAddr;
}
#define DIM_SETUP(D) \ 
    METADATA_STAGE(D) \ 
    SKETCHING_STAGE_5(D) \ 
    hash_consolidate_and_split_5_init(cs_##D, key_fields, 0x149cf87##D##1, md_##D.temp, 32, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, 1, 1, 1, 1, 1, 2, 3, 4) \ 
    heavy_flowkey_storage_step1_5_init(th_##D, md_##D.est_1, md_##D.est_2, md_##D.est_3, md_##D.est_4, md_##D.est_5, md_##D.comp_1, md_##D.comp_2, md_##D.comp_3, md_##D.comp_4, md_##D.comp_5, md_##D.threshold) \ 
    heavy_flowkey_storage_step2_5_init(sum_##D, md_##D.comp_1, md_##D.comp_2, md_##D.comp_3, md_##D.comp_4, md_##D.comp_5, md_##D.above_threshold, key_fields, ipv4.srcAddr, 0x11ba201##D##1, 65536, md_##D.hash_entry, md_##D.match_hit) 

DIM_SETUP(1)
DIM_SETUP(2)
DIM_SETUP(3)
DIM_SETUP(4)
DIM_SETUP(5)
DIM_SETUP(6)
DIM_SETUP(7)
DIM_SETUP(8)
DIM_SETUP(9)

#define SKETCHING(D) \ 
	apply(sketching_##D##_1_table); \ 
	apply(sketching_##D##_2_table); \ 
	apply(sketching_##D##_3_table); \ 
	apply(sketching_##D##_4_table); \ 
	apply(sketching_##D##_5_table); \ 

#define MAIN(D) \ 
    hash_consolidate_and_split_5_call(cs_##D) \ 
	SKETCHING(D) \ 
    heavy_flowkey_storage_step1_5_call(th_##D) \ 
    heavy_flowkey_storage_step2_5_call(sum_##D, md_##D.above_threshold, md_##D.hash_entry, ipv4.srcAddr) 

control start {
	MAIN(1) 
}
