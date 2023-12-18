// #define ROW_COMPARE(NAME, LEVEL, EST, i) \
//     table NAME##_compare_table_##i { \
//         reads { \
//             LEVEL: exact; \
//             EST: range; \
//         } \
//         actions { \
//             NAME##_compare_table_##i##_act_miss; \
//             NAME##_compare_table_##i##_act_hit; \
//         } \
//         default_action: NAME##_compare_table_##i##_act_miss; \
//     } \
//     action NAME##_compare_table_##i##_act_miss () { \
//         modify_field(md.compare_##i, 0); \
//     } \
//     action NAME##_compare_table_##i##_act_hit () { \
//         modify_field(md.compare_##i, 1); \
//     }


// #define THRESHOLD_STAGE_5(NAME, LEVEL, E1, E2, E3, E4, E5) \
//     ROW_COMPARE(NAME, LEVEL, E1, 0) \
//     ROW_COMPARE(NAME, LEVEL, E2, 1) \
//     ROW_COMPARE(NAME, LEVEL, E3, 2) \
//     ROW_COMPARE(NAME, LEVEL, E4, 3) \
//     ROW_COMPARE(NAME, LEVEL, E5, 4)


// #define ROW_COMPARE(NAME, i) \
//     table NAME##_compare_table_##i { \
//         actions { \
//             NAME##_compare_table_##i##_act; \
//         } \
//         default_action: NAME##_compare_table_##i##_act; \
//     } \
//     action NAME##_compare_table_##i##_act () { \
//         modify_field(md.compare_##i, 1); \
//     }

// #define THRESHOLD_STAGE_5(NAME) \
//     ROW_COMPARE(NAME, 0) \
//     ROW_COMPARE(NAME, 1) \
//     ROW_COMPARE(NAME, 2) \
//     ROW_COMPARE(NAME, 3) \
//     ROW_COMPARE(NAME, 4)
// #define ROW_COMPARE(NAME, i) \
//     table NAME##_compare_table_##i { \
//         actions { \
//             NAME##_compare_table_##i##_act; \
//         } \
//         default_action: NAME##_compare_table_##i##_act; \
//     } \
//     action NAME##_compare_table_##i##_act () { \
//         modify_field(md.compare_##i, 1); \
//     }

// #define THRESHOLD_STAGE_5(NAME) \
//     ROW_COMPARE(NAME, 0) \
//     ROW_COMPARE(NAME, 1) \
//     ROW_COMPARE(NAME, 2) \
//     ROW_COMPARE(NAME, 3) \
//     ROW_COMPARE(NAME, 4)



    // table hh_threshold_tcam_table { \
    //     reads { \
    //         md.compare_0: exact; \
    //         md.compare_1: exact; \
    //         md.compare_2: exact; \
    //         md.compare_3: exact; \
    //         md.compare_4: exact; \
    //     } \
    //     actions { \
    //         hh_threshold_tcam_miss; \
    //         hh_threshold_tcam_hit; \
    //     } \
    //     default_action: hh_threshold_tcam_hit; \
    // } \
    // action hh_threshold_tcam_miss() { \
    //     modify_field(md.threshold_hit, 0); \
    // }
    // action hh_threshold_tcam_hit() { \
    //     modify_field(md.threshold_hit, 1); \
    //     update_sketch_##i##_##j.execute_stateful_alu_from_hash(index_hash_##i##_##j); \
    // }
    // register  reg_##i##_##j { \
    //     width: 32; \
    //     instance_count: COL_SIZE; \
    // } \
    // blackbox stateful_alu update_sketch_##i##_##j { \
    //     reg: reg_##i##_##j; \
    //     condition_lo: md_##i.res_##j > 0; \
    //     update_lo_1_predicate: condition_lo;     /* if   */ \
    //     update_lo_1_value    : register_lo + 1; \
    //     update_lo_2_predicate: not condition_lo; /* else */ \
    //     update_lo_2_value    : register_lo - 1; \
    //     output_value: alu_lo; \
    //     output_dst: md_##i.count_##j; \
    // }



    // if(E1 > 10) { \
    //     apply(NAME##_compare_table_0); \
    // } \
    // if(E2 > 10) { \
    //     apply(NAME##_compare_table_1); \
    // } \
    // if(E3 > THRESHOLD) { \
    //     apply(NAME##_compare_table_2); \
    // } \
    // if(E4 > 10) { \
    //     apply(NAME##_compare_table_3); \
    // } \
    // if(E5 > 10) { \
    //     apply(NAME##_compare_table_4); \
    // }
	// apply(NAME##_logarithmic_hash_table); \
 //    if (univmon_md.threshold_hit_or_miss == 1 && md.hash_table_miss) {
 //        apply(hh_dup_filter_table);
 //    }





// #define ROW_COMPARE(NAME, EST, i) \
//     table NAME##_compare_table_##i { \
//         reads { \
//             EST: lpm; \
//         } \
//         actions { \
//             NAME##_compare_table_##i##_act_miss; \
//             NAME##_compare_table_##i##_act_hit; \
//         } \
//         default_action: NAME##_compare_table_##i##_act_miss; \
//     } \
//     action NAME##_compare_table_##i##_act_miss () { \
//         modify_field(md.compare_##i, 0); \
//     } \
//     action NAME##_compare_table_##i##_act_hit () { \
//         modify_field(md.compare_##i, 1); \
//     }


// #define SUBTRACT_STAGE_5(NAME, E1, E2, E3, E4, E5, THRESHOLD) \
//     ROW_SUBTRACT(NAME, E1, THRESHOLD, 0) \
//     ROW_SUBTRACT(NAME, E2, THRESHOLD, 1) \
//     ROW_SUBTRACT(NAME, E3, THRESHOLD, 2) \
//     ROW_SUBTRACT(NAME, E4, THRESHOLD, 3) \
//     ROW_SUBTRACT(NAME, E5, THRESHOLD, 4)


// #define COMPARE_STAGE_5(NAME, E1, E2, E3, E4, E5) \
//     ROW_COMPARE(NAME, E1, 0) \
//     ROW_COMPARE(NAME, E2, 1) \
//     ROW_COMPARE(NAME, E3, 2) \
//     ROW_COMPARE(NAME, E4, 3) \
//     ROW_COMPARE(NAME, E5, 4)


// #define API6_FLOWKEY_STORAGE_5_INIT(NAME, E1, E2, E3, E4, E5, THRESHOLD) \
//     SUBTRACT_STAGE_5(NAME, E1, E2, E3, E4, E5, THRESHOLD) \
//     COMPARE_STAGE_5(NAME, E1, E2, E3, E4, E5)


// #define API6_FLOWKEY_STORAGE_5_CALL(NAME) \
//     apply(NAME##_subtract_table_0); \
//     apply(NAME##_subtract_table_1); \
//     apply(NAME##_subtract_table_2); \
//     apply(NAME##_subtract_table_3); \
//     apply(NAME##_subtract_table_4);

