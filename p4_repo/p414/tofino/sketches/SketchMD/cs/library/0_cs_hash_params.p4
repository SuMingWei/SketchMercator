#define INDEX_HASH_FUNCTION(D, R) \
    field_list_calculation cs_index_hash_func_##D##_##R { \
        input { \
            key_fields_##D; \
        } \
        algorithm : poly_0x11e12a##D##R##1_init_0x00000000_xout_0ffffffff; \
        output_width : CS_HASH_WIDTH; \
    }

#define RES_HASH_FUNCTION(D, R) \
    field_list_calculation cs_res_hash_func_##D##_##R { \
        input { \
            key_fields_##D; \
        } \
        algorithm : poly_0x11ba20##D##R##1_init_0x00000000_xout_0ffffffff; \
        output_width : 1; \
    }

#define HASH_INIT_7(D) \
    INDEX_HASH_FUNCTION(D, 1) \
    INDEX_HASH_FUNCTION(D, 2) \
    INDEX_HASH_FUNCTION(D, 3) \
    INDEX_HASH_FUNCTION(D, 4) \
    INDEX_HASH_FUNCTION(D, 5) \
    INDEX_HASH_FUNCTION(D, 6) \
    INDEX_HASH_FUNCTION(D, 7) \
    RES_HASH_FUNCTION(D, 1) \
    RES_HASH_FUNCTION(D, 2) \
    RES_HASH_FUNCTION(D, 3) \
    RES_HASH_FUNCTION(D, 4) \
    RES_HASH_FUNCTION(D, 5) \
    RES_HASH_FUNCTION(D, 6) \
    RES_HASH_FUNCTION(D, 7)


HASH_INIT_7(1)
HASH_INIT_7(2)
HASH_INIT_7(3)
HASH_INIT_7(4)
HASH_INIT_7(5)
HASH_INIT_7(6)
HASH_INIT_7(7)
