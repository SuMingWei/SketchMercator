#define hash_init(NAME, KEY_FIELDS, POLY_PARAM, PHV, MASK) \
    field_list_calculation NAME##_hash_func { \
        input { \
            KEY_FIELDS; \
        } \
        algorithm : poly_##POLY_PARAM##_init_0x00000000_xout_0xffffffff; \
        output_width : 32; \
    } \
    table NAME##_compute_hash { \
        actions { \
            NAME##_compute_hash_act; \
        } \
        default_action: NAME##_compute_hash_act; \
    } \
    action NAME##_compute_hash_act () { \
        modify_field_with_hash_based_offset(PHV, 0x0, NAME##_hash_func, MASK); \
    }
#define hash_call(NAME) \
    apply(NAME##_compute_hash);


#define hash_consolidate_and_split_5_init(NAME, KEY_FIELDS, POLY_PARAM, PHV0, LEN0, PHV1, PHV2, PHV3, PHV4, PHV5, MASK1, MASK2, MASK3, MASK4, LEN1, LEN2, LEN3, LEN4) \
    field_list_calculation NAME##_hash_func { \
        input { \
            KEY_FIELDS; \
        } \
        algorithm : poly_##POLY_PARAM##_init_0x00000000_xout_0xffffffff; \
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
        shift_right(PHV1, PHV0, 0); \
        shift_right(PHV2, PHV0, LEN1); \
        shift_right(PHV3, PHV0, LEN2); \
        shift_right(PHV4, PHV0, LEN3); \
        shift_right(PHV5, PHV0, LEN4); \
    }

#define hash_consolidate_and_split_5_call(NAME) \
    apply(NAME##_compute_all_hash); \
    apply(NAME##_split_table);



#define select_key_init(NAME, LEVEL, BASE, THRESHOLD, D) \
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

#define select_key_call(NAME) \
    apply(NAME##_select_key_table);

#define reuse_hash_result_3_init(NAME, KEY_FIELDS, POLY_PARAM, PHV, PHV1, PHV2, PHV3, MASK1, MASK2, MASK3) \
    field_list_calculation NAME##_hash_func { \
        input { \
            KEY_FIELDS; \
        } \
        algorithm : poly_##POLY_PARAM##_init_0x00000000_xout_0xffffffff; \
        output_width : 16; \
    } \
    table NAME##_compute_all_hash { \
        actions { \
            NAME##_compute_all_hash_act; \
        } \
        default_action: NAME##_compute_all_hash_act; \
    } \
    action NAME##_compute_all_hash_act () { \
        modify_field_with_hash_based_offset(PHV, 0x0, NAME##_hash_func, 16); \
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

#define reuse_hash_result_3_call(NAME) \
    apply(NAME##_compute_all_hash); \
    apply(NAME##_split_table);




