#define SAMPLING_HASH_FUNCTION_1(D) \
    field_list_calculation univmon_sampling_hash_func_##D { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x1##D##e##D##2aa##D##3_init_0x00000000_xout_0ffffffff; \
        output_width : 1; \
    }

#define INDEX_HASH_FUNCTION_1(D, R) \
    field_list_calculation cs_index_hash_func_##D##_##R { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x12e12a##D##R##1_init_0x00000000_xout_0ffffffff; \
        output_width : CS_HASH_WIDTH; \
    }

#define RES_HASH_FUNCTION_1(D, R) \
    field_list_calculation cs_res_hash_func_##D##_##R { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x13ba20##D##R##3_init_0x00000000_xout_0ffffffff; \
        output_width : 1; \
    }

#define SAMPLING_HASH_FUNCTION_2(D) \
    field_list_calculation univmon_sampling_hash_func_##D { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x14e12a##D##5_init_0x00000000_xout_0ffffffff; \
        output_width : 1; \
    }

#define INDEX_HASH_FUNCTION_2(D, R) \
    field_list_calculation cs_index_hash_func_##D##_##R { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x15e12##D##R##7_init_0x00000000_xout_0ffffffff; \
        output_width : CS_HASH_WIDTH; \
    }

#define RES_HASH_FUNCTION_2(D, R) \
    field_list_calculation cs_res_hash_func_##D##_##R { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x16ba2##D##R##9_init_0x00000000_xout_0ffffffff; \
        output_width : 1; \
    }

#define HASH_INIT_1(D) \
    SAMPLING_HASH_FUNCTION_1(D) \
    INDEX_HASH_FUNCTION_1(D, 1) \
    INDEX_HASH_FUNCTION_1(D, 2) \
    INDEX_HASH_FUNCTION_1(D, 3) \
    INDEX_HASH_FUNCTION_1(D, 4) \
    INDEX_HASH_FUNCTION_1(D, 5) \
    INDEX_HASH_FUNCTION_1(D, 6) \
    INDEX_HASH_FUNCTION_1(D, 7) \
    RES_HASH_FUNCTION_1(D, 1) \
    RES_HASH_FUNCTION_1(D, 2) \
    RES_HASH_FUNCTION_1(D, 3) \
    RES_HASH_FUNCTION_1(D, 4) \
    RES_HASH_FUNCTION_1(D, 5) \
    RES_HASH_FUNCTION_1(D, 6) \
    RES_HASH_FUNCTION_1(D, 7)

#define HASH_INIT_2(D) \
    SAMPLING_HASH_FUNCTION_2(D) \
    INDEX_HASH_FUNCTION_2(D, 1) \
    INDEX_HASH_FUNCTION_2(D, 2) \
    INDEX_HASH_FUNCTION_2(D, 3) \
    INDEX_HASH_FUNCTION_2(D, 4) \
    INDEX_HASH_FUNCTION_2(D, 5) \
    INDEX_HASH_FUNCTION_2(D, 6) \
    INDEX_HASH_FUNCTION_2(D, 7) \
    RES_HASH_FUNCTION_2(D, 1) \
    RES_HASH_FUNCTION_2(D, 2) \
    RES_HASH_FUNCTION_2(D, 3) \
    RES_HASH_FUNCTION_2(D, 4) \
    RES_HASH_FUNCTION_2(D, 5) \
    RES_HASH_FUNCTION_2(D, 6) \
    RES_HASH_FUNCTION_2(D, 7)


HASH_INIT_1(1)
HASH_INIT_1(2)
HASH_INIT_1(3)
HASH_INIT_1(4)
HASH_INIT_1(5)
HASH_INIT_1(6)
HASH_INIT_1(7)
HASH_INIT_1(8)
HASH_INIT_1(9)
HASH_INIT_2(10)
HASH_INIT_2(11)
HASH_INIT_2(12)
HASH_INIT_2(13)
HASH_INIT_2(14)
HASH_INIT_2(15)
HASH_INIT_2(16)
HASH_INIT_2(17)
HASH_INIT_2(18)
HASH_INIT_2(19)
HASH_INIT_2(20)
HASH_INIT_2(21)
HASH_INIT_2(22)
HASH_INIT_2(23)
HASH_INIT_2(24)
HASH_INIT_2(25)
HASH_INIT_2(26)
HASH_INIT_2(27)
HASH_INIT_2(28)
HASH_INIT_2(29)
HASH_INIT_2(30)
