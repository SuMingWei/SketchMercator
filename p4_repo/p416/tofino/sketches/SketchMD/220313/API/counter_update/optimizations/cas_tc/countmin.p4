#define TC_CAS_CM_SIZE 16384
#define TC_CAS_CM_HASH_BITS 13 // 8192

#define STAGE00 6
#define STAGE01 5
#define STAGE02 4
#define STAGE03 3
#define STAGE04 2
#define STAGE05 1

#define STAGE06 0
#define STAGE07 -1
#define STAGE08 -2
#define STAGE09 -3
#define STAGE10 -4
#define STAGE11 -5

control TC_CAS_CM(
  in bit<16> index,
  in bit<16> psize,
  out bit<32> est)
{
    Register<pair, bit<32>>(TC_CAS_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<16>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            register_data.second = register_data.second+(bit<32>)psize;
            result = register_data.first;
        }
    };

    action ca_sketch_table_act()
    {
        est = cm_ca_action.execute(index);
    }
    @pragma placement_priority STAGE00
    table ca_sketch_table {
        actions = {
            ca_sketch_table_act;
        }
        const default_action = ca_sketch_table_act;
        size = 16;
    }

    apply {
        // est = cm_ca_action.execute(index);
        ca_sketch_table.apply();
    }
}

#define TC_CAS_CM_CS_SIZE 20480 // 4096 + 16384, 1 square = 2048
#define TC_CAS_CM_CS_HASH_BITS 15

control TC_CAS_CS_CM(
  in bit<16> index,
  in bit<1> res,
  out bit<32> est)
{
    Register<pair, bit<32>>(TC_CAS_CM_CS_SIZE) cm_cs_ca;

    RegisterAction<pair, bit<16>, bit<32>>(cm_cs_ca) cm_cs_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if(res == 1) {
                register_data.first = register_data.first+1;
            }
            else {
                register_data.first = register_data.first-1;
            }
            register_data.second = register_data.second+1;
            result = register_data.first;
        }
    };

    action ca_sketch_table_act()
    {
        est = cm_cs_ca_action.execute(index);
    }
    @pragma placement_priority STAGE00
    table ca_sketch_table {
        actions = {
            ca_sketch_table_act;
        }
        const default_action = ca_sketch_table_act;
        size = 16;
    }

    apply {
        // est = cm_ca_action.execute(index);
        ca_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
    }
}

// control TC_CAS_CM(
//   in bit<TC_CAS_CM_HASH_BITS> index1,
//   in bit<TC_CAS_CM_HASH_BITS> index2,
//   in bit<16> size,
//   in bit<1> rand,
//   out bit<32> est)
// {
//     bit<16> index;

//     Register<pair, bit<32>>(TC_CAS_CM_SIZE) cm_ca;

//     RegisterAction<pair, bit<16>, bit<32>>(cm_ca) cm_ca_action = {
//         void apply(inout pair register_data, out bit<32> result) {
//             register_data.first = register_data.first+1;
//             register_data.second = register_data.second+(bit<32>)size;
//             result = register_data.first;
//         }
//     };

//     apply {
//         // if (rand == 0) {
//         index = (bit<16>)index1;
//         // }
//         // else {
//         //     index = 8192 + (bit<16>)index2;
//         // }
//         est = cm_ca_action.execute(index);
//     }
// // }

// control TC_CAS_CM_2(
//   in bit<TC_CAS_CM_HASH_BITS> index1,
//   in bit<TC_CAS_CM_HASH_BITS> index2,
//   in bit<16> psize,
//   in bit<1> rand,
//   out bit<32> est)
// {
//     bit<TC_CAS_CM_HASH_BITS> index;

//     Register<pair, bit<32>>(TC_CAS_CM_SIZE) cm_ca;

//     RegisterAction<pair, bit<TC_CAS_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
//         void apply(inout pair register_data, out bit<32> result) {
//             register_data.first = register_data.first+1;
//             register_data.second = register_data.second+(bit<32>)psize;
//             result = register_data.first;
//         }
//     };

//     action ca_sketch_table_act()
//     {
//         est = cm_ca_action.execute(index1);
//     }
//     @pragma placement_priority STAGE00
//     table ca_sketch_table {
//         actions = {
//             ca_sketch_table_act;
//         }
//         const default_action = ca_sketch_table_act;
//         size = 16;
//     }

