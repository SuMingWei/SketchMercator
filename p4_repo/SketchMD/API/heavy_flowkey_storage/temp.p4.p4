control HEAVY_FLOWKEY_STORAGE_CONFIG_221 ( \
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md, \
    in bit<32> key1, \
    in bit<32> key2, \
    in bit<16> key3, \
    in bit<16> key4, \
    in bit<8> key5) \
    (bit<32> polynomial) \
{ \
    CRCPolynomial<bit<32>>(polynomial,true,false,false,32w0xFFFFFFFF,32w0xFFFFFFFF) poly1; \
    // HEADER_STORAGE_CONFIG(32, key1, HT_SIZE, HT_BITLEN) \
// #define HEADER_STORAGE_CONFIG(HDR_BITLEN, HDR, HT_SIZE, HT_BITLEN) \
    Register<bit<HDR_BITLEN>, bit<HT_BITLEN>>(HT_SIZE) ##HDR##_hash_table; \
    RegisterAction<bit<HDR_BITLEN>, bit<HT_BITLEN>, bit<HDR_BITLEN>>(##HDR##_hash_table) ##HDR##_action = { \
        void apply(inout bit<HDR_BITLEN> register_data, out bit<HDR_BITLEN> result) { \
            if (register_data == 0) { \
                register_data = ##HDR##; \
                result = 0; \
            } \
            else { \
                result = register_data; \
            } \
        } \
    }; \
    // HEADER_STORAGE_CONFIG(32, key2, HT_SIZE, HT_BITLEN) \
// #define HEADER_STORAGE_CONFIG(HDR_BITLEN, HDR, HT_SIZE, HT_BITLEN) \
    Register<bit<HDR_BITLEN>, bit<HT_BITLEN>>(HT_SIZE) ##HDR##_hash_table; \
    RegisterAction<bit<HDR_BITLEN>, bit<HT_BITLEN>, bit<HDR_BITLEN>>(##HDR##_hash_table) ##HDR##_action = { \
        void apply(inout bit<HDR_BITLEN> register_data, out bit<HDR_BITLEN> result) { \
            if (register_data == 0) { \
                register_data = ##HDR##; \
                result = 0; \
            } \
            else { \
                result = register_data; \
            } \
        } \
    }; \
    // HEADER_STORAGE_CONFIG(16, key3, HT_SIZE, HT_BITLEN) \
// #define HEADER_STORAGE_CONFIG(HDR_BITLEN, HDR, HT_SIZE, HT_BITLEN) \
    Register<bit<HDR_BITLEN>, bit<HT_BITLEN>>(HT_SIZE) ##HDR##_hash_table; \
    RegisterAction<bit<HDR_BITLEN>, bit<HT_BITLEN>, bit<HDR_BITLEN>>(##HDR##_hash_table) ##HDR##_action = { \
        void apply(inout bit<HDR_BITLEN> register_data, out bit<HDR_BITLEN> result) { \
            if (register_data == 0) { \
                register_data = ##HDR##; \
                result = 0; \
            } \
            else { \
                result = register_data; \
            } \
        } \
    }; \
    // HEADER_STORAGE_CONFIG(16, key4, HT_SIZE, HT_BITLEN) \
// #define HEADER_STORAGE_CONFIG(HDR_BITLEN, HDR, HT_SIZE, HT_BITLEN) \
    Register<bit<HDR_BITLEN>, bit<HT_BITLEN>>(HT_SIZE) ##HDR##_hash_table; \
    RegisterAction<bit<HDR_BITLEN>, bit<HT_BITLEN>, bit<HDR_BITLEN>>(##HDR##_hash_table) ##HDR##_action = { \
        void apply(inout bit<HDR_BITLEN> register_data, out bit<HDR_BITLEN> result) { \
            if (register_data == 0) { \
                register_data = ##HDR##; \
                result = 0; \
            } \
            else { \
                result = register_data; \
            } \
        } \
    }; \
    // HEADER_STORAGE_CONFIG(8, key5, HT_SIZE, HT_BITLEN) \
// #define HEADER_STORAGE_CONFIG(HDR_BITLEN, HDR, HT_SIZE, HT_BITLEN) \
    Register<bit<HDR_BITLEN>, bit<HT_BITLEN>>(HT_SIZE) ##HDR##_hash_table; \
    RegisterAction<bit<HDR_BITLEN>, bit<HT_BITLEN>, bit<HDR_BITLEN>>(##HDR##_hash_table) ##HDR##_action = { \
        void apply(inout bit<HDR_BITLEN> register_data, out bit<HDR_BITLEN> result) { \
            if (register_data == 0) { \
                register_data = ##HDR##; \
                result = 0; \
            } \
            else { \
                result = register_data; \
            } \
        } \
    }; \
    // HEADER_STORAGE_STORE_CONFIG_5(32, key1, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_5(HDR_BITLEN, HDR, HT_BITLEN) \
    // HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash_##HDR##; \
    bit<##HDR_BITLEN##> entry_##HDR##; \
    action HDR##_ht_table_act() \
    { \
    entry_##HDR## = ##HDR##_action.execute(hash_##HDR##.get({key1, key2, key3, key4, key5})); \
//     HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
// #define HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
    } \
    table HDR##_ht_table { \
        actions = { \
            HDR##_ht_table_act; \
        } \
        const default_action = HDR##_ht_table_act; \
        size = 16; \
    } \

    // HEADER_STORAGE_STORE_CONFIG_5(32, key2, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_5(HDR_BITLEN, HDR, HT_BITLEN) \
    // HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash_##HDR##; \
    bit<##HDR_BITLEN##> entry_##HDR##; \
    action HDR##_ht_table_act() \
    { \
    entry_##HDR## = ##HDR##_action.execute(hash_##HDR##.get({key1, key2, key3, key4, key5})); \
//     HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
// #define HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
    } \
    table HDR##_ht_table { \
        actions = { \
            HDR##_ht_table_act; \
        } \
        const default_action = HDR##_ht_table_act; \
        size = 16; \
    } \

    // HEADER_STORAGE_STORE_CONFIG_5(16, key3, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_5(HDR_BITLEN, HDR, HT_BITLEN) \
    // HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash_##HDR##; \
    bit<##HDR_BITLEN##> entry_##HDR##; \
    action HDR##_ht_table_act() \
    { \
    entry_##HDR## = ##HDR##_action.execute(hash_##HDR##.get({key1, key2, key3, key4, key5})); \
//     HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
// #define HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
    } \
    table HDR##_ht_table { \
        actions = { \
            HDR##_ht_table_act; \
        } \
        const default_action = HDR##_ht_table_act; \
        size = 16; \
    } \

    // HEADER_STORAGE_STORE_CONFIG_5(16, key4, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_5(HDR_BITLEN, HDR, HT_BITLEN) \
    // HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash_##HDR##; \
    bit<##HDR_BITLEN##> entry_##HDR##; \
    action HDR##_ht_table_act() \
    { \
    entry_##HDR## = ##HDR##_action.execute(hash_##HDR##.get({key1, key2, key3, key4, key5})); \
//     HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
// #define HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
    } \
    table HDR##_ht_table { \
        actions = { \
            HDR##_ht_table_act; \
        } \
        const default_action = HDR##_ht_table_act; \
        size = 16; \
    } \

    // HEADER_STORAGE_STORE_CONFIG_5(8, key5, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_5(HDR_BITLEN, HDR, HT_BITLEN) \
    // HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
