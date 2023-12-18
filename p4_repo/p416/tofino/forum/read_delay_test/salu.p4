control CS_UPDATE(
  in bit<16> index,
  out bit<32> est)
{
    // Register<bit<32>, bit<16>>(32w2048) cs_table;
    // Register<bit<32>, bit<16>>(32w4096) cs_table;
    // Register<bit<32>, bit<16>>(32w8192) cs_table;
    Register<bit<32>, bit<16>>(32w16384) cs_table;
    // Register<bit<32>, bit<16>>(32w32768) cs_table;
    // Register<bit<32>, bit<16>>(32w65536) cs_table;
    // Register<bit<32>, bit<16>>(32w512) cs1;

    RegisterAction<bit<32>, bit<16>, bit<32>>(cs_table) cs_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
            result = register_data;
        }
    };

    apply {
        est = cs_action.execute(index);
    }
}
