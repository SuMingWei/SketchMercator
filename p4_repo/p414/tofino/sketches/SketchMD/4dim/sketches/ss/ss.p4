header_type ss_md_t {
    fields {
        index_1: 16;
        index_2: 16;
        index_3: 16;
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

#define SS_WIDTH_BITLEN 10
#define SS_WIDTH 1024
#define SS_TOTAL 65536

#define SS_INIT_COMMON(D, FLOWKEY, ATTR) \
    metadata ss_md_t ss_md_##D; \
    hash_init(ss_##D##_sampling, ATTR, 0x1198f10d1, ss_md_##D.sampling_hash_value, 65536) \
    lpm_optimization_init(ss_##D##_tcam, ss_md_##D.sampling_hash_value, ss_md_##D.level) \
    hash_init(ss_##D##_index_1, FLOWKEY, 0x119cf8783, ss_md_##D.index_1, SS_WIDTH) \
    hash_init(ss_##D##_index_2, FLOWKEY, 0x119cf8785, ss_md_##D.index_2, SS_WIDTH) \
    hash_init(ss_##D##_index_3, FLOWKEY, 0x119cf8787, ss_md_##D.index_3, SS_WIDTH) \
    consolidate_update_ss_init(ss_##D##_row_1, ss_md_##D.base, ss_md_##D.sampling_hash_value, ss_md_##D.index_1, SS_TOTAL) \
    consolidate_update_ss_init(ss_##D##_row_2, ss_md_##D.base, ss_md_##D.sampling_hash_value, ss_md_##D.index_2, SS_TOTAL) \
    consolidate_update_ss_init(ss_##D##_row_3, ss_md_##D.base, ss_md_##D.sampling_hash_value, ss_md_##D.index_3, SS_TOTAL) \


#define SS_INSTANCE_KEY_1(D, FLOWKEY, ATTR, KEY_1) \
    SS_INIT_COMMON(D, FLOWKEY, ATTR) \
    consolidate_update_ss_update_init(ss_##D##_level_1, ss_md_##D.index_1, ss_md_##D.level, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_level_2, ss_md_##D.index_2, ss_md_##D.level, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_level_3, ss_md_##D.index_3, ss_md_##D.level, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key1_1, ss_md_##D.index_1, KEY_1, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key1_2, ss_md_##D.index_2, KEY_1, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key1_3, ss_md_##D.index_3, KEY_1, SS_WIDTH) \


#define SS_INSTANCE_KEY_2(D, FLOWKEY, ATTR, KEY_1, KEY_2) \
    SS_INIT_COMMON(D, FLOWKEY, ATTR) \
    consolidate_update_ss_update_init(ss_##D##_level_1, ss_md_##D.index_1, ss_md_##D.level, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_level_2, ss_md_##D.index_2, ss_md_##D.level, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_level_3, ss_md_##D.index_3, ss_md_##D.level, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key1_1, ss_md_##D.index_1, KEY_1, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key1_2, ss_md_##D.index_2, KEY_1, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key1_3, ss_md_##D.index_3, KEY_1, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key2_1, ss_md_##D.index_1, KEY_2, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key2_2, ss_md_##D.index_2, KEY_2, SS_WIDTH) \
    consolidate_update_ss_update_init(ss_##D##_key2_3, ss_md_##D.index_3, KEY_2, SS_WIDTH) \



#define SS_RUN_COMMON(D) \
    hash_call(ss_##D##_sampling) \
    lpm_optimization_call(ss_##D##_tcam) \
    hash_call(ss_##D##_index_1) \
    hash_call(ss_##D##_index_2) \
    hash_call(ss_##D##_index_3) \
    consolidate_update_ss_call(ss_##D##_row_1) \
    consolidate_update_ss_call(ss_##D##_row_2) \
    consolidate_update_ss_call(ss_##D##_row_3) \


#define SS_RUN_KEY_1(D) \
    SS_RUN_COMMON(D) \
    consolidate_update_ss_update_call(ss_##D##_level_1) \
    consolidate_update_ss_update_call(ss_##D##_level_2) \
    consolidate_update_ss_update_call(ss_##D##_level_3) \
    consolidate_update_ss_update_call(ss_##D##_key1_1) \
    consolidate_update_ss_update_call(ss_##D##_key1_2) \
    consolidate_update_ss_update_call(ss_##D##_key1_3) \


#define SS_RUN_KEY_2(D) \
    SS_RUN_COMMON(D) \
    consolidate_update_ss_update_call(ss_##D##_level_1) \
    consolidate_update_ss_update_call(ss_##D##_level_2) \
    consolidate_update_ss_update_call(ss_##D##_level_3) \
    consolidate_update_ss_update_call(ss_##D##_key1_1) \
    consolidate_update_ss_update_call(ss_##D##_key1_2) \
    consolidate_update_ss_update_call(ss_##D##_key1_3) \
    consolidate_update_ss_update_call(ss_##D##_key2_1) \
    consolidate_update_ss_update_call(ss_##D##_key2_2) \
    consolidate_update_ss_update_call(ss_##D##_key2_3) \


#define SS_ADV_RUN_KEY_1(D) \
    SS_RUN_COMMON(D) \
    consolidate_update_ss_update_call(ss_##D##_level_1) \
    consolidate_update_ss_update_call(ss_##D##_level_2) \
    consolidate_update_ss_update_call(ss_##D##_level_3) \


#define SS_ADV_RUN_KEY_2(D) \
    SS_RUN_COMMON(D) \
    consolidate_update_ss_update_call(ss_##D##_level_1) \
    consolidate_update_ss_update_call(ss_##D##_level_2) \
    consolidate_update_ss_update_call(ss_##D##_level_3) \
    consolidate_update_ss_update_call(ss_##D##_key2_1) \
    consolidate_update_ss_update_call(ss_##D##_key2_2) \
    consolidate_update_ss_update_call(ss_##D##_key2_3) \