// #define HEADER_STORAGE_STORE_CONFIG_SETUP(HDR_BITLEN, HDR, HT_BITLEN) \
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash_##HDR##; \
    bit<##HDR_BITLEN##> entry_##HDR##; \
    action HDR##_ht_table_act() \
    { \
    entry_##HDR## = ##HDR##_action.execute(hash_##HDR##.get({key1, key2, key3, key4, key5})); \
//     HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
// #define HEADER_STORAGE_STORE_END(HDR_BITLEN, HDR) \
    } \
    table HDR##_ht_table { \
        actions = { \
            HDR##_ht_table_act; \
        } \
        const default_action = HDR##_ht_table_act; \
        size = 16; \
    } \

    // EXACT_TABLE_CONFIG_5(EM_SIZE) \
// #define EXACT_TABLE_CONFIG_5(EM_SIZE) \
    // EXACT_TABLE_SETUP() \
// #define EXACT_TABLE_SETUP() \
    action tbl_exact_match_miss() { \
        ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE; \
    } \
    action tbl_exact_match_hit() { \
    } \
    table tbl_exact_match { \
        key = { \
    key1 : exact; \
    key2 : exact; \
    key3 : exact; \
    key4 : exact; \
    key5 : exact; \
    // EXACT_TABLE_CONFIG_END(EM_SIZE) \
// #define EXACT_TABLE_CONFIG_END(EM_SIZE) \
        } \
        actions = { \
            tbl_exact_match_miss; \
            tbl_exact_match_hit; \
        } \
        const default_action = tbl_exact_match_miss; \
        size = EM_SIZE; \
    } \

    apply { \
        // FLOWKEY_STORAGE_CORE_5() \
// #define FLOWKEY_STORAGE_CORE_5() \
    key1_ht_table.apply(); \
    key2_ht_table.apply(); \
    key3_ht_table.apply(); \
    key4_ht_table.apply(); \
    key5_ht_table.apply(); \
    if (entry_key1 != 0 && entry_key2 != 0 && entry_key3 != 0 && entry_key4 != 0 && entry_key5 != 0) { \
        if(entry_key1 != key1) { \
            tbl_exact_match.apply(); \
        } \
        else { \
            if(entry_key2 != key2) { \
                tbl_exact_match.apply(); \
            } \
            else { \
                if(entry_key3 != key3) { \
                    tbl_exact_match.apply(); \
                } \
                else { \
                    if(entry_key4 != key4) { \
                        tbl_exact_match.apply(); \
                    } \
                    else { \
                        if(entry_key5 != key5) { \
                            tbl_exact_match.apply(); \
                        } \
                    } \
                } \
            } \
        } \
    } \

    } \
} \


