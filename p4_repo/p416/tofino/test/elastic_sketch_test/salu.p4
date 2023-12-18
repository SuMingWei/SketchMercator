struct pair {
    bit<32>     first;
    bit<32>     second;
}
// in bit<32> evicted_count,

control CS_UPDATE_64(
in bit<32> index,
in bit<32> vote_all,
in bit<32> evicted_count,
in bit<32> key)
{
    Register<pair, bit<32>>(65536) cs_table;

    // compilation success
    RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (key == register_data.first) {
                register_data.second = register_data.second + 1;
            }
            if (vote_all > register_data.second) {
                register_data.first = key;
                register_data.second = 0;
            }
            result = register_data.first;
        }
    };

    // // compilation fail 1 - too many metadata,
    // RegisterAction<pair, bit<32>, bit<32>>(cs_table) cs_action = {
    //     void apply(inout pair register_data, out bit<32> result) {
    //         if (key == register_data.first) {
    //             register_data.second = register_data.second + evicted_count;
    //         }
    //         if (vote_all > register_data.second) {
    //             register_data.first = key;
    //             register_data.second = 0;
    //         }
    //         result = register_data.first;
    //     }
    // };

    // // [FCM sketch] 
    // // It needs to swap a key-value pair stored in registers with metadata (or PHV) fields during eviction.
    // // However, existing stateful ALUs can modify only a limited number of fields in a single stage.

    // // compilation fail 2 - SALU can not output 64 bit to metadata. 
    // RegisterAction<pair, bit<32>, pair>(cs_table) cs_action = {
    //     void apply(inout pair register_data, out pair result) {
    //         if (key == register_data.first) {
    //             register_data.second = register_data.second + 1;
    //         }
    //         if (vote_all > register_data.second) {
    //             register_data.first = key;
    //             register_data.second = 0;
    //         }
    //     }
    // };

    apply {
        cs_action.execute(index);
    }
}
