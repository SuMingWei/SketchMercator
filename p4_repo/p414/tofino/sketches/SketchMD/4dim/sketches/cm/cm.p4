header_type cm_md_t {
    fields {
        res_1: 1;
        res_2: 1;
        res_3: 1;
        // res_4: 1;
        // res_5: 1;
        est_1: 32;
        est_2: 32;
        est_3: 32;
        // est_4: 32;
        // est_5: 32;
        threshold: 32;
        above_threshold: 1;
        hash_entry_1: 32;
        hash_entry_2: 32;
        hash_entry_3: 32;
        match_hit: 1;
    }
}

#define CM_INIT_COMMON(D, FLOWKEY) \
    metadata cm_md_t cm_md_##D; \
    CM_ROW_SKETCH(D, 1, FLOWKEY) \
    CM_ROW_SKETCH(D, 2, FLOWKEY) \
    CM_ROW_SKETCH(D, 3, FLOWKEY) \

    // TH_TABLE(cm_md_##D.threshold) \

#define CM_INSTANCE_KEY_1(D, FLOWKEY, KEY_1) \
    CM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(cm_##D##_f1, cm_md_##D.est_1, cm_md_##D.est_2, cm_md_##D.est_3, cm_md_##D.res_1, cm_md_##D.res_2, cm_md_##D.res_3, cm_md_##D.threshold) \
    heavy_flowkey_storage_step2_3_key_1_init(cm_##D##_f2, cm_md_##D.res_1, cm_md_##D.res_2, cm_md_##D.res_3, cm_md_##D.above_threshold, FLOWKEY, cm_md_##D.match_hit, KEY_1, cm_md_##D.hash_entry_1) \

#define CM_INSTANCE_KEY_2(D, FLOWKEY, KEY_1, KEY_2) \
    CM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(cm_##D##_f1, cm_md_##D.est_1, cm_md_##D.est_2, cm_md_##D.est_3, cm_md_##D.res_1, cm_md_##D.res_2, cm_md_##D.res_3, cm_md_##D.threshold) \
    heavy_flowkey_storage_step2_3_key_2_init(cm_##D##_f2, cm_md_##D.res_1, cm_md_##D.res_2, cm_md_##D.res_3, cm_md_##D.above_threshold, FLOWKEY, cm_md_##D.match_hit, KEY_1, KEY_2, cm_md_##D.hash_entry_1, cm_md_##D.hash_entry_2) \

#define CM_INSTANCE_KEY_3(D, FLOWKEY, KEY_1, KEY_2, KEY_3) \
    CM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(cm_##D##_f1, cm_md_##D.est_1, cm_md_##D.est_2, cm_md_##D.est_3, cm_md_##D.res_1, cm_md_##D.res_2, cm_md_##D.res_3, cm_md_##D.threshold) \
    heavy_flowkey_storage_step2_3_key_3_init(cm_##D##_f2, cm_md_##D.res_1, cm_md_##D.res_2, cm_md_##D.res_3, cm_md_##D.above_threshold, FLOWKEY, cm_md_##D.match_hit, KEY_1, KEY_2, KEY_3, cm_md_##D.hash_entry_1, cm_md_##D.hash_entry_2, cm_md_##D.hash_entry_3) \

// #define CM_INSTANCE_NOHH(D, FLOWKEY) \
//     CM_INIT_COMMON(D, FLOWKEY) \
    // apply(th_table); \


#define CM_RUN_COMMON(D) \
    apply(cm_sketching_##D##_1_table); \
    apply(cm_sketching_##D##_2_table); \
    apply(cm_sketching_##D##_3_table); \

#define CM_RUN_KEY_1(D, KEY_1) \
    CM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(cm_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_1_call(cm_##D##_f2, cm_md_##D.above_threshold, KEY_1, cm_md_##D.hash_entry_1) \

#define CM_RUN_KEY_2(D, KEY_1, KEY_2) \
    CM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(cm_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_2_call(cm_##D##_f2, cm_md_##D.above_threshold, KEY_1, KEY_2, cm_md_##D.hash_entry_1, cm_md_##D.hash_entry_2) \

#define CM_RUN_KEY_3(D, KEY_1, KEY_2, KEY_3) \
    CM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(cm_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_3_call(cm_##D##_f2, cm_md_##D.above_threshold, KEY_1, KEY_2, KEY_3, cm_md_##D.hash_entry_1, cm_md_##D.hash_entry_2, cm_md_##D.hash_entry_3) \

// #define CM_RUN_KEY_NOHH(D) \

