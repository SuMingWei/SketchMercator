#define heavy_flowkey_storage_step1_3_init(NAME, E1, E2, E3, COMP1, COMP2, COMP3, THRESHOLD) \
    table NAME##_subtract_table { \
        actions { \
            NAME##_subtract_table_act; \
        } \
        default_action: NAME##_subtract_table_act; \
    } \
    action NAME##_subtract_table_act () { \
        subtract_from_field(E1, THRESHOLD); \
        subtract_from_field(E2, THRESHOLD); \
        subtract_from_field(E3, THRESHOLD); \
    } \
    table NAME##_shift_table { \
        actions { \
            NAME##_shift_table_act; \
        } \
        default_action: NAME##_shift_table_act; \
    } \
    action NAME##_shift_table_act () { \
        shift_right(COMP1, E1, 31); \
        shift_right(COMP2, E2, 31); \
        shift_right(COMP3, E3, 31); \
    } \

#define heavy_flowkey_storage_step1_3_call(NAME) \
    apply(NAME##_subtract_table); \
    apply(NAME##_shift_table); \


#define O6_HASH_TABLE_INIT(NAME, N, KEY_FIELDS, KEY, HASH_ENTRY) \
    field_list_calculation NAME##_hash_func_##N { \
        input { \
            KEY_FIELDS; \
        } \
        algorithm : poly_0x11e12a719_init_0x00000000_xout_0xffffffff; \
        output_width : 14; \
    } \
    register NAME##_hash_table_register_##N { \
        width: 32; \
        instance_count: 16384; \
    } \
    blackbox stateful_alu NAME##_blackbox_##N { \
        reg: NAME##_hash_table_register_##N; \
        condition_lo: register_lo == 0; \
        update_lo_1_predicate: condition_lo; \
        update_lo_1_value    : KEY; \
        update_lo_2_predicate: not condition_lo; /* else */ \
        update_lo_2_value    : register_lo; \
        update_hi_1_predicate: condition_lo;     /* if   */ \
        update_hi_1_value    : 0; \
        update_hi_2_predicate: not condition_lo; /* else */ \
        update_hi_2_value    : register_lo; \
        output_value: alu_hi; \
        output_dst: HASH_ENTRY; \
    } \
    table NAME##_##N##_call_hash_table_table { \
        actions { \
            NAME##_##N##_call_hash_table_table_act; \
        } \
        default_action: NAME##_##N##_call_hash_table_table_act; \
    } \
    action NAME##_##N##_call_hash_table_table_act () { \
        NAME##_blackbox_##N.execute_stateful_alu_from_hash(NAME##_hash_func_##N); \
    }

#define heavy_flowkey_storage_step2_3_key_1_init(NAME, C1, C2, C3, ABOVE_THRESHOLD, KEY_FIELDS, MATCH_HIT, KEY_1, HASH_ENTRY_1) \
    table NAME##_sum_table { \
        reads { \
            C1: exact; \
            C2: exact; \
            C3: exact; \
        } \
        actions { \
            NAME##_sum_miss; \
            NAME##_sum_hit; \
        } \
        default_action: NAME##_sum_miss; \
        size: 32; \
    } \
    action NAME##_sum_miss() { \
        modify_field(ABOVE_THRESHOLD, 0); \
    } \
    action NAME##_sum_hit() { \
        modify_field(ABOVE_THRESHOLD, 1); \
    } \
    O6_HASH_TABLE_INIT(NAME, 1, KEY_FIELDS, KEY_1, HASH_ENTRY_1) \
    table NAME##_match_table { \
        reads { \
            KEY_1: exact; \
        } \
        actions { \
            NAME##_match_miss; \
            NAME##_match_hit; \
        } \
        default_action: NAME##_match_miss; \
        size : 10000; \
    } \
    action NAME##_match_miss() { \
        modify_field(MATCH_HIT, 0); \
    } \
    action NAME##_match_hit() { \
        modify_field(MATCH_HIT, 1); \
    } \

