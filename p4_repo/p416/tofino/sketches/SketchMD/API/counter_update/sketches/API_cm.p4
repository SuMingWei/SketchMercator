#define CM_UPDATE_SETUP()                               \
    in bit<16> psize,                                   \
    out bit<32> est)(                                   \
    bit<32> polynomial) {                               \


#define CM_UPDATE_CORE(SIZE, BITLEN)                                          \
    Hash<bit<##BITLEN##>>(HashAlgorithm_t.CUSTOM, poly1) hash;                \
    Register<bit<32>, bit<##BITLEN##>>(SIZE) cm_ca;                           \
    RegisterAction<bit<32>, bit<##BITLEN##>, bit<32>>(cm_ca) cm_ca_action = { \
        void apply(inout bit<32> register_data, out bit<32> result) {     \
            register_data = register_data + (bit<32>)psize;               \
            result = register_data;                                       \
        }                                                                 \
    };                                                                    \



#define CM_UPDATE_16(SIZE, BITLEN)                      \
control CM_UPDATE_16_##SIZE##(                          \
    in bit<16> key,                                     \
    CM_UPDATE_SETUP()                                   \
    CRCPolynomial<bit<32>>(polynomial,true,false,false, \
                   32w0xFFFFFFFF, 32w0xFFFFFFFF) poly1; \
    CM_UPDATE_CORE(SIZE, BITLEN)                        \
    apply {                                             \
        est = cm_ca_action.execute(hash.get({key}));    \
    }                                                   \
}                                                       \

CM_UPDATE_16(1024, 10)
CM_UPDATE_16(2048, 11)
CM_UPDATE_16(4096, 12)
CM_UPDATE_16(8192, 13)


#define CM_UPDATE_32(SIZE, BITLEN)                      \
control CM_UPDATE_32_##SIZE##(                          \
    in bit<32> key,                                     \
    CM_UPDATE_SETUP()                                   \
    CRCPolynomial<bit<32>>(polynomial,true,false,false, \
                   32w0xFFFFFFFF, 32w0xFFFFFFFF) poly1; \
    CM_UPDATE_CORE(SIZE, BITLEN)                        \
    apply {                                             \
        est = cm_ca_action.execute(hash.get({key}));    \
    }                                                   \
}                                                       \

CM_UPDATE_32(1024, 10)
CM_UPDATE_32(2048, 11)
CM_UPDATE_32(4096, 12)
CM_UPDATE_32(8192, 13)


#define CM_UPDATE_32_16(SIZE, BITLEN)                      \
control CM_UPDATE_32_16_##SIZE##(                          \
    in bit<32> key1,                                     \
    in bit<16> key2,                                     \
    CM_UPDATE_SETUP()                                   \
    CRCPolynomial<bit<32>>(polynomial,true,false,false, \
                   32w0xFFFFFFFF, 32w0xFFFFFFFF) poly1; \
    CM_UPDATE_CORE(SIZE, BITLEN)                        \
    apply {                                             \
        est = cm_ca_action.execute(hash.get({key1, key2}));    \
    }                                                   \
}                                                       \

CM_UPDATE_32_16(1024, 10)
CM_UPDATE_32_16(2048, 11)
CM_UPDATE_32_16(4096, 12)
CM_UPDATE_32_16(8192, 13)


#define CM_UPDATE_32_32(SIZE, BITLEN)                      \
control CM_UPDATE_32_32_##SIZE##(                          \
    in bit<32> key1,                                     \
    in bit<32> key2,                                     \
    CM_UPDATE_SETUP()                                   \
    CRCPolynomial<bit<32>>(polynomial,true,false,false, \
                   32w0xFFFFFFFF, 32w0xFFFFFFFF) poly1; \
    CM_UPDATE_CORE(SIZE, BITLEN)                        \
    apply {                                             \
        est = cm_ca_action.execute(hash.get({key1, key2}));    \
    }                                                   \
}                                                       \

CM_UPDATE_32_32(1024, 10)
CM_UPDATE_32_32(2048, 11)
CM_UPDATE_32_32(4096, 12)
CM_UPDATE_32_32(8192, 13)
