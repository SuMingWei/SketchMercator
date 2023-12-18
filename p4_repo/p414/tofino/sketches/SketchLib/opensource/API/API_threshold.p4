#define TH_TABLE() \
    action th_table_act (threshold) { \
        modify_field(md.threshold, threshold); \
    } \
    table th_table { \
        actions { \
            th_table_act; \
        } \
    }
