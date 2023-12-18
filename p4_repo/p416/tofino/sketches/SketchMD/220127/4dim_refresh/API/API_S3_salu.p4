// control UM_SS_UPDATE_1(
//   in bit<16> index,
//   in bit<1> res,
//   in bit<16> um_base,
//   in bit<16> ss_base,
//   in bit<16> xyhash,
//   inout bit<32> est)
// {
//     bit<16> um_mem_index;
//     bit<16> ss_mem_index;
//     bit<16> xyhash_mask;

//     Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

//     RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             if (res == 0) {
//                 register_data = register_data-1;
//             }
//             else {
//                 register_data = register_data+1;
//             }
//             result = register_data;
//         }
//     };

//     Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

//     RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
//         void apply(inout bit<1> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     action step1() {
//         um_mem_index = um_base + index;
//         ss_mem_index = ss_base + index;
//         xyhash_mask = xyhash & 15360; // 0b11110000000000
//     }

//     action step2() {
//         ss_mem_index = ss_mem_index + xyhash_mask;
//     }

//     apply {
//         step1();
//         est = um_ca_action.execute(um_mem_index);
//         if (res == 0) {
//             est = -est;
//         }
//         step2();
//         bitmap_action.execute(ss_mem_index);
//     }
// }


// control UM_SS_UPDATE_2(
//   in bit<16> index,
//   in bit<1> res,
//   in bit<16> um_base,
//   in bit<16> ss_base_1,
//   in bit<16> xyhash_1,
//   in bit<16> ss_base_2,
//   in bit<16> xyhash_2,
//   inout bit<32> est)
// {
//     bit<16> um_mem_index;
//     bit<16> ss_mem_index_1;
//     bit<16> xyhash_mask_1;
//     bit<16> ss_mem_index_2;
//     bit<16> xyhash_mask_2;

//     Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

//     RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             if (res == 0) {
//                 register_data = register_data-1;
//             }
//             else {
//                 register_data = register_data+1;
//             }
//             result = register_data;
//         }
//     };

//     Register<bit<1>, bit<16>>(65536) bitmap_1; // 1024 * 4 * 16

//     RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap_1) bitmap_action_1 = {
//         void apply(inout bit<1> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     Register<bit<1>, bit<16>>(65536) bitmap_2; // 1024 * 4 * 16

//     RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap_2) bitmap_action_2 = {
//         void apply(inout bit<1> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     action step1() {
//         um_mem_index = um_base + index;
//         ss_mem_index_1 = ss_base_1 + index;
//         ss_mem_index_2 = ss_base_2 + index;
//         xyhash_mask_1 = xyhash_1 & 15360; // 0b11110000000000
//         xyhash_mask_2 = xyhash_2 & 15360; // 0b11110000000000
//     }

//     action step2() {
//         ss_mem_index_1 = ss_mem_index_1 + xyhash_mask_1;
//         ss_mem_index_2 = ss_mem_index_2 + xyhash_mask_2;
//     }

//     apply {
//         step1();
//         est = um_ca_action.execute(um_mem_index);
//         if (res == 0) {
//             est = -est;
//         }
//         step2();
//         bitmap_action_1.execute(ss_mem_index_1);
//         bitmap_action_2.execute(ss_mem_index_2);
//     }
// }
