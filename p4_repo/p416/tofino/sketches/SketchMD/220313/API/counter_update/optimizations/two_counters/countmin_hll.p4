#define TC_CM_HASH_BITS 12
#define TC_CM_SIZE 4096

control TC_CM_UPDATE_TYPE2_16(
  in bit<16> key1,
  in bit<16> size,
  in bit<32> level,
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

    Hash<bit<TC_CM_HASH_BITS>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<32>>(TC_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<TC_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            if (level > register_data.second) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1}));
    }
}

control TC_CM_UPDATE_TYPE2_32(
  in bit<32> key1,
  in bit<16> size,
  in bit<32> level,
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

    Hash<bit<TC_CM_HASH_BITS>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<32>>(TC_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<TC_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            register_data.second = register_data.second | level;
            // if (level > register_data.second) {
            //     register_data.second = level;
            // }
            result = register_data.first;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1}));
    }
}


control TC_CM_UPDATE_TYPE2_32_16(
  in bit<32> key1,
  in bit<16> key2,
  in bit<16> size,
  in bit<32> level,
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

    Hash<bit<TC_CM_HASH_BITS>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<32>>(TC_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<TC_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            if (level > register_data.second) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1, key2}));
    }
}


control TC_CM_UPDATE_TYPE2_32_32(
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> size,
  in bit<32> level,
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

    Hash<bit<TC_CM_HASH_BITS>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<32>>(TC_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<TC_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            if (level > register_data.second) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1, key2}));
    }
}

control TC_CM_UPDATE_TYPE2_32_32_16_16(
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> key3,
  in bit<16> key4,
  in bit<16> size,
  in bit<32> level,
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

    Hash<bit<TC_CM_HASH_BITS>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<32>>(TC_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<TC_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            if (level > register_data.second) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1, key2, key3, key4}));
    }
}

control TC_CM_UPDATE_TYPE2_32_32_16_16_8(
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> key3,
  in bit<16> key4,
  in bit<8> key5,
  in bit<16> size,
  in bit<32> level,
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

    Hash<bit<TC_CM_HASH_BITS>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<32>>(TC_CM_SIZE) cm_ca;

    RegisterAction<pair, bit<TC_CM_HASH_BITS>, bit<32>>(cm_ca) cm_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            register_data.first = register_data.first+1;
            if (level > register_data.second) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    apply {
        est = cm_ca_action.execute(hash.get({key1, key2, key3, key4, key5}));
    }
}
