// API1 is reuse output result

#define API1_REUSE_3_INIT(NAME, KEY_FIELDS, POLY_PARAM, PHV, LEN, PHV1, MASK1, PHV2, MASK2, PHV3, MASK3) \
    field_list_calculation NAME##_hash_func { \
        input { \
            KEY_FIELDS; \
        } \
        algorithm : poly_##POLY_PARAM##_init_0x00000000_xout_0xffffffff; \
        output_width : 32; \
    } \
	table NAME##_compute_all_hash { \
	    actions { \
	        NAME##_compute_all_hash_act; \
	    } \
	    default_action: NAME##_compute_all_hash_act; \
	} \
	action NAME##_compute_all_hash_act () { \
	    modify_field_with_hash_based_offset(PHV, 0x0, NAME##_hash_func, LEN); \
	} \
	table NAME##_split_table { \
	    actions { \
	        NAME##_split_table_act; \
	    } \
	    default_action: NAME##_split_table_act; \
	} \
	action NAME##_split_table_act () { \
	    modify_field_with_shift(PHV1, PHV, 0, MASK1); \
	    modify_field_with_shift(PHV2, PHV, 0, MASK2); \
	    modify_field_with_shift(PHV3, PHV, 0, MASK3); \
	}

#define API1_REUSE_CALL(NAME) \
	apply(NAME##_compute_all_hash);
