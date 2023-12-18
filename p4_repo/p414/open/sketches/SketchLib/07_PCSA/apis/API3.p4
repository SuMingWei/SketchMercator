// API3 is select input using if/else


#define API3_INIT(NAME, LEVEL, BASE, THRESHOLD, D) \
	table NAME##_select_key_table { \
	    reads { \
	        LEVEL : exact; \
	    } \
	    actions { \
	        NAME##_select_key_0_act; \
	        NAME##_select_key_1_act; \
	        NAME##_select_key_2_act; \
	        NAME##_select_key_3_act; \
	        NAME##_select_key_4_act; \
	        NAME##_select_key_5_act; \
	        NAME##_select_key_6_act; \
	        NAME##_select_key_7_act; \
	        NAME##_select_key_8_act; \
	        NAME##_select_key_9_act; \
	        NAME##_select_key_10_act; \
	        NAME##_select_key_11_act; \
	        NAME##_select_key_12_act; \
	        NAME##_select_key_13_act; \
	        NAME##_select_key_14_act; \
	        NAME##_select_key_15_act; \
	        NAME##_select_key_16_act; \
	        NAME##_select_key_17_act; \
	        NAME##_select_key_18_act; \
	        NAME##_select_key_19_act; \
	        NAME##_select_key_20_act; \
	        NAME##_select_key_21_act; \
	        NAME##_select_key_22_act; \
	        NAME##_select_key_23_act; \
	        NAME##_select_key_24_act; \
	    } \
	} \
	action NAME##_select_key_0_act (base, threshold) { \
		modify_field(md_##D.base, base); \
		modify_field(md_##D.threshold, threshold); \
	    modify_field(md_##D.src_key, ipv4.srcAddr); \
	    modify_field(md_##D.dst_key, ipv4.dstAddr); \
	} \
	action NAME##_select_key_1_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, ipv4.srcAddr); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 8, 16777215); \
	} \
	action NAME##_select_key_2_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, ipv4.srcAddr); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 16, 65535); \
	} \
	action NAME##_select_key_3_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, ipv4.srcAddr); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 24, 255); \
	} \
	action NAME##_select_key_4_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, ipv4.srcAddr); \
	    modify_field(md_##D.dst_key, 0); \
	} \
	action NAME##_select_key_5_act (base, threshold) { \
		modify_field(md_##D.base, base); \
		modify_field(md_##D.threshold, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 8, 16777215); \
	    modify_field(md_##D.dst_key, ipv4.dstAddr); \
	} \
	action NAME##_select_key_6_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 8, 16777215); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 8, 16777215); \
	} \
	action NAME##_select_key_7_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 8, 16777215); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 16, 65535); \
	} \
	action NAME##_select_key_8_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 8, 16777215); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 24, 255); \
	} \
	action NAME##_select_key_9_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 8, 16777215); \
	    modify_field(md_##D.dst_key, 0); \
	} \
	action NAME##_select_key_10_act (base, threshold) { \
		modify_field(md_##D.base, base); \
		modify_field(md_##D.threshold, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 16, 65535); \
	    modify_field(md_##D.dst_key, ipv4.dstAddr); \
	} \
	action NAME##_select_key_11_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 16, 65535); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 8, 16777215); \
	} \
	action NAME##_select_key_12_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 16, 65535); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 16, 65535); \
	} \
	action NAME##_select_key_13_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 16, 65535); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 24, 255); \
	} \
	action NAME##_select_key_14_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 16, 65535); \
	    modify_field(md_##D.dst_key, 0); \
	} \
	action NAME##_select_key_15_act (base, threshold) { \
		modify_field(md_##D.base, base); \
		modify_field(md_##D.threshold, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 24, 255); \
	    modify_field(md_##D.dst_key, ipv4.dstAddr); \
	} \
	action NAME##_select_key_16_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 24, 255); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 8, 16777215); \
	} \
	action NAME##_select_key_17_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 24, 255); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 16, 65535); \
	} \
	action NAME##_select_key_18_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 24, 255); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 24, 255); \
	} \
	action NAME##_select_key_19_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field_with_shift(md_##D.src_key, ipv4.srcAddr, 24, 255); \
	    modify_field(md_##D.dst_key, 0); \
	} \
	action NAME##_select_key_20_act (base, threshold) { \
		modify_field(md_##D.base, base); \
		modify_field(md_##D.threshold, threshold); \
	    modify_field(md_##D.src_key, 0); \
	    modify_field(md_##D.dst_key, ipv4.dstAddr); \
	} \
	action NAME##_select_key_21_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, 0); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 8, 16777215); \
	} \
	action NAME##_select_key_22_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, 0); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 16, 65535); \
	} \
	action NAME##_select_key_23_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, 0); \
	    modify_field_with_shift(md_##D.dst_key, ipv4.dstAddr, 24, 255); \
	} \
	action NAME##_select_key_24_act (base, threshold) { \
		modify_field(BASE, base); \
		modify_field(THRESHOLD, threshold); \
	    modify_field(md_##D.src_key, 0); \
	    modify_field(md_##D.dst_key, 0); \
	}

#define API3_CALL(NAME) \
	apply(NAME##_select_key_table);
