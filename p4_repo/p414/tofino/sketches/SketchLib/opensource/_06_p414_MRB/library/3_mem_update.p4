
#define ROW_SKETCH(D, R) \
    register  register_##D##_##R { \
        width: 32; \
        instance_count: COL_SIZE; \
    } \
    blackbox stateful_alu blackbox_##D##_##R { \
        reg: register_##D##_##R; \
        update_lo_1_value    : 1;  \
    } \
    table sketching_##D##_##R##_table { \
        actions { \
            sketching_##D##_##R##_act; \
        } \
        default_action: sketching_##D##_##R##_act; \
    } \
    action sketching_##D##_##R##_act () { \
        blackbox_##D##_##R.execute_stateful_alu(md_##D.alpha); \
    }
