#define ROW_SKETCH(D, R) \
    register  register_##D##_##R { \
        width: 1; \
        static: sketching_##D##_##R##_table; \
        instance_count: COL_SIZE; \
    } \
    table sketching_##D##_##R##_table { \
        actions { \
            sketching_##D##_##R##_act; \
        } \
        default_action: sketching_##D##_##R##_act; \
    } \
    action sketching_##D##_##R##_act () { \
        register_write(register_##D##_##R, md_##D.alpha, 1); \
    }
