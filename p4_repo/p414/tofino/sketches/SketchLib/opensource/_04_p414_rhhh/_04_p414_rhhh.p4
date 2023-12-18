#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>

#define DDOS_TEST_PORT 0x00
#define DDOS_OUT_PORT 0x01

#include "../common_library/defines.p4"
#include "../common_library/headers.p4"
#include "../common_library/parsers.p4"
#include "../common_library/route.p4"

control ingress {
	rhhh();
}

control egress {
}


#define CS_HASH_WIDTH 11
#define COL_SIZE 2048

#include "library/1_metadata.p4"
#include "../API/API_hash.p4"
#include "../API/API_salu.p4"
#include "../API/API_tcam.p4"
#include "../API/API_flowkey.p4"

METADATA_STAGE(1)

field_list key_fields {
    md_1.src_key;
    md_1.dst_key;
}

table compute_level_table {
    actions {
        compute_level_act;
    }
    default_action: compute_level_act;
}
action compute_level_act () {
    modify_field_rng_uniform(md_1.level, 0, 31);
}


#define RHHH_INIT(D) \
    select_key_init(rhhh, md_1.level, md_1.base, md_1.threshold, 1) \
    hash_init(cs_index_1_##D, key_fields, 0x1##D##9cf8781, md_##D.index_1, 2048) \
    hash_init(cs_index_2_##D, key_fields, 0x1##D##9cf8783, md_##D.index_2, 2048) \
    hash_init(cs_index_3_##D, key_fields, 0x1##D##9cf8785, md_##D.index_3, 2048) \
    hash_init(cs_index_4_##D, key_fields, 0x1##D##9cf8787, md_##D.index_4, 2048) \
    hash_init(cs_index_5_##D, key_fields, 0x1##D##9cf8789, md_##D.index_5, 2048) \
    hash_consolidate_and_split_5_init(cs_res_group_##D, key_fields, 0x1##D##9cf8781, md_##D.temp1, 32, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, 1, 1, 1, 1, 1, 2, 3, 4) \
    consolidate_update_cs_5_init(cs_row_1_##D, md_##D.base, md_##D.index_1, md_##D.res_1, md_##D.est_1, 51200) \
    consolidate_update_cs_5_init(cs_row_2_##D, md_##D.base, md_##D.index_2, md_##D.res_2, md_##D.est_2, 51200) \
    consolidate_update_cs_5_init(cs_row_3_##D, md_##D.base, md_##D.index_3, md_##D.res_3, md_##D.est_3, 51200) \
    consolidate_update_cs_5_init(cs_row_4_##D, md_##D.base, md_##D.index_4, md_##D.res_4, md_##D.est_4, 51200) \
    consolidate_update_cs_5_init(cs_row_5_##D, md_##D.base, md_##D.index_5, md_##D.res_5, md_##D.est_5, 51200) \
    heavy_flowkey_storage_step1_5_init(th_##D, md_##D.est_1, md_##D.est_2, md_##D.est_3, md_##D.est_4, md_##D.est_5, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, md_##D.threshold) \
    heavy_flowkey_storage_step2_5_init(sum_##D, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, md_##D.above_threshold, key_fields, ipv4.srcAddr, 0x11ba201b1, 16384, md_##D.hash_entry, md_##D.match_hit)

RHHH_INIT(1)

control rhhh {
    apply(compute_level_table);
    select_key_call(rhhh)

    hash_consolidate_and_split_5_call(cs_res_group_1)
    hash_call(cs_index_1_1)
    hash_call(cs_index_2_1)
    hash_call(cs_index_3_1)
    hash_call(cs_index_4_1)
    hash_call(cs_index_5_1)
    consolidate_update_cs_5_call(cs_row_1_1)
    consolidate_update_cs_5_call(cs_row_2_1)
    consolidate_update_cs_5_call(cs_row_3_1)
    consolidate_update_cs_5_call(cs_row_4_1)
    consolidate_update_cs_5_call(cs_row_5_1)

    heavy_flowkey_storage_step1_5_call(th_1)
    heavy_flowkey_storage_step2_5_call(sum_1, md_1.above_threshold, md_1.hash_entry, ipv4.srcAddr)
}
