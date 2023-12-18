#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>


#include "headers.p4"
#include "parsers.p4"

control ingress {
	count_sketch();
}

control egress {
}


#define CS_HASH_WIDTH 11
#define COL_SIZE 2048

#include "API_O1_hash.p4"
#include "API_O6_flowkey.p4"
#include "API_threshold.p4"

header_type md_t {
    fields {
        temp:5;
        res_1: 1;
        res_2: 1;
        res_3: 1;
        res_4: 1;
        res_5: 1;
        index_1: 16;
        index_2: 16;
        index_3: 16;
        index_4: 16;
        index_5: 16;
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

field_list key_fields {
    ipv4.srcAddr;
}

#define ROW_SKETCH(R) \
    register  register_##R { \
        width: 32; \
        instance_count: COL_SIZE; \
    } \
    blackbox stateful_alu blackbox_##R { \
        reg: register_##R; \
        condition_lo: md.res_##R > 0; \
        update_lo_1_predicate: condition_lo; \
        update_lo_1_value    : register_lo + 1;  \
        update_lo_2_predicate: not condition_lo; \
        update_lo_2_value    : register_lo - 1;  \
        condition_hi: md.res_##R > 0;  \
        update_hi_1_predicate: condition_hi;  \
        update_hi_1_value    : 1+register_lo; \
        update_hi_2_predicate: not condition_hi; \
        update_hi_2_value    : ~register_lo; \
        output_value: alu_hi; \
        output_dst: md.est_##R; \
    } \
    table sketching_##R##_table { \
        actions { \
            sketching_##R##_act; \
        } \
        default_action: sketching_##R##_act; \
    } \
    action sketching_##R##_act () { \
        blackbox_##R.execute_stateful_alu_from_hash(cs_index_hash_func_##R); \
    }

#define SKETCHING_STAGE_5() \
    ROW_SKETCH(1) \
    ROW_SKETCH(2) \
    ROW_SKETCH(3) \
    ROW_SKETCH(4) \
    ROW_SKETCH(5)

field_list_calculation cs_index_hash_func_1 {
    input {
        key_fields;
    }
    algorithm : poly_0x30243f0b_init_0x00000000_xout_0ffffffff;
    output_width : CS_HASH_WIDTH;
}

field_list_calculation cs_index_hash_func_2 {
    input {
        key_fields;
    }
    algorithm : poly_0x0f79f523_init_0x00000000_xout_0ffffffff;
    output_width : CS_HASH_WIDTH;
}

field_list_calculation cs_index_hash_func_3 {
    input {
        key_fields;
    }
    algorithm : poly_0x6b8cb0c5_init_0x00000000_xout_0ffffffff;
    output_width : CS_HASH_WIDTH;
}

field_list_calculation cs_index_hash_func_4 {
    input {
        key_fields;
    }
    algorithm : poly_0x00390fc3_init_0x00000000_xout_0ffffffff;
    output_width : CS_HASH_WIDTH;
}

field_list_calculation cs_index_hash_func_5 {
    input {
        key_fields;
    }
    algorithm : poly_0x298ac673_init_0x00000000_xout_0ffffffff;
    output_width : CS_HASH_WIDTH;
}


TH_TABLE()
SKETCHING_STAGE_5()
hash_consolidate_and_split_5_init(cs, key_fields, 0x5b445b31, md.temp, 32, md.res_1, md.res_2, md.res_3, md.res_4, md.res_5, 1, 1, 1, 1, 1, 2, 3, 4)
heavy_flowkey_storage_step1_5_init(th, md.est_1, md.est_2, md.est_3, md.est_4, md.est_5, md.res_1, md.res_2, md.res_3, md.res_4, md.res_5, md.threshold)
heavy_flowkey_storage_step2_5_init(sum, md.res_1, md.res_2, md.res_3, md.res_4, md.res_5, md.above_threshold, key_fields, ipv4.srcAddr, 0x5b445b31, 16384, md.hash_entry, md.match_hit)

control count_sketch {
    apply(th_table);
    hash_consolidate_and_split_5_call(cs)

    apply(sketching_1_table);
    apply(sketching_2_table);
    apply(sketching_3_table);
    apply(sketching_4_table);
    apply(sketching_5_table);

    heavy_flowkey_storage_step1_5_call(th)
    heavy_flowkey_storage_step2_5_call(sum, md.above_threshold, md.hash_entry, ipv4.srcAddr)
}
