#define CM_INDEX_UPDATE_CORE(SIZE, BITLEN)                                          \
    Hash<bit<##BITLEN##>>(HashAlgorithm_t.CUSTOM, poly1) hash;                \
    Register<bit<32>, bit<##BITLEN##>>(SIZE) cm_ca;                           \
    RegisterAction<bit<32>, bit<##BITLEN##>, bit<32>>(cm_ca) cm_ca_action = { \
        void apply(inout bit<32> register_data, out bit<32> result) {     \
            register_data = register_data + (bit<32>)psize;               \
            result = register_data;                                       \
        }                                                                 \
    };                                                                    \



#define CM_INDEX_UPDATE(SIZE, BITLEN)                   \
control CM_INDEX_UPDATE_##SIZE##(                       \
    in bit<16> index,                                   \
    in bit<16> psize,                                   \
    out bit<32> est)() {                                \
    CM_INDEX_UPDATE_CORE(SIZE, BITLEN)                  \
    apply {                                             \
        est = cm_ca_action.execute(index);              \
    }                                                   \
}                                                       \

CM_INDEX_UPDATE(1024, 10)
CM_INDEX_UPDATE(2048, 11)
CM_INDEX_UPDATE(4096, 12)
CM_INDEX_UPDATE(8192, 13)
