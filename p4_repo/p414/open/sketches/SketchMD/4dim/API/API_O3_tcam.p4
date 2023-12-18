#define lpm_optimization_init(NAME, SAMPLING_HASH, LEVEL, BASE) \
    action NAME##_table_act (level, base) { \
        modify_field(LEVEL, level); \
        modify_field(BASE, base); \
    } \
    table NAME##_table { \
        reads { \
            SAMPLING_HASH : lpm; \
        } \
        actions { \
            NAME##_table_act; \
        } \
    }

#define lpm_optimization_call(NAME) \
	apply(NAME##_table);
