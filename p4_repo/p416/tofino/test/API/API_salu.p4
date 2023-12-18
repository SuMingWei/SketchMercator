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

control HLL_UPDATE(
  in bit<16> index,
  in bit<16> level)
{

    Register<bit<32>, bit<16>>(32w2048) cs_table;

    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if ((bit<32>)level > register_data) {
                register_data = (bit<32>)level;
            }
        }
    };

    apply {
        cs_action.execute(index);
    }
}

control PCSA_UPDATE(
  in bit<16> index)
{
    Register<bit<32>, bit<16>>(32w1024) cs_table;

    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    apply {
        cs_action.execute(index);
    }
}

control MRB_UPDATE(
  in bit<16> index)
{
    Register<bit<32>, bit<16>>(32w65536) cs_table;

    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    apply {
        cs_action.execute(index);
    }
}


control CS_UPDATE(
  in bit<16> index,
  in bit<1> res,
  out bit<32> est)
{

    Register<bit<32>, bit<16>>(32w2048) cs_table;
    // Register<bit<32>, bit<16>>(32w4096) cs_table;
    // Register<bit<32>, bit<16>>(32w8192) cs_table;
    // Register<bit<32>, bit<16>>(32w16384) cs_table;
    // Register<bit<32>, bit<16>>(32w32768) cs_table;
    // Register<bit<32>, bit<16>>(32w512) cs1;

    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (res == 0) {
                register_data = register_data - 1;
            }
            else {
                register_data = register_data + 1;
            }
            result = register_data;
        }
    };

    apply {
        est = cs_action.execute(index);
        if (res == 0) {
            est = -est;
        }
    }
}



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