//     apply {
//         // if (rand == 0) {
//         //     index = index1;
//         // }
//         // else {
//         //     index = index2;
//         //     // index = 8192 + (bit<16>)index2;
//         // }
//         // est = cm_ca_action.execute(index1);
//         ca_sketch_table.apply();
//     }
// }

// control TC_CAS_CM_3(
//   in bit<TC_CAS_CM_HASH_BITS> index1,
//   in bit<TC_CAS_CM_HASH_BITS> index2,
//   in bit<16> psize,
//   in bit<1> rand,
//   out bit<32> est)
// {
//     bit<TC_CAS_CM_HASH_BITS> index;

//     Register<pair, bit<32>>(TC_CAS_CM_SIZE) cm_ca;

//     RegisterAction<pair, bit<TC_CAS_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
//         void apply(inout pair register_data, out bit<32> result) {
//             register_data.first = register_data.first+1;
//             register_data.second = register_data.second+(bit<32>)psize;
//             result = register_data.first;
//         }
//     };

//     action ca_sketch_table_act()
//     {
//         est = cm_ca_action.execute(index2);
//     }
//     @pragma placement_priority STAGE00
//     table ca_sketch_table {
//         actions = {
//             ca_sketch_table_act;
//         }
//         const default_action = ca_sketch_table_act;
//         size = 16;
//     }

//     apply {
//         // if (rand == 0) {
//         //     index = index1;
//         // }
//         // else {
//         //     index = index2;
//         //     // index = 8192 + (bit<16>)index2;
//         // }
//         // est = cm_ca_action.execute(index2);
//         ca_sketch_table.apply();
//     }
// }

// control TC_CAS_CM_4(
//   in bit<TC_CAS_CM_HASH_BITS> index1,
//   in bit<TC_CAS_CM_HASH_BITS> index2,
//   in bit<16> psize,
//   in bit<1> rand,
//   out bit<32> est)
// {
//     bit<TC_CAS_CM_HASH_BITS> index;

//     Register<pair, bit<32>>(TC_CAS_CM_SIZE) cm_ca;

//     RegisterAction<pair, bit<TC_CAS_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
//         void apply(inout pair register_data, out bit<32> result) {
//             register_data.first = register_data.first+1;
//             register_data.second = register_data.second+(bit<32>)psize;
//             result = register_data.first;
//         }
//     };

//     action ca_sketch_table_act()
//     {
//         est = cm_ca_action.execute(index);
//     }
//     @pragma placement_priority STAGE00
//     table ca_sketch_table {
//         actions = {
//             ca_sketch_table_act;
//         }
//         const default_action = ca_sketch_table_act;
//         size = 16;
//     }

//     apply {
//         if (rand == 0) {
//             index = index1;
//         }
//         else {
//             index = index2;
//             // index = 8192 + (bit<16>)index2;
//         }
//         // est = cm_ca_action.execute(index);
//         ca_sketch_table.apply();
//     }
// }




// control TC_CAS_CM_P(
//   in bit<TC_CAS_CM_HASH_BITS> index1,
//   in bit<TC_CAS_CM_HASH_BITS> index2,
//   in bit<16> psize,
//   in bit<1> rand,
//   out bit<32> est)
// {
//     bit<16> index;

//     Register<pair, bit<32>>(TC_CAS_CM_SIZE) cm_ca;

//     RegisterAction<pair, bit<16>, bit<32>>(cm_ca) cm_ca_action = {
//         void apply(inout pair register_data, out bit<32> result) {
//             register_data.first = register_data.first+1;
//             register_data.second = register_data.second+(bit<32>)psize;
//             result = register_data.first;
//         }
//     };

//     action ca_sketch_table_act()
//     {
//         est = cm_ca_action.execute(index);
//     }
//     @pragma placement_priority STAGE00
//     table ca_sketch_table {
//         actions = {
//             ca_sketch_table_act;
//         }
//         const default_action = ca_sketch_table_act;
//         size = 16;
//     }
//     apply {
//         // if (rand == 0) {
//         index = (bit<16>)index1;
//         // }
//         // else {
//         //     index = 8192 + (bit<16>)index2;
//         // }
//         ca_sketch_table.apply();
//     }
// }
