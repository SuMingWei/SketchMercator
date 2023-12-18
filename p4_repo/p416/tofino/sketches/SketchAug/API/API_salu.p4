#define HLL_UPDATE(SIZE, LENGTH) \
    control HLL_UPDATE_##SIZE##( \
    in bit<16> index, \
    in bit<16> level) \
    { \
        Register<bit<32>, bit<16>>(##SIZE##) cs_table; \
        RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = { \
            void apply(inout bit<32> register_data, out bit<32> result) { \
                if ((bit<32>)level > register_data) { \
                    register_data = (bit<32>)level; \
                } \
            } \
        }; \
        apply { \
            cs_action.execute((bit<16>)index[##LENGTH##:0]); \
        } \
    }

HLL_UPDATE(512, 8)
HLL_UPDATE(1024, 9)
HLL_UPDATE(2048, 10)
HLL_UPDATE(4096, 11)


#define CS_UPDATE(SIZE, LENGTH) \
    control CS_UPDATE_##SIZE##( \
    in bit<16> index, \
    in bit<1> res, \
    out bit<32> est) \
    { \
        Register<bit<32>, bit<16>>(##SIZE##) cs_table; \
        RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = { \
            void apply(inout bit<32> register_data, out bit<32> result) { \
                if (res == 0) { \
                    register_data = register_data - 1; \
                } \
                else { \
                    register_data = register_data + 1; \
                } \
                result = register_data; \
            } \
        }; \
        apply { \
            est = cs_action.execute((bit<16>)index[##LENGTH##:0]); \
        } \
    }

CS_UPDATE(512, 8)
CS_UPDATE(1024, 9)
CS_UPDATE(2048, 10)
CS_UPDATE(4096, 11)
CS_UPDATE(8192, 12)
CS_UPDATE(16384, 13)
CS_UPDATE(32768, 14)
CS_UPDATE(51200, 15)


#define CM_UPDATE(SIZE, LENGTH) \
    control CM_UPDATE_##SIZE##( \
    in bit<16> index, \
    in bit<1> res, \
    out bit<32> est) \
    { \
        Register<bit<32>, bit<16>>(##SIZE##) cs_table; \
        RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = { \
            void apply(inout bit<32> register_data, out bit<32> result) { \
                register_data = register_data + 1; \
            } \
        }; \
        apply { \
            est = cs_action.execute((bit<16>)index[##LENGTH##:0]); \
        } \
    }

CM_UPDATE(512, 8)
CM_UPDATE(1024, 9)
CM_UPDATE(2048, 10)
CM_UPDATE(4096, 11)
CM_UPDATE(8192, 12)
CM_UPDATE(16384, 13)

#define MRB_UPDATE(SIZE) \
    control MRB_UPDATE_##SIZE##( \
    in bit<16> index) \
    { \
        Register<bit<1>, bit<16>>(##SIZE##) cs_table; \
        RegisterAction<bit<1>, bit<16>, bit<1>>(cs_table) cs_action = { \
            void apply(inout bit<1> register_data, out bit<1> result) { \
                register_data = 1; \
            } \
        }; \
        apply { \
            cs_action.execute(index); \
        } \
    }

MRB_UPDATE(4096)
MRB_UPDATE(8192)
MRB_UPDATE(16384)
MRB_UPDATE(32768)
MRB_UPDATE(65536)

// control CS_UPDATE_1(
//   in bit<16> index_1,
//   in bit<1> res_1,
//   out bit<32> est_1)
// {

//     Register<bit<32>, bit<16>>(32w32768) cs1_table;
//     // Register<bit<32>, bit<16>>(32w512) cs1;

//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs1_table) cs1_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             if (res_1 == 0) {
//                 register_data = register_data - 1;
//             }
//             else {
//                 register_data = register_data + 1;
//             }
//             result = register_data;
//         }
//     };

//     apply {
//         est_1 = cs1_action.execute(index_1);
//         if (res_1 == 0) {
//             est_1 = -est_1;
//         }
//     }
// }



// control PCSA_UPDATE(
//   in bit<16> index)
// {
//     Register<bit<32>, bit<16>>(32w1024) cs_table;

//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     apply {
//         cs_action.execute(index);
//     }
// }

// control MRB_UPDATE(
//   in bit<16> index)
// {
//     Register<bit<32>, bit<16>>(32w65536) cs_table;

//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     apply {
//         cs_action.execute(index);
//     }
// }


// control CS_UPDATE(
//   in bit<16> index,
//   in bit<1> res,
//   out bit<32> est)
// {

//     // Register<bit<32>, bit<16>>(32w2048) cs_table;
//     // Register<bit<32>, bit<16>>(32w4096) cs_table;
//     // Register<bit<32>, bit<16>>(32w8192) cs_table;
//     // Register<bit<32>, bit<16>>(32w12288) cs_table;
//     // Register<bit<32>, bit<16>>(32w16384) cs_table;
//     Register<bit<32>, bit<16>>(32w36864) cs_table;
//     // Register<bit<32>, bit<16>>(32w32768) cs_table;
//     // Register<bit<32>, bit<16>>(32w65536) cs_table;
//     // Register<bit<32>, bit<16>>(32w512) cs1;

//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             if (res == 0) {
//                 register_data = register_data - 1;
//             }
//             else {
//                 register_data = register_data + 1;
//             }
//             result = register_data;
//         }
//     };

//     apply {
//         est = cs_action.execute(index);
//         if (res == 0) {
//             est = -est;
//         }
//     }
// }



// #define CS_UPDATE(D)                                                                \
// control CS_UPDATE_##D (                                                             \  
//   in bit<16> index_##D,                                                             \
//   in bit<1> res_##D,                                                                \
//   out bit<32> est_##D)                                                              \
// {                                                                                   \
//                                                                                     \
//     Register<bit<32>, bit<16>>(32w32768) cs##D##_table;                             \
//                                                                                     \
//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs##D##_table) cs##D##_action = {     \
//         void apply(inout bit<32> register_data, out bit<32> result) {               \
//             if (res_##D == 0) {                                                     \
//                 register_data = register_data - 1;                                  \
//             }                                                                       \
//             else {                                                                  \
//                 register_data = register_data + 1;                                  \
//             }                                                                       \
//             result = register_data;                                                 \
//         }                                                                           \
//     };                                                                              \
//                                                                                     \
//     apply {                                                                         \
//         est_##D = cs##D##_action.execute(index_##D);                                \
//         if (res_##D == 0) {                                                         \
//             est_##D = -est_##D;                                                     \
//         }                                                                           \
//     }                                                                               \
// }

