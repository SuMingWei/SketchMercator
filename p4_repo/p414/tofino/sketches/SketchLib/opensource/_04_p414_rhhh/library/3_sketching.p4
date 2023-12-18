#define ROW_SKETCH(D, R) \
    register  register_##D##_##R { \
        width: 32; \
        instance_count: COL_SIZE; \
    } \
    blackbox stateful_alu blackbox_##D##_##R { \
        reg: register_##D##_##R; \
        condition_lo: md_##D.res_##R > 0; \
        update_lo_1_predicate: condition_lo; \
        update_lo_1_value    : register_lo + 1;  \
        update_lo_2_predicate: not condition_lo; \
        update_lo_2_value    : register_lo - 1;  \
        condition_hi: md_##D.res_##R > 0;  \
        update_hi_1_predicate: condition_hi;  \
        update_hi_1_value    : 1+register_lo; \
        update_hi_2_predicate: not condition_hi; \
        update_hi_2_value    : ~register_lo; \
        output_value: alu_hi; \
        output_dst: md_##D.est_##R; \
    } \
    table sketching_##D##_##R##_table { \
        actions { \
            sketching_##D##_##R##_act; \
        } \
        default_action: sketching_##D##_##R##_act; \
    } \
    action sketching_##D##_##R##_act () { \
        blackbox_##D##_##R.execute_stateful_alu_from_hash(cs_index_hash_func_##D##_##R); \
    }

#define SKETCHING_STAGE_1(D) \
    ROW_SKETCH(D, 1)

#define SKETCHING_STAGE_2(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2)

#define SKETCHING_STAGE_3(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2) \
    ROW_SKETCH(D, 3)

#define SKETCHING_STAGE_4(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2) \
    ROW_SKETCH(D, 3) \
    ROW_SKETCH(D, 4)

#define SKETCHING_STAGE_5(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2) \
    ROW_SKETCH(D, 3) \
    ROW_SKETCH(D, 4) \
    ROW_SKETCH(D, 5)
