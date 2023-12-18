header_type kary_md_t {
    fields {
        res_1: 1;
        res_2: 1;
        res_3: 1;
        est_1: 32;
        est_2: 32;
        est_3: 32;
        est_4: 32;
        est_5: 32;
        est_6: 32;
        threshold: 32;
        above_threshold: 1;
        hash_entry_1: 32;
        hash_entry_2: 32;
        hash_entry_3: 32;
        match_hit: 1;
    }
}

#define KARY_INIT_COMMON(D, FLOWKEY) \
    metadata kary_md_t kary_md_##D; \
    KARY_ROW_SKETCH(D, 1, FLOWKEY) \
    KARY_ROW_SKETCH(D, 2, FLOWKEY) \
    KARY_ROW_SKETCH(D, 3, FLOWKEY) \
    KARY_ROW_SKETCH(D, 4, FLOWKEY) \
    KARY_ROW_SKETCH(D, 5, FLOWKEY) \
    KARY_ROW_SKETCH(D, 6, FLOWKEY) \

#define KARY_INSTANCE_KEY_1(D, FLOWKEY, KEY_1) \
    KARY_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(kary_##D##_f1, kary_md_##D.est_1, kary_md_##D.est_2, kary_md_##D.est_3, kary_md_##D.res_1, kary_md_##D.res_2, kary_md_##D.res_3, kary_md_##D.threshold) \
    heavy_flowkey_storage_step2_3_key_1_init(kary_##D##_f2, kary_md_##D.res_1, kary_md_##D.res_2, kary_md_##D.res_3, kary_md_##D.above_threshold, FLOWKEY, kary_md_##D.match_hit, KEY_1, kary_md_##D.hash_entry_1) \

#define KARY_INSTANCE_KEY_2(D, FLOWKEY, KEY_1, KEY_2) \
    KARY_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(kary_##D##_f1, kary_md_##D.est_1, kary_md_##D.est_2, kary_md_##D.est_3, kary_md_##D.res_1, kary_md_##D.res_2, kary_md_##D.res_3, kary_md_##D.threshold) \
    heavy_flowkey_storage_step2_3_key_2_init(kary_##D##_f2, kary_md_##D.res_1, kary_md_##D.res_2, kary_md_##D.res_3, kary_md_##D.above_threshold, FLOWKEY, kary_md_##D.match_hit, KEY_1, KEY_2, kary_md_##D.hash_entry_1, kary_md_##D.hash_entry_2) \

#define KARY_INSTANCE_KEY_3(D, FLOWKEY, KEY_1, KEY_2, KEY_3) \
    KARY_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(kary_##D##_f1, kary_md_##D.est_1, kary_md_##D.est_2, kary_md_##D.est_3, kary_md_##D.res_1, kary_md_##D.res_2, kary_md_##D.res_3, kary_md_##D.threshold) \
    heavy_flowkey_storage_step2_3_key_3_init(kary_##D##_f2, kary_md_##D.res_1, kary_md_##D.res_2, kary_md_##D.res_3, kary_md_##D.above_threshold, FLOWKEY, kary_md_##D.match_hit, KEY_1, KEY_2, KEY_3, kary_md_##D.hash_entry_1, kary_md_##D.hash_entry_2, kary_md_##D.hash_entry_3) \

// #define KARY_INSTANCE_NOHH(D, FLOWKEY) \
//     KARY_INIT_COMMON(D, FLOWKEY) \
    // apply(th_table); \


#define KARY_RUN_COMMON(D) \
    apply(kary_sketching_##D##_1_table); \
    apply(kary_sketching_##D##_2_table); \
    apply(kary_sketching_##D##_3_table); \
    apply(kary_sketching_##D##_4_table); \
    apply(kary_sketching_##D##_5_table); \
    apply(kary_sketching_##D##_6_table); \

#define KARY_RUN_KEY_1(D, KEY_1) \
    KARY_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(kary_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_1_call(kary_##D##_f2, kary_md_##D.above_threshold, KEY_1, kary_md_##D.hash_entry_1) \

#define KARY_RUN_KEY_2(D, KEY_1, KEY_2) \
    KARY_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(kary_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_2_call(kary_##D##_f2, kary_md_##D.above_threshold, KEY_1, KEY_2, kary_md_##D.hash_entry_1, kary_md_##D.hash_entry_2) \

#define KARY_RUN_KEY_3(D, KEY_1, KEY_2, KEY_3) \
    KARY_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(kary_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_3_call(kary_##D##_f2, kary_md_##D.above_threshold, KEY_1, KEY_2, KEY_3, kary_md_##D.hash_entry_1, kary_md_##D.hash_entry_2, kary_md_##D.hash_entry_3) \

// #define KARY_RUN_KEY_NOHH(D) \

