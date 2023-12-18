#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>

#include "headers.p4"
#include "parsers.p4"

#include "API_common.p4"
#include "API_threshold.p4"

control ingress {
    count_sketch();
}

control egress {
}


field_list key_fields {
    ipv4.srcAddr;
}

header_type md_t {
    fields {
        est_1: 32;
        est_2: 32;
        est_3: 32;
        est_4: 32;
        est_5: 32;
        threshold: 16;
        above_threshold: 1;
        hash_entry: 32;
        hash_hit: 1;
        match_hit: 1;
    }
}
metadata md_t md;

// #define DIM_SETUP_5(D) \
//     TH_TABLE(D) \
//     METADATA_STAGE(D) \
//     SKETCHING_STAGE_5(D) \
//     hash_consolidate_and_split_5_init(cs_##D, key_fields, 0x149cf87##D##1, md_##D.temp, 32, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, 1, 1, 1, 1, 1, 2, 3, 4) \
//     heavy_flowkey_storage_step1_5_init(th_##D, md_##D.est_1, md_##D.est_2, md_##D.est_3, md_##D.est_4, md_##D.est_5, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, md_##D.threshold) \
//     heavy_flowkey_storage_step2_5_init(sum_##D, md_##D.res_1, md_##D.res_2, md_##D.res_3, md_##D.res_4, md_##D.res_5, md_##D.above_threshold, key_fields, ipv4.srcAddr, 0x11ba201##D##1, 16384, md_##D.hash_entry, md_##D.match_hit)

// DIM_SETUP_5(1)

TH_TABLE()

control count_sketch {

    apply(th_table);

    // apply(sketching_1_table);
    // apply(sketching_2_table);
    // apply(sketching_3_table);
    // apply(sketching_4_table);
    // apply(sketching_5_table);

    // heavy_flowkey_storage_step1_5_call(th_1)
    // heavy_flowkey_storage_step2_5_call(sum_1, md_1.above_threshold, md_1.hash_entry, ipv4.srcAddr)
}
