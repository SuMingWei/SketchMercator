#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>

#define DDOS_TEST_PORT 0x00
#define DDOS_OUT_PORT 0x01

#include "defines.p4"
#include "headers.p4"
#include "parsers.p4"
#include "route.p4"

#define CS_HASH_WIDTH 11
#define COL_SIZE 2048

#include "1_metadata.p4"
#include "API_hash.p4"
#include "API_salu.p4"
#include "API_tcam.p4"
#include "API_flowkey.p4"

field_list key_fields_1 {
    ipv4.srcAddr;
}

field_list key_fields_2 {
    ipv4.dstAddr;
}

field_list key_fields_3 {
    ipv4.protocol;
}

field_list key_fields_4 {
    ipv4.ttl;
}

#define UNIVMON_INIT(D) \
    hash_init(sampling_##D, key_fields_##D, 0x1##D##98f10d1, md_##D.sampling_hash_value, 65536) \
    lpm_optimization_init(logarithmic_##D, md_##D.sampling_hash_value, D) \
    hash_consolidate_and_split_5_init(cs_res_group_##D, key_fields_##D, 0x1##D##9cf8781, md_##D.temp1, 32, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, 1, 1, 1, 1, 1, 2, 3, 4) \
    hash_init(cs_index_1_##D, key_fields_##D, 0x1##D##9cf8783, md_##D.index_1, 2048) \
    hash_init(cs_index_2_##D, key_fields_##D, 0x1##D##9cf8785, md_##D.index_2, 2048) \
    hash_init(cs_index_3_##D, key_fields_##D, 0x1##D##9cf8787, md_##D.index_3, 2048) \
    hash_init(cs_index_4_##D, key_fields_##D, 0x1##D##9cf8789, md_##D.index_4, 2048) \
    hash_init(cs_index_5_##D, key_fields_##D, 0x1##D##9cf878b, md_##D.index_5, 2048) \
    consolidate_update_cs_5_init(cs_row_1_##D, md_##D.base, md_##D.index_1, md_##D.res_1, md_##D.est_1, 32768) \
    consolidate_update_cs_5_init(cs_row_2_##D, md_##D.base, md_##D.index_2, md_##D.res_2, md_##D.est_2, 32768) \
    consolidate_update_cs_5_init(cs_row_3_##D, md_##D.base, md_##D.index_3, md_##D.res_3, md_##D.est_3, 32768) \
    consolidate_update_cs_5_init(cs_row_4_##D, md_##D.base, md_##D.index_4, md_##D.res_4, md_##D.est_4, 32768) \
    consolidate_update_cs_5_init(cs_row_5_##D, md_##D.base, md_##D.index_5, md_##D.res_5, md_##D.est_5, 32768) \
    heavy_flowkey_storage_step1_5_init(univmon_th_##D, md_##D.est_1, md_##D.est_2, md_##D.est_3, md_##D.est_4, md_##D.est_5, md_##D.comp_1, md_##D.comp_2, md_##D.comp_3, md_##D.comp_4, md_##D.comp_5, md_##D.threshold) \
    heavy_flowkey_storage_step2_5_init(univmon_sum_##D, md_##D.comp_1, md_##D.comp_2, md_##D.comp_3, md_##D.comp_4, md_##D.comp_5, md_##D.above_threshold, key_fields_##D, ipv4.srcAddr, 0x11ba201b1, 10000, md_##D.hash_entry, md_##D.match_hit)

METADATA_STAGE(1)
METADATA_STAGE(2)

UNIVMON_INIT(1)
UNIVMON_INIT(2)


control ingress {
    hash_call(sampling_1)
    lpm_optimization_call(logarithmic_1)

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

    heavy_flowkey_storage_step1_5_call(univmon_th_1)
    heavy_flowkey_storage_step2_5_call(univmon_sum_1, md_1.above_threshold, md_1.hash_entry, ipv4.srcAddr)


    hash_call(sampling_2)
    lpm_optimization_call(logarithmic_2)

    hash_consolidate_and_split_5_call(cs_res_group_2)
    hash_call(cs_index_1_2)
    hash_call(cs_index_2_2)
    hash_call(cs_index_3_2)
    hash_call(cs_index_4_2)
    hash_call(cs_index_5_2)

    consolidate_update_cs_5_call(cs_row_1_2)
    consolidate_update_cs_5_call(cs_row_2_2)
    consolidate_update_cs_5_call(cs_row_3_2)
    consolidate_update_cs_5_call(cs_row_4_2)
    consolidate_update_cs_5_call(cs_row_5_2)

    heavy_flowkey_storage_step1_5_call(univmon_th_2)
    heavy_flowkey_storage_step2_5_call(univmon_sum_2, md_2.above_threshold, md_2.hash_entry, ipv4.srcAddr)
}

control egress {
}
