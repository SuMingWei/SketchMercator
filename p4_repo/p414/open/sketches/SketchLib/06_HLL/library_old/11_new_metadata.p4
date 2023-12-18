header_type md_t {
    fields {
        sampling_hash_value: 16;
        level:10;
        base:16;
        threshold: 16;
        temp1:5;
        temp2:16;
        res_1: 1;
        res_2: 1;
        res_3: 1;
        res_4: 1;
        res_5: 1;
        index_1: 11;
        index_2: 11;
        index_3: 11;
        index_4: 11;
        index_5: 11;
        est_1: 32;
        est_2: 32;
        est_3: 32;
        est_4: 32;
        est_5: 32;
        comp_1: 1;
        comp_2: 1;
        comp_3: 1;
        comp_4: 1;
        comp_5: 1;
    }
}

#define METADATA_STAGE(D) \
    metadata md_t md_##D;
