header_type mrac_md_t {
    fields {
        index_1: 16;
        sampling_hash_value: 16;
        level:32;
        base:16;
    }
}

#define MRAC_WIDTH 1024
#define MRAC_TOTAL 16384

#define MRAC_INSTANCE(D, FLOWKEY) \
    metadata mrac_md_t mrac_md_##D; \
    hash_init(mrac_##D##_sampling, FLOWKEY, 0x1198f10d1, mrac_md_##D.sampling_hash_value, 65536) \
    lpm_optimization_init(mrac_##D##_tcam, mrac_md_##D.sampling_hash_value, mrac_md_##D.level) \
    hash_init(mrac_##D##_index_1, FLOWKEY, 0x119cf8783, mrac_md_##D.index_1, MRAC_WIDTH) \
    consolidate_update_mrac_init(mrac_##D##_row_1, mrac_md_##D.base, mrac_md_##D.index_1, MRAC_TOTAL) \


#define MRAC_RUN(D) \
    hash_call(mrac_##D##_sampling) \
    lpm_optimization_call(mrac_##D##_tcam) \
    hash_call(mrac_##D##_index_1) \
    consolidate_update_mrac_call(mrac_##D##_row_1) \
