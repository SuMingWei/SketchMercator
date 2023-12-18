header_type md_t {
    fields {
        sampling_hash_value: 16;
        level:10;
        base:16;
        threshold: 32;
        temp:5;
        res_1: 1;
        res_2: 1;
        res_3: 1;
        res_4: 1;
        res_5: 1;
        index_1: 16;
        index_2: 16;
        index_3: 16;
        index_4: 16;
        index_5: 16;
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
        above_threshold: 1;
        hash_entry: 32;
        hash_hit: 1;
        match_hit: 1;

        bf_index:32;
        bf:1;
        a:32;
        b:32;
        c:32;
        d:32;
    }
}

#define METADATA_STAGE(D) \
    metadata md_t md_##D;
