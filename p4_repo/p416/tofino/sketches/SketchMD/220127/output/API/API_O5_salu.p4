// CS and HLL
struct pair {
    bit<32>     first;
    bit<32>     second;
}

control update_cs_and_hll(
in bit<32> index,
in bit<1> res,
in bit<32> level,
out bit<32> output)
{
    Register<pair, bit<32>>(2048) cs_table;

    RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (res == 0) {
                register_data.first = register_data.first + 1;
            }
            else {
                register_data.first = register_data.first - 1;
            }

            if (level > register_data.second) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    apply {
        output = cs_action.execute(index);
    }
}

control update_cs_and_cm(
in bit<32> index,
in bit<1> res,
out bit<32> output)
{
    Register<pair, bit<32>>(2048) cs_table;

    RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (res == 0) {
                register_data.first = register_data.first + 1;
            }
            else {
                register_data.first = register_data.first - 1;
            }

            register_data.second = register_data.second + 1;
            result = register_data.first;
        }
    };

    apply {
        output = cs_action.execute(index);
    }
}

control update_cm_and_cm(
in bit<32> index,
out bit<32> output)
{
    Register<pair, bit<32>>(1024) cs_table;

    RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first + 1;
            register_data.second = register_data.second + 1;
            result = register_data.first;
        }
    };

    apply {
        output = cs_action.execute(index);
    }
}

// // CS and CM -> we have to set the cs or cm output
// struct pair {
//     bit<32>     first;
//     bit<32>     second;
// }

// control CS_UPDATE_64(
// in bit<32> index,
// in bit<32> var1,
// in bit<32> var2,
// in bit<32> var3,
// in bit<32> key)
// {
//     Register<pair, bit<32>>(65536) cs_table;

//     RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
//         void apply(inout pair register_data, out bit<32> result) {
//             if (var1 == 0) {
//                 register_data.first = register_data.first + 1;
//             }
//             else {
//                 register_data.first = register_data.first - 1;
//             }
//             register_data.second = register_data.second + 1;

//             result = register_data.first;
//             // result = register_data.second; // we cannot do both
//         }
//     };

//     apply {
//         cs_action.execute(index);
//     }
// }




// control consolidate_update_univmon(
//   in bit<16> index,
//   in bit<1> res,
//   inout bit<16> level,
//   inout bit<16> base,
//   inout bit<16> mem_index,
//   out bit<32> est)
// {

//     Register<bit<32>, bit<16>>(45056) cs_table;

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
//     // action shift_action() {
//     //     base = (level << 11);
//     // }
//     // action add_action() {
//     //     mem_index = index+base;
//     // }
//     apply {
//         // shift_action();
//         // add_action();
//         est = cs_action.execute(mem_index);
//         if (res == 0) {
//             est = -est;
//         }
//     }
// }

// control consolidate_update_rhhh(
//   in bit<16> index,
//   in bit<1> res,
//   inout bit<16> level,
//   inout bit<16> base,
//   inout bit<16> mem_index,
//   out bit<32> est)
// {

//     Register<bit<32>, bit<16>>(51200) cs_table;

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
//     action shift_action() {
//         base = (level << 11);
//     }
//     action add_action() {
//         mem_index = index+base;
//     }
//     apply {
//         shift_action();
//         add_action();
//         est = cs_action.execute(mem_index);
//         if (res == 0) {
//             est = -est;
//         }
//     }
// }

// control consolidate_update_mrac(
//   in bit<16> index,
//   inout bit<16> level,
//   inout bit<16> base,
//   inout bit<16> mem_index)
// {
//     Register<bit<32>, bit<16>>(24576) cs_table;

//     RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<32> register_data, out bit<32> result) {
//             register_data = register_data + 1;
//         }
//     };
//     action shift_action() {
//         base = (level << 11);
//     }
//     action add_action() {
//         mem_index = base + index;
//     }
//     apply {
//         shift_action();
//         add_action();
//         cs_action.execute(mem_index);
//     }
// }

// control consolidate_update_mrb(
//   in bit<16> index,
//   inout bit<16> level,
//   inout bit<16> base,
//   inout bit<16> mem_index)
// {
//     Register<bit<1>, bit<16>>(65536) cs_table;

//     RegisterAction<bit<1>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<1> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     action shift_action() {
//         base = (level << 12);
//     }
//     action add_action() {
//         mem_index = index+base;
//     }
//     apply {
//         shift_action();
//         add_action();
//         cs_action.execute(mem_index);
//     }
// }

// control consolidate_update_pcsa(
//   in bit<16> index,
//   inout bit<16> level,
//   inout bit<16> base,
//   inout bit<16> mem_index)
// {
//     Register<bit<1>, bit<16>>(1024) cs_table;

//     RegisterAction<bit<1>, bit<16>, bit<32>>(cs_table) cs_action = {
//         void apply(inout bit<1> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     action shift_action() {
//         base = (index << 5);
//     }

//     action add_action() {
//         mem_index = base + level;
//     }

//     apply {
//         shift_action();
//         add_action();
//         cs_action.execute(mem_index);
//     }
// }

// control consolidate_update_ss(
//   in bit<32> index,
//   inout bit<32> level,
//   inout bit<32> base_1,
//   inout bit<32> base_2,
//   inout bit<32> mem_index)
// {
//     Register<bit<1>, bit<32>>(262144) bitmap;

//     RegisterAction<bit<1>, bit<32>, bit<32>>(bitmap) bitmap_action = {
//         void apply(inout bit<1> register_data, out bit<32> result) {
//             register_data = 1;
//         }
//     };

//     action shift_action() {
//         base_1 = (index << 7);
//         base_2 = (level << 5);
//     }

//     action add_action() {
//         mem_index = base_1 + base_2;
//     }
//     action add_action_2() {
//         mem_index = mem_index + (bit<32>)index[4:0];
//     }

//     apply {
//         shift_action();
//         add_action();
//         add_action_2();

//         bitmap_action.execute(mem_index);
//     }
// }
