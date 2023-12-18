#define COMPUTE_SAMPLING(D) \
    table sampling_##D##_table { \
        actions { \
            sampling_##D##_table_act; \
        } \
        default_action: sampling_##D##_table_act; \
    } \
    action sampling_##D##_table_act () { \
        modify_field_with_hash_based_offset(md_##D.sampling, 0x0, univmon_sampling_hash_func_##D, 2); \
    }


#define COMPUTE_RES(D, R) \
    table res_##D##_##R##_table { \
        actions { \
            res_##D##_##R##_table_act; \
        } \
    } \
    action res_##D##_##R##_table_act () { \
        modify_field_with_hash_based_offset(md_##D.res_##R, 0x0, cs_res_hash_func_##D##_##R, 2); \
    }

// default_action: res_##D##_##R##_table_act; \

#define COMPUTE_RES_1(D) \
    COMPUTE_RES(D, 1)

#define COMPUTE_RES_2(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2)

#define COMPUTE_RES_3(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3)

#define COMPUTE_RES_4(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3) \
    COMPUTE_RES(D, 4)

#define COMPUTE_RES_5(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3) \
    COMPUTE_RES(D, 4) \
    COMPUTE_RES(D, 5)
