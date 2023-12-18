// API2 is merge hashes and split output result


/* ---------------- */
/* For 5 split INIT */
/* ---------------- */

#define API2_SPLIT_5_INIT(NAME, KEY_FIELDS, POLY_PARAM, PHV0, LEN0, PHV1, PHV2, PHV3, PHV4, PHV5, MASK1, MASK2, MASK3, MASK4, LEN1, LEN2, LEN3, LEN4) \
    field_list_calculation NAME##_hash_func { \
        input { \
            KEY_FIELDS; \
        } \
        algorithm : programmable_crc; \
        output_width : 16; \
    } \
	table NAME##_compute_all_hash { \
	    actions { \
	        NAME##_compute_all_hash_act; \
	    } \
	    default_action: NAME##_compute_all_hash_act; \
	} \
	action NAME##_compute_all_hash_act () { \
	    modify_field_with_hash_based_offset(PHV0, 0x0, NAME##_hash_func, LEN0); \
	} \
	table NAME##_split_table { \
	    actions { \
	        NAME##_split_table_act; \
	    } \
	    default_action: NAME##_split_table_act; \
	} \
	action NAME##_split_table_act () { \
	    bit_and(PHV1, PHV0, MASK1); \
	    shift_right(PHV2, PHV0, LEN1); \
	    bit_and(PHV2, PHV2, MASK2); \
	    shift_right(PHV3, PHV0, LEN2); \
	    bit_and(PHV3, PHV3, MASK3); \
	    shift_right(PHV4, PHV0, LEN3); \
	    bit_and(PHV4, PHV4, MASK4); \
	    shift_right(PHV5, PHV0, LEN4); \
	}


/* ---------------- */
/* CALLs */
/* ---------------- */

#define API2_SPLIT_CALL(NAME) \
	apply(NAME##_compute_all_hash); \
	apply(NAME##_split_table);


