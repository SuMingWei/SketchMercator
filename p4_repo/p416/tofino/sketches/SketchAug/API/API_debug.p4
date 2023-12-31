control EPOCH_COUNT_1(inout bit<16> epoch_index)
{
    Register<bit<32>, bit<16>>(32w1024) cs_table;
    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            result = register_data;
        }
    };

    apply {
        epoch_index = (bit<16>)cs_action.execute(0);
    }
}

control EPOCH_COUNT_2(inout bit<16> epoch_index, inout bit<16> temp_index)
{
    Register<bit<32>, bit<16>>(32w1024) cs_table;
    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
        }
    };

    action fix() {
        temp_index = epoch_index+1;
    }

    apply {
        fix();
        cs_action.execute(temp_index);
        // cs_action_2.execute(0);
    }
}