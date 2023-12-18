header_type um_md_t {
    fields {
        temp: 3;
        res_1: 1;
        res_2: 1;
        res_3: 1;
        // res_4: 1;
        // res_5: 1;
        index_1: 16;
        index_2: 16;
        index_3: 16;
        // index_4: 16;
        // index_5: 16;
        est_1: 32;
        est_2: 32;
        est_3: 32;
        // est_4: 32;
        // est_5: 32;
        sampling_hash_value: 16;
        level:32;
        base:16;
        threshold: 32;
        above_threshold: 1;
        hash_entry_1: 32;
        hash_entry_2: 32;
        hash_entry_3: 32;
        match_hit: 1;
    }
}

#define UM_WIDTH_BITLEN 10
#define UM_WIDTH 1024
#define UM_TOTAL 16384

#define UM_INIT_COMMON(D, FLOWKEY) \
    metadata um_md_t um_md_##D; \
    hash_init(um_##D##_sampling, FLOWKEY, 0x1198f10d1, um_md_##D.sampling_hash_value, 65536) \
    lpm_optimization_init(um_##D##_tcam, um_md_##D.sampling_hash_value, um_md_##D.level, um_md_##D.base) \
    hash_consolidate_and_split_3_init(um_##D##_tcam, FLOWKEY, 0x11e12a717, um_md_##D.temp, 8, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, 1, 1, 1, 2) \
    hash_init(um_##D##_index_1, FLOWKEY, 0x119cf8783, um_md_##D.index_1, UM_WIDTH) \
    hash_init(um_##D##_index_2, FLOWKEY, 0x119cf8785, um_md_##D.index_2, UM_WIDTH) \
    hash_init(um_##D##_index_3, FLOWKEY, 0x119cf8787, um_md_##D.index_3, UM_WIDTH) \
    consolidate_update_cs_init(um_##D##_row_1, um_md_##D.base, um_md_##D.index_1, um_md_##D.res_1, um_md_##D.est_1, UM_TOTAL) \
    consolidate_update_cs_init(um_##D##_row_2, um_md_##D.base, um_md_##D.index_2, um_md_##D.res_2, um_md_##D.est_2, UM_TOTAL) \
    consolidate_update_cs_init(um_##D##_row_3, um_md_##D.base, um_md_##D.index_3, um_md_##D.res_3, um_md_##D.est_3, UM_TOTAL) \

#define UM_INSTANCE_KEY_1(D, FLOWKEY, KEY_1) \
    UM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(um_##D##_f1, um_md_##D.est_1, um_md_##D.est_2, um_md_##D.est_3, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.threshold, um_md_##D.above_threshold) \
    heavy_flowkey_storage_step2_3_key_1_init(um_##D##_f2, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.above_threshold, FLOWKEY, um_md_##D.match_hit, KEY_1, um_md_##D.hash_entry_1, 16384) \

#define UM_INSTANCE_KEY_2(D, FLOWKEY, KEY_1, KEY_2) \
    UM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(um_##D##_f1, um_md_##D.est_1, um_md_##D.est_2, um_md_##D.est_3, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.threshold, um_md_##D.above_threshold) \
    heavy_flowkey_storage_step2_3_key_2_init(um_##D##_f2, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.above_threshold, FLOWKEY, um_md_##D.match_hit, KEY_1, KEY_2, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2, 16384) \

#define UM_INSTANCE_KEY_3(D, FLOWKEY, KEY_1, KEY_2, KEY_3) \
    UM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(um_##D##_f1, um_md_##D.est_1, um_md_##D.est_2, um_md_##D.est_3, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.threshold, um_md_##D.above_threshold) \
    heavy_flowkey_storage_step2_3_key_3_init(um_##D##_f2, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.above_threshold, FLOWKEY, um_md_##D.match_hit, KEY_1, KEY_2, KEY_3, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2, um_md_##D.hash_entry_3, 16384) \

#define UM_INSTANCE_KEY_3_SIZE(D, FLOWKEY, KEY_1, KEY_2, KEY_3, SIZE) \
    UM_INIT_COMMON(D, FLOWKEY) \
    heavy_flowkey_storage_step1_3_init(um_##D##_f1, um_md_##D.est_1, um_md_##D.est_2, um_md_##D.est_3, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.threshold, um_md_##D.above_threshold) \
    heavy_flowkey_storage_step2_3_key_3_init(um_##D##_f2, um_md_##D.res_1, um_md_##D.res_2, um_md_##D.res_3, um_md_##D.above_threshold, FLOWKEY, um_md_##D.match_hit, KEY_1, KEY_2, KEY_3, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2, um_md_##D.hash_entry_3, SIZE) \


#define UM_RUN_COMMON(D) \
    hash_call(um_##D##_sampling) \
    lpm_optimization_call(um_##D##_tcam) \
    hash_consolidate_and_split_3_call(um_##D##_tcam) \
    hash_call(um_##D##_index_1) \
    hash_call(um_##D##_index_2) \
    hash_call(um_##D##_index_3) \
    consolidate_update_cs_call(um_##D##_row_1) \
    consolidate_update_cs_call(um_##D##_row_2) \
    consolidate_update_cs_call(um_##D##_row_3) \

#define UM_RUN_KEY_1(D, KEY_1) \
    UM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(um_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_1_call(um_##D##_f2, um_md_##D.above_threshold, KEY_1, um_md_##D.hash_entry_1) \

#define UM_RUN_KEY_2(D, KEY_1, KEY_2) \
    UM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(um_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_2_call(um_##D##_f2, um_md_##D.above_threshold, KEY_1, KEY_2, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2) \

#define UM_RUN_KEY_3(D, KEY_1, KEY_2, KEY_3) \
    UM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(um_##D##_f1) \
    heavy_flowkey_storage_step2_3_key_3_call(um_##D##_f2, um_md_##D.above_threshold, KEY_1, KEY_2, KEY_3, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2, um_md_##D.hash_entry_3) \


#define UM_RUN_KEY_1_HALF(D, KEY_1) \
    UM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(um_##D##_f1) \

#define UM_RUN_KEY_2_HALF(D, KEY_1, KEY_2) \
    UM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(um_##D##_f1) \

#define UM_RUN_KEY_3_HALF(D, KEY_1, KEY_2, KEY_3) \
    UM_RUN_COMMON(D) \
    heavy_flowkey_storage_step1_3_call(um_##D##_f1) \

#define UM_RUN_KEY_ALL(D, KEY_1, KEY_2, KEY_3) \
    heavy_flowkey_storage_step2_3_key_3_call_all(um_##D##_f2, um_md_##D.above_threshold, KEY_1, KEY_2, KEY_3, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2, um_md_##D.hash_entry_3) \


    // heavy_flowkey_storage_step2_3_key_3_call_half(um_##D##_f2, um_md_##D.above_threshold, KEY_1, KEY_2, KEY_3, um_md_##D.hash_entry_1, um_md_##D.hash_entry_2, um_md_##D.hash_entry_3) \
