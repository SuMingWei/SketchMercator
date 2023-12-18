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

control ingress {
	count_sketch();
}

control egress {
}


#define CS_HASH_WIDTH 11
#define COL_SIZE 2048
#define LOG_SIZE 143360

#include "0_cs_hash_params.p4"
#include "1_metadata.p4"
#include "2_compute_hash.p4"
#include "3_sketching.p4"

#include "API_flowkey.p4"
#include "API_hash.p4"

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

field_list key_fields_5 {
    ipv4.version;
}

field_list key_fields_6 {
    ipv4.diffserv;
}

field_list key_fields_7 {
    ipv4.ihl;
}

#define TH_TABLE(D) \
    action th_table_##D##_act (threshold) { \
        modify_field(md_##D.threshold, threshold); \
    } \
    table th_table_##D { \
        actions { \
            th_table_##D##_act; \
        } \
    }

#define DIM_SETUP_5(D) \
    TH_TABLE(D) \
    METADATA_STAGE(D) \
    SKETCHING_STAGE_5(D) \
    hash_consolidate_and_split_5_init(cs_##D, key_fields_##D, 0x149cf87##D##1, md_##D.temp, 32, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, 1, 1, 1, 1, 1, 2, 3, 4) \
    heavy_flowkey_storage_step1_5_init(th_##D, md_##D.est_1, md_##D.est_2, md_##D.est_3, md_##D.est_4, md_##D.est_5, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, md_##D.threshold) \
    heavy_flowkey_storage_step2_5_init(sum_##D, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, md_##D.above_threshold, key_fields_##D, ipv4.srcAddr, 0x11ba201##D##1, 16384, md_##D.hash_entry, md_##D.match_hit)

#define HASH_SKETCHING_5(D) \
    apply(sketching_##D##_1_table); \
    apply(sketching_##D##_2_table); \
    apply(sketching_##D##_3_table); \
    apply(sketching_##D##_4_table); \
    apply(sketching_##D##_5_table);

DIM_SETUP_5(1)
DIM_SETUP_5(2)
DIM_SETUP_5(3)

control count_sketch {
    apply(th_table_1);
    hash_consolidate_and_split_5_call(cs_1)
    HASH_SKETCHING_5(1)
    heavy_flowkey_storage_step1_5_call(th_1)
    heavy_flowkey_storage_step2_5_call(sum_1, md_1.above_threshold, md_1.hash_entry, ipv4.srcAddr)

    apply(th_table_2);
    hash_consolidate_and_split_5_call(cs_2)
    HASH_SKETCHING_5(2)
    heavy_flowkey_storage_step1_5_call(th_2)
    heavy_flowkey_storage_step2_5_call(sum_2, md_2.above_threshold, md_2.hash_entry, ipv4.srcAddr)

    apply(th_table_3);
    hash_consolidate_and_split_5_call(cs_3)
    HASH_SKETCHING_5(3)
    heavy_flowkey_storage_step1_5_call(th_3)
    heavy_flowkey_storage_step2_5_call(sum_3, md_3.above_threshold, md_3.hash_entry, ipv4.srcAddr)
}
