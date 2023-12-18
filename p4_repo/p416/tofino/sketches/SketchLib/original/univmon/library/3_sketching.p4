#define ROW_SKETCH(D, R) \
    Register<bit<32>, bit<11>>(32w32768) cs_table_##D##_##R; \
    RegisterAction<bit<32>, bit<11>, bit<32>>(cs_table_##D##_##R) cs_action_##D##_##R = { \
        void apply(inout bit<32> register_data, out bit<32> result) { \
            if (ig_md.res_##D##_##R## == 0) { \
                register_data = register_data - 1; \
            } \
            else { \
                register_data = register_data + 1; \
            } \
        } \
    }; \
    CRCPolynomial<bit<32>>(32w0x298a##D##6##R##3, \
                           true, \
                           false, \
                           false, \
                           32w0xFFFFFFFF, \
                           32w0xFFFFFFFF \
                           ) index_poly_##D##_##R##; \
    Hash<bit<11>>(HashAlgorithm_t.CUSTOM, index_poly_##D##_##R##) index_hash_##D##_##R##; \
    action action_index_hash_and_salu_##D##_##R() { \
        cs_action_##D##_##R.execute(index_hash_##D##_##R##.get({hdr.ipv4.src_addr})); \
    }

        // cs_action_##D##_##R.execute((bit<16>)index_hash_##D##_##R##.get({hdr.ipv4.src_addr[31:0]})); \

#define SKETCHING_STAGE_1(D) \
    ROW_SKETCH(D, 1)

#define SKETCHING_STAGE_2(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2)

#define SKETCHING_STAGE_3(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2) \
    ROW_SKETCH(D, 3)

#define SKETCHING_STAGE_4(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2) \
    ROW_SKETCH(D, 3) \
    ROW_SKETCH(D, 4)

#define SKETCHING_STAGE_5(D) \
    ROW_SKETCH(D, 1) \
    ROW_SKETCH(D, 2) \
    ROW_SKETCH(D, 3) \
    ROW_SKETCH(D, 4) \
    ROW_SKETCH(D, 5)
