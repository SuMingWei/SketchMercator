#define METADATA_SETUP(D) \
    bit<1> sampling_bit_##D##; \
    bit<1> res_##D##_1; \
    bit<1> res_##D##_2; \
    bit<1> res_##D##_3; \
    bit<1> res_##D##_4; \
    bit<1> res_##D##_5; \
    bit<16> index_##D##_1; \
    bit<16> index_##D##_2; \
    bit<16> index_##D##_3; \
    bit<16> index_##D##_4; \
    bit<16> index_##D##_5;
