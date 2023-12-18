#define COMPUTE_SAMPLING(D) \
    CRCPolynomial<bit<32>>(32w0x30243f##D##b, \
                           true, \
                           false, \
                           false, \
                           32w0xFFFFFFFF, \
                           32w0xFFFFFFFF \
                           ) sampling_poly_##D##; \
    Hash<bit<1>>(HashAlgorithm_t.CUSTOM, sampling_poly_##D##) sampling_hash_##D##; \
    action action_sampling_hash_##D() { \
        ig_md.sampling_bit_##D = sampling_hash_##D##.get({hdr.ipv4.src_addr[31:0]}); \
    }

#define COMPUTE_RES(D, R) \
    CRCPolynomial<bit<32>>(32w0x0f79##D##5##R##3, \
                           true, \
                           false, \
                           false, \
                           32w0xFFFFFFFF, \
                           32w0xFFFFFFFF \
                           ) res_poly_##D##_##R##; \
    Hash<bit<1>>(HashAlgorithm_t.CUSTOM, res_poly_##D##_##R##) res_hash_##D##_##R##; \
    action action_res_hash_##D##_##R() { \
        ig_md.res_##D##_##R## = res_hash_##D##_##R##.get({hdr.ipv4.src_addr[31:0]}); \
    }

#define COMPUTE_RES_1(D) \
    COMPUTE_RES(D, 1)

#define COMPUTE_RES_2(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2)

#define COMPUTE_RES_3(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3)

#define COMPUTE_RES_4(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3) \
    COMPUTE_RES(D, 4)

#define COMPUTE_RES_5(D) \
    COMPUTE_RES(D, 1) \
    COMPUTE_RES(D, 2) \
    COMPUTE_RES(D, 3) \
    COMPUTE_RES(D, 4) \
    COMPUTE_RES(D, 5)
