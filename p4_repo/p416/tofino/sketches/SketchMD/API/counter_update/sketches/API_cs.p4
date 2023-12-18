control CS_UPDATE(
  in bit<32> key,
  in bit<1> res,
  out bit<32> est)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<bit<32>, bit<10>>(32w1024) cs_ca;

    RegisterAction<bit<32>, bit<10>, bit<32>>(cs_ca) cs_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (res == 0) {
                register_data = register_data-1;
            }
            else {
                register_data = register_data+1;
            }
            result = register_data;
        }
    };

    apply {
        est = cs_ca_action.execute(hash.get({key}));
        if (res == 0) {
            est = -est;
        }
    }
}
