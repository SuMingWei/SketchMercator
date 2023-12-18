header_type md_t {
    fields {
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
        threshold: 16;
        above_threshold: 1;
        hash_entry: 32;
        hash_hit: 1;
        match_hit: 1;
    }
}

#define METADATA_STAGE(D) \
	metadata md_t md_##D;


// header_type md_t {
//     fields {
//         temp:32;
//         res_1: 32;
//         res_2: 32;
//         res_3: 32;
//         res_4: 32;
//         res_5: 32;
//         res_6: 32;
//         res_7: 32;
//         res_8: 32;
//         index_1: 32;
//         index_2: 32;
//         index_3: 32;
//         index_4: 32;
//         index_5: 32;
//         index_6: 32;
//         index_7: 32;
//         index_8: 32;
//         est_1: 32;
//         est_2: 32;
//         est_3: 32;
//         est_4: 32;
//         est_5: 32;
//         est_6: 32;
//         est_7: 32;
//         est_8: 32;
//         compare_1: 1;
//         compare_2: 1;
//         compare_3: 1;
//         compare_4: 1;
//         compare_5: 1;
//         compare_6: 1;
//         compare_7: 1;
//         compare_8: 1;
//     }
// }
