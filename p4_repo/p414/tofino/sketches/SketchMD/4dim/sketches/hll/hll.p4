header_type hll_md_t {
    fields {
        index_1: 16;
        sampling_hash_value: 16;
        level:32;
        base:16;
    }
}

#define HLL_WIDTH 1024
#define HLL_TOTAL 16384


#define HLL_INSTANCE(D, FLOWKEY) \
    metadata hll_md_t hll_md_##D; \
    hash_init(hll_##D##_sampling, FLOWKEY, 0x1198f10d1, hll_md_##D.sampling_hash_value, 65536) \
    lpm_optimization_init(hll_##D##_tcam, hll_md_##D.sampling_hash_value, hll_md_##D.level) \
    HLL_SKETCH(D, FLOWKEY, hll_md_##D.level) \


#define HLL_RUN(D) \
    hash_call(hll_##D##_sampling) \
    lpm_optimization_call(hll_##D##_tcam) \
    apply(hll_sketching_##D##_table); \
