#define CS_UPDATE_1(LENGTH) \
    control CS_UPDATE_##LENGTH##_1( \
    in bit<32> index) \
    { \
        Register<bit<1>, bit<32>>(##LENGTH##) cs_table; \
        RegisterAction<bit<1>, bit<32>, bit<1>>(cs_table) cs_action = { \
            void apply(inout bit<1> register_data, out bit<1> result) { \
                register_data = register_data + 1; \
                result = register_data; \
            } \
        }; \
        apply { \
            cs_action.execute(index); \
        } \
    }
CS_UPDATE_1(4096)
CS_UPDATE_1(8192)
CS_UPDATE_1(12288)
CS_UPDATE_1(16384)
CS_UPDATE_1(20480)
CS_UPDATE_1(32768)
CS_UPDATE_1(36864)
CS_UPDATE_1(65536)
CS_UPDATE_1(131072)


#define CS_UPDATE_32(LENGTH) \
    control CS_UPDATE_##LENGTH##_32( \
    in bit<32> index) \
    { \
        Register<bit<32>, bit<32>>(##LENGTH##) cs_table; \
        RegisterAction<bit<32>, bit<32>, bit<32>>(cs_table) cs_action = { \
            void apply(inout bit<32> register_data, out bit<32> result) { \
                register_data = register_data + 1; \
                result = register_data; \
            } \
        }; \
        apply { \
            cs_action.execute(index); \
        } \
    }
CS_UPDATE_32(4096)
CS_UPDATE_32(8192)
CS_UPDATE_32(12288)
CS_UPDATE_32(16384)
CS_UPDATE_32(20480)
CS_UPDATE_32(32768)
CS_UPDATE_32(36864)
CS_UPDATE_32(65536)
CS_UPDATE_32(131072)


struct pair {
    bit<32>     first;
    bit<32>     second;
}

#define CS_UPDATE_64(LENGTH) \
    control CS_UPDATE_##LENGTH##_64( \
    in bit<32> index) \
    { \
        Register<pair, bit<32>>(##LENGTH##) cs_table; \
        RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = { \
            void apply(inout pair register_data, out bit<32> result) { \
                register_data.first = register_data.first + 1; \
                register_data.second = register_data.second + 1; \
                result = register_data.second; \
            } \
        }; \
        apply { \
            cs_action.execute(index); \
        } \
    }
CS_UPDATE_64(4096)
CS_UPDATE_64(8192)
CS_UPDATE_64(12288)
CS_UPDATE_64(16384)
CS_UPDATE_64(20480)
CS_UPDATE_64(32768)
CS_UPDATE_64(36864)
CS_UPDATE_64(65536)
CS_UPDATE_64(131072)
