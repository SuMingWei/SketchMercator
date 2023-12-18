
#define API6_COMPARE_5_INIT(NAME, E1, E2, E3, E4, E5, COMP1, COMP2, COMP3, COMP4, COMP5, THRESHOLD) \
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
        subtract_from_field(E4, THRESHOLD); \
        subtract_from_field(E5, THRESHOLD); \
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
        shift_right(COMP4, E4, 31); \
        shift_right(COMP5, E5, 31); \
    }

#define API6_COMPARE_5_CALL(NAME) \
    apply(NAME##_subtract_table); \
    apply(NAME##_shift_table);

#define API6_SUM_TABLE_5_INIT(NAME, C1, C2, C3, C4, C5, V1, V2, D, KEYFIELDS) \
    table NAME##_sum_table { \
        reads { \
            C1: exact; \
            C2: exact; \
            C3: exact; \
            C4: exact; \
            C5: exact; \
        } \
        actions { \
            NAME##_sum_hit; \
        } \
        size: 32; \
    } \
    action NAME##_sum_hit() { \
        modify_field(V1, D); \
    }

#define API6_SUM_TABLE_5_CALL(NAME) \
    apply(NAME##_sum_table);
