#define ROW_SKETCH(D, R) \
    register  register_##D##_##R { \
        width: 32; \
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
        modify_field_with_hash_based_offset(md_##D.index_##R, 0, cs_index_hash_func_##D##_##R, 2048); \
        register_read(md_##D.est_##R, register_##D##_##R, md_##D.index_##R); \
        add_to_field(md_##D.est_##R, md_##D.res_##R); \
        register_write(register_##D##_##R, md_##D.index_##R, md_##D.est_##R); \
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
