// control HASH_COMPUTE(
//     in ipv4_addr_t src_addr,
//     in ipv4_addr_t dst_addr,
//     in bit<16> src_port,
//     in bit<16> dst_port,
//     in bit<8> protocol,
//     out bit<32> result1,
//     out bit<32> result2,
//     out bit<32> result3,
//     out bit<32> result4,
//     out bit<32> result5,
//     out bit<32> result6)(
//     bit<32> polynomial)
// {

control HASH_COMPUTE(
    inout header_t hdr,
    inout metadata_t ig_md,
    out bit<32> result_1,
    out bit<32> result_2,
    out bit<32> result_3,
    out bit<32> result_4,
    out bit<32> result_5,
    out bit<32> result_6)(
    bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
        true,
        false,
        false,
        32w0xFFFFFFFF,
        32w0xFFFFFFFF
        ) poly1;

    Hash<bit<32>>(HashAlgorithm_t.CUSTOM, poly1) hash_1;
    Hash<bit<32>>(HashAlgorithm_t.CUSTOM, poly1) hash_2;
    Hash<bit<32>>(HashAlgorithm_t.CUSTOM, poly1) hash_3;
    Hash<bit<32>>(HashAlgorithm_t.CUSTOM, poly1) hash_4;
    Hash<bit<32>>(HashAlgorithm_t.CUSTOM, poly1) hash_5;
    Hash<bit<32>>(HashAlgorithm_t.CUSTOM, poly1) hash_6;

    action action_hash_1() {
        result_1 = (bit<32>) hash_1.get({hdr.ipv4.src_addr});
    }
    action action_hash_2() {
        result_2 = (bit<32>) hash_2.get({hdr.ipv4.dst_addr});
    }
    action action_hash_3() {
        result_3 = (bit<32>) hash_3.get({hdr.ipv4.src_addr, ig_md.src_port});
    }
    action action_hash_4() {
        result_4 = (bit<32>) hash_4.get({hdr.ipv4.dst_addr, ig_md.dst_port});
    }
    action action_hash_5() {
        result_5 = (bit<32>) hash_5.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr});
    }
    action action_hash_6() {
        result_6 = (bit<32>) hash_6.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, ig_md.src_port, ig_md.dst_port, hdr.ipv4.protocol});
    }
    apply {
        action_hash_1();
        action_hash_2();
        action_hash_3();
        action_hash_4();
        action_hash_5();
        action_hash_6();
    }
}


// #define PLAIN_HASH_SRCIP(TOTAL_LENGTH, HASH_LENGTH)                 \
//   control HASH_COMPUTE_SRCIP_##TOTAL_LENGTH##_##HASH_LENGTH## (     \
//     in ipv4_addr_t srcIP,                                           \
//     out bit<##TOTAL_LENGTH##> result)(                              \
//     bit<32> polynomial)                                             \
//   {                                                                 \
//       CRCPolynomial<bit<32>>(polynomial,                            \
//                              true,                                  \
//                              false,                                 \
//                              false,                                 \
//                              32w0xFFFFFFFF,                         \
//                              32w0xFFFFFFFF                          \
//                              ) poly1;                               \
//                                                                     \
//       Hash<bit<##HASH_LENGTH##>>(HashAlgorithm_t.CUSTOM, poly1) hash;\
//                                                                     \
//       action action_hash() {                                        \
//           result = (bit<##TOTAL_LENGTH##>) hash.get({srcIP});       \
//       }                                                             \
//                                                                     \
//       table tbl_hash {                                              \
//           actions = {                                               \
//               action_hash;                                          \
//           }                                                         \
//           const default_action = action_hash();                     \
//       }                                                             \
//                                                                     \
//      apply {                                                        \
//           tbl_hash.apply();                                         \
//       }                                                             \
//   }

// PLAIN_HASH_SRCIP(12, 12)
// PLAIN_HASH_SRCIP(15, 15)

// PLAIN_HASH_SRCIP(16, 5)
// PLAIN_HASH_SRCIP(16, 11)
// PLAIN_HASH_SRCIP(16, 12)
// PLAIN_HASH_SRCIP(16, 16)

// PLAIN_HASH_SRCIP(20, 20)

// PLAIN_HASH_SRCIP(32, 11)
// PLAIN_HASH_SRCIP(32, 20)

// #define PLAIN_HASH_SRCIP_DSTIP(TOTAL_LENGTH, HASH_LENGTH)           \
//   control HASH_COMPUTE_SRCIP_DSTIP_##TOTAL_LENGTH##_##HASH_LENGTH## (\
//     in ipv4_addr_t srcIP,                                           \
//     in ipv4_addr_t dstIP,                                           \
//     out bit<##TOTAL_LENGTH##> result)(                              \
//     bit<32> polynomial)                                             \
//   {                                                                 \
//       CRCPolynomial<bit<32>>(polynomial,                            \
//                              true,                                  \
//                              false,                                 \
//                              false,                                 \
//                              32w0xFFFFFFFF,                         \
//                              32w0xFFFFFFFF                          \
//                              ) poly1;                               \
//                                                                     \
//       Hash<bit<##HASH_LENGTH##>>(HashAlgorithm_t.CUSTOM, poly1) hash;\
//                                                                     \
//       action action_hash() {                                        \
//           result = (bit<##TOTAL_LENGTH##>) hash.get({srcIP[31:0], dstIP[31:0]}); \
//       }                                                             \
//                                                                     \
//       table tbl_hash {                                              \
//           actions = {                                               \
//               action_hash;                                          \
//           }                                                         \
//           const default_action = action_hash();                     \
//       }                                                             \
//                                                                     \
//      apply {                                                        \
//           tbl_hash.apply();                                         \
//       }                                                             \
//   }

// PLAIN_HASH_SRCIP_DSTIP(16, 16)
// PLAIN_HASH_SRCIP_DSTIP(16, 11)
// PLAIN_HASH_SRCIP_DSTIP(32, 32)

// control CS_UPDATE(
//   in bit<32> key,
//   in bit<1> res,
//   out bit<32> est)(
//   bit<32> polynomial)
// {
//     CRCPolynomial<bit<32>>(polynomial,                          
//                          true,                                  
//                          false,                                 
//                          false,                                 
//                          32w0xFFFFFFFF,                         
//                          32w0xFFFFFFFF                          
//                          ) poly1;                               
                                                                
//     Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

//     Register<bit<32>, bit<16>>(32w4096) cs_table;

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
//         est = cs_action.execute(hash.get({key}));
//         if (res == 0) {
//             est = -est;
//         }
//     }
// }

// control CM_UPDATE(
//   in bit<32> key,
//   out bit<32> est)(
//   bit<32> polynomial)
// {
//     CRCPolynomial<bit<32>>(polynomial,                          
//                          true,                                  
//                          false,                                 
//                          false,                                 
//                          32w0xFFFFFFFF,                         
//                          32w0xFFFFFFFF                          
//                          ) poly1;                               
                                                                
//     Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

//     Register<bit<32>, bit<16>>(32w4096) cs_table;

//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             register_data = register_data + 1;
//             result = register_data;
//         }
//     };

//     apply {
//         est = cs_action.execute(hash.get({key}));
//     }
// }

// control CALC_RNG(out bit<5> random_number)
// {
//     Random<bit<5>>() rng;
//     action get_random() {
//         random_number = rng.get();
//     }
//     table random {
//         actions = { get_random; }
//         default_action = get_random();
//         size = 1;
//     }
//     apply {
//         random.apply();
//     }
// }
