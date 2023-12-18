header_type mrb_md_t {
    fields {
        index_1: 16;
        sampling_hash_value: 16;
        level:32;
        base:16;
    }
}

#define MRB_WIDTH 1024
#define MRB_TOTAL 16384

#define MRB_INSTANCE(D, FLOWKEY) \
    metadata mrb_md_t mrb_md_##D; \
    hash_init(mrb_##D##_sampling, FLOWKEY, 0x1198f10d1, mrb_md_##D.sampling_hash_value, 65536) \
    lpm_optimization_init(mrb_##D##_tcam, mrb_md_##D.sampling_hash_value, mrb_md_##D.level, mrb_md_##D.base) \
    hash_init(mrb_##D##_index_1, FLOWKEY, 0x119cf8783, mrb_md_##D.index_1, MRB_WIDTH) \
    consolidate_update_mrb_init(mrb_##D##_row_1, mrb_md_##D.base, mrb_md_##D.index_1, MRB_TOTAL) \


#define MRB_RUN(D) \
    hash_call(mrb_##D##_sampling) \
    lpm_optimization_call(mrb_##D##_tcam) \
    hash_call(mrb_##D##_index_1) \
    consolidate_update_mrb_call(mrb_##D##_row_1) \
