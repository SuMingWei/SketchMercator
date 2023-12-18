#define COMPUTE_RES(D, R) \
    table res_##D##_##R##_table { \
        actions { \
            res_##D##_##R##_table_act; \
        } \
        default_action: res_##D##_##R##_table_act; \
    } \
    action res_##D##_##R##_table_act () { \
        modify_field_with_hash_based_offset(md_##D.res_##R, 0x0, cs_res_hash_func_##D##_##R, 2); \
    }


#define COMPUTE_HASH_1(D) \
    COMPUTE_RES(D, 1)

#define COMPUTE_HASH_2(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2)

#define COMPUTE_HASH_3(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3)

#define COMPUTE_HASH_4(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3) \
    COMPUTE_RES(D, 4)

#define COMPUTE_HASH_5(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3) \
    COMPUTE_RES(D, 4) \
    COMPUTE_RES(D, 5)
