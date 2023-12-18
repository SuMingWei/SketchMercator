control CM_UPDATE(
  in bit<32> key,
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

    Register<bit<32>, bit<10>>(32w1024) cm_ca;

    RegisterAction<bit<32>, bit<10>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
            result = register_data;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key}));
    }
}

control CM_UPDATE_32_32_32(
  in bit<32> key1,
  in bit<32> key2,
  in bit<32> key3,
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

    Register<bit<32>, bit<10>>(32w1024) cm_ca;

    RegisterAction<bit<32>, bit<10>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
            result = register_data;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1, key2, key3}));
    }
}

control CM_UPDATE_32_32_32_8(
  in bit<32> key1,
  in bit<32> key2,
  in bit<32> key3,
  in bit<8> key4,
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

    Register<bit<32>, bit<10>>(32w1024) cm_ca;

    RegisterAction<bit<32>, bit<10>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
            result = register_data;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1, key2, key3, key4}));
    }
}


