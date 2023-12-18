// // CS and HLL
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

//             if (var2 > register_data.second) {
//                 register_data.second = var2;
//             }
//             result = register_data.first;
//         }
//     };

//     apply {
//         cs_action.execute(index);
//     }
// }

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


// CS and bitmap32
struct pair {
    bit<32>     first;
    bit<16>     second;
}

control CS_UPDATE_64(
in bit<32> index,
in bit<32> var1,
in bit<32> var2,
in bit<32> var3,
in bit<32> key)
{
    Register<pair, bit<32>>(65536) cs_table;

    RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (var1 == 0) {
                register_data.first = register_data.first + 1;
            }
            else {
                register_data.first = register_data.first - 1;
            }
            register_data.second = register_data.second | var2;

            result = register_data.first;
            // result = register_data.second; // we cannot do both
        }
    };

    apply {
        cs_action.execute(index);
    }
}
