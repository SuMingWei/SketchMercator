// API2 is merge hashes and split output result

/* ----------------  */
/* For no split INIT */
/* ----------------  */

#define API0_HASH_INIT(NAME, KEY_FIELDS, POLY_PARAM, PHV, MASK) \
    field_list_calculation NAME##_hash_func { \
        input { \
            KEY_FIELDS; \
        } \
		algorithm : programmable_crc; \
        output_width : 32; \
    } \
	table NAME##_compute_hash { \
	    actions { \
	        NAME##_compute_hash_act; \
	    } \
	    default_action: NAME##_compute_hash_act; \
	} \
	action NAME##_compute_hash_act () { \
		modify_field_with_hash_based_offset(PHV, 0, NAME##_hash_func, MASK); \
	}

/* ---------------- */
/* CALLs */
/* ---------------- */

#define API0_HASH_CALL(NAME) \
	apply(NAME##_compute_hash);
