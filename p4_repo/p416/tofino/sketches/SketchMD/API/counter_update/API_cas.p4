control CA_SAMPLING(
  in bit<10> index1,
  in bit<10> index2,
  in bit<1> rand,
  out bit<32> est)
{
    bit<16> index;

    Register<bit<32>, bit<16>>(32w2048) cm_ca;

    RegisterAction<bit<32>, bit<16>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
            result = register_data;
        }
    };

    apply {
        if (rand == 0) {
            index = (bit<16>)index1;
        }
        else {
            index = 1024 + (bit<16>)index2;
        }
        est = cm_ca_action.execute(index);
    }
}
