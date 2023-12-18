// logarithmic hashing

#define lpm_optimization_init(NAME, PHV, D) \
    action NAME##_table_act (level, base, threshold) { \
        modify_field(md_##D.level, level); \
        modify_field(md_##D.base, base); \
        modify_field(md_##D.threshold, threshold); \
    } \
    table NAME##_table { \
        reads { \
            PHV : lpm; \
        } \
        actions { \
            NAME##_table_act; \
        } \
    }

#define lpm_optimization_call(NAME) \
	apply(NAME##_table);