#define heavy_flowkey_storage_step2_3_key_1_call(NAME, ABOVE_THRESHOLD, KEY_1, HASH_ENTRY_1) \
    apply(NAME##_sum_table); \
    if (ABOVE_THRESHOLD == 1) { \
        apply(NAME##_1_call_hash_table_table); \
        if (HASH_ENTRY_1 != KEY_1) { \
            apply(NAME##_match_table); \
        }\
    }\


#define heavy_flowkey_storage_step2_3_key_2_init(NAME, C1, C2, C3, ABOVE_THRESHOLD, KEY_FIELDS, MATCH_HIT, KEY_1, KEY_2, HASH_ENTRY_1, HASH_ENTRY_2) \
    table NAME##_sum_table { \
        reads { \
            C1: exact; \
            C2: exact; \
            C3: exact; \
        } \
        actions { \
            NAME##_sum_miss; \
            NAME##_sum_hit; \
        } \
        default_action: NAME##_sum_miss; \
        size: 32; \
    } \
    action NAME##_sum_miss() { \
        modify_field(ABOVE_THRESHOLD, 0); \
    } \
    action NAME##_sum_hit() { \
        modify_field(ABOVE_THRESHOLD, 1); \
    } \
    O6_HASH_TABLE_INIT(NAME, 1, KEY_FIELDS, KEY_1, HASH_ENTRY_1) \
    O6_HASH_TABLE_INIT(NAME, 2, KEY_FIELDS, KEY_2, HASH_ENTRY_2) \
    table NAME##_match_table { \
        reads { \
            KEY_1: exact; \
            KEY_2: exact; \
        } \
        actions { \
            NAME##_match_miss; \
            NAME##_match_hit; \
        } \
        default_action: NAME##_match_miss; \
        size : 10000; \
    } \
    action NAME##_match_miss() { \
        modify_field(MATCH_HIT, 0); \
    } \
    action NAME##_match_hit() { \
        modify_field(MATCH_HIT, 1); \
    } \

#define heavy_flowkey_storage_step2_3_key_2_call(NAME, ABOVE_THRESHOLD, KEY_1, KEY_2, HASH_ENTRY_1, HASH_ENTRY_2) \
    apply(NAME##_sum_table); \
    if (ABOVE_THRESHOLD == 1) { \
        apply(NAME##_1_call_hash_table_table); \
        apply(NAME##_2_call_hash_table_table); \
        if (HASH_ENTRY_1 != KEY_1) { \
            apply(NAME##_match_table); \
        }\
        else { \
            if (HASH_ENTRY_2 != KEY_2) { \
                apply(NAME##_match_table); \
            }\
        }\
    }\



#define heavy_flowkey_storage_step2_3_key_3_init(NAME, C1, C2, C3, ABOVE_THRESHOLD, KEY_FIELDS, MATCH_HIT, KEY_1, KEY_2, KEY_3, HASH_ENTRY_1, HASH_ENTRY_2, HASH_ENTRY_3) \
    table NAME##_sum_table { \
        reads { \
            C1: exact; \
            C2: exact; \
            C3: exact; \
        } \
        actions { \
            NAME##_sum_miss; \
            NAME##_sum_hit; \
        } \
        default_action: NAME##_sum_miss; \
        size: 32; \
    } \
    action NAME##_sum_miss() { \
        modify_field(ABOVE_THRESHOLD, 0); \
    } \
    action NAME##_sum_hit() { \
        modify_field(ABOVE_THRESHOLD, 1); \
    } \
    O6_HASH_TABLE_INIT(NAME, 1, KEY_FIELDS, KEY_1, HASH_ENTRY_1) \
    O6_HASH_TABLE_INIT(NAME, 2, KEY_FIELDS, KEY_2, HASH_ENTRY_2) \
    O6_HASH_TABLE_INIT(NAME, 3, KEY_FIELDS, KEY_3, HASH_ENTRY_3) \
    table NAME##_match_table { \
        reads { \
            KEY_1: exact; \
            KEY_2: exact; \
            KEY_3: exact; \
        } \
        actions { \
            NAME##_match_miss; \
            NAME##_match_hit; \
        } \
        default_action: NAME##_match_miss; \
        size : 10000; \
    } \
    action NAME##_match_miss() { \
        modify_field(MATCH_HIT, 0); \
    } \
    action NAME##_match_hit() { \
        modify_field(MATCH_HIT, 1); \
    } \

#define heavy_flowkey_storage_step2_3_key_3_call(NAME, ABOVE_THRESHOLD, KEY_1, KEY_2, KEY_3, HASH_ENTRY_1, HASH_ENTRY_2, HASH_ENTRY_3) \
    apply(NAME##_sum_table); \
    if (ABOVE_THRESHOLD == 1) { \
        apply(NAME##_1_call_hash_table_table); \
        apply(NAME##_2_call_hash_table_table); \
        apply(NAME##_3_call_hash_table_table); \
        if (HASH_ENTRY_1 != KEY_1) { \
            apply(NAME##_match_table); \
        }\
        else { \
            if (HASH_ENTRY_2 != KEY_2) { \
                apply(NAME##_match_table); \
            }\
            else { \
                if (HASH_ENTRY_3 != KEY_3) { \
                    apply(NAME##_match_table); \
                }\
            }\
        }\
    }\


