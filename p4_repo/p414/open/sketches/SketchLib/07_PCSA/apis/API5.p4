// logarithmic hashing

#define API5_INIT(NAME, PHV, D) \
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

#define API5_CALL(NAME) \
	apply(NAME##_table);

