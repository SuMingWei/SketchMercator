struct pair {
    bit<32>     first;
    bit<32>     second;
}

control UM_MRAC_UPDATE(
  in bit<32> index, // 10bit
  in bit<1> res,
  inout bit<32> base,
  inout bit<32> est)
{
    bit<32> mem_index;

    Register<pair, bit<32>>(1024) um_ca;

    RegisterAction<pair, bit<32>, bit<32>>(um_ca) um_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (res == 0) {
                register_data.first = register_data.first-1;
            }
            else {
                register_data.first = register_data.first+1;
            }
            register_data.second = register_data.second+1;
            result = register_data.first;
        }
    };

    action step1() {
        mem_index = base + index;
    }

    apply {
        step1();
        est = um_ca_action.execute(mem_index);
        if (res == 0) {
            est = -est;
        }
    }
}

control UM_UPDATE(
  in bit<32> index, // 10bit
  in bit<1> res,
  inout bit<32> base,
  inout bit<32> est)
{
    bit<32> mem_index;

    Register<bit<32>, bit<32>>(1024) um_ca;

    RegisterAction<bit<32>, bit<32>, bit<32>>(um_ca) um_ca_action = {
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

    action step1() {
        mem_index = base + index;
    }

    apply {
        step1();
        est = um_ca_action.execute(mem_index);
        if (res == 0) {
            est = -est;
        }
    }
}


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

control ENT_UPDATE(
  in bit<32> key)(
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

    Register<bit<32>, bit<10>>(32w1024) ent_ca;

    RegisterAction<bit<32>, bit<10>, bit<32>>(ent_ca) ent_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
        }
    };

    apply {
        ent_ca_action.execute(hash.get({key}));
    }
}

control HLL_UPDATE(
  in bit<32> key,
  in bit<32> level)(
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

    Register<bit<32>, bit<10>>(32w1024) ent_ca;

    RegisterAction<bit<32>, bit<10>, bit<32>>(ent_ca) ent_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (level > register_data) {
                register_data = level;
            }
        }
    };

    apply {
        ent_ca_action.execute(hash.get({key}));
    }
}

control KARY_UPDATE(
  in bit<32> key,
  in bit<1> epoch,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash1;
    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash2;

    Register<bit<32>, bit<16>>(32w1024) kary_ca_0;

    RegisterAction<bit<32>, bit<16>, bit<32>>(kary_ca_0) kary_ca_0_write = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if(epoch == 0) {
                register_data = register_data + 1;
            }
            result = register_data;
        }
    };

    Register<bit<32>, bit<16>>(32w1024) kary_ca_1;
    RegisterAction<bit<32>, bit<16>, bit<32>>(kary_ca_1) kary_ca_1_write = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if(epoch == 1) {
                register_data = register_data + 1;
            }
            result = register_data;
        }
    };

    apply {
        bit<32> first_read;
        first_read = kary_ca_0_write.execute(hash1.get({key}));

        bit<32> second_read;
        second_read = kary_ca_1_write.execute(hash2.get({key}));

        if (epoch == 0) {
            est = first_read - second_read;
        }
        else {
            est = second_read - first_read;
        }
    }
}

control KARY_CM_HLL_UPDATE(
  in bit<32> key,
  in bit<1> epoch,
  in bit<32> level,
  out bit<32> est,
  out bit<32> cm_est)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash1;
    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash2;

    Register<pair, bit<16>>(32w1024) kary_ca_0;

    RegisterAction<pair, bit<16>, bit<32>>(kary_ca_0) kary_ca_0_write = {
        void apply(inout pair register_data, out bit<32> result) {
            if(epoch == 0) {
                register_data.first = register_data.first + 1;
            }
            if(register_data.second > level) {
                register_data.second = level;
            }
            result = register_data.first;
        }
    };

    Register<bit<32>, bit<16>>(32w1024) kary_ca_1;
    RegisterAction<bit<32>, bit<16>, bit<32>>(kary_ca_1) kary_ca_1_write = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if(epoch == 1) {
                register_data = register_data + 1;
            }
            result = register_data;
        }
    };

    apply {
        bit<32> first_read;
        first_read = kary_ca_0_write.execute(hash1.get({key}));

        bit<32> second_read;
        second_read = kary_ca_1_write.execute(hash2.get({key}));

        if (epoch == 0) {
            est = first_read - second_read;
            cm_est = first_read;
        }
        else {
            est = second_read - first_read;
            cm_est = second_read;
        }
    }
}

control KARY_CM_UPDATE(
  in bit<32> key,
  in bit<1> epoch,
  out bit<32> est,
  out bit<32> cm_est)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash1;
    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash2;

    Register<bit<32>, bit<16>>(32w1024) kary_ca_0;

    RegisterAction<bit<32>, bit<16>, bit<32>>(kary_ca_0) kary_ca_0_write = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if(epoch == 0) {
                register_data = register_data + 1;
            }
            result = register_data;
        }
    };

    Register<bit<32>, bit<16>>(32w1024) kary_ca_1;
    RegisterAction<bit<32>, bit<16>, bit<32>>(kary_ca_1) kary_ca_1_write = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if(epoch == 1) {
                register_data = register_data + 1;
            }
            result = register_data;
        }
    };

    apply {
        bit<32> first_read;
        first_read = kary_ca_0_write.execute(hash1.get({key}));

        bit<32> second_read;
        second_read = kary_ca_1_write.execute(hash2.get({key}));

        if (epoch == 0) {
            est = first_read - second_read;
            cm_est = first_read;
        }
        else {
            est = second_read - first_read;
            cm_est = second_read;
        }
    }
}

control MRB_UPDATE(
  in bit<32> base,
  in bit<32> index)
{
    bit<32> mem_index;

    Register<bit<1>, bit<32>>(16384) mrb_ca; // 1024 * 16

    RegisterAction<bit<1>, bit<32>, bit<32>>(mrb_ca) mrb_ca_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action add_action() {
        mem_index = index+base;
    }
    apply {
        add_action();
        mrb_ca_action.execute(mem_index);
    }
}

control MRAC_UPDATE(
  in bit<32> base,
  in bit<32> index)
{
    bit<32> mem_index;

    Register<bit<32>, bit<32>>(16384) mrac_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<32>, bit<32>>(mrac_ca) mrac_ca_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            register_data = register_data + 1;
        }
    };

    action add_action() {
        mem_index = index+base;
    }
    apply {
        add_action();
        mrac_ca_action.execute(mem_index);
    }
}

control SS_UPDATE(
  in bit<32> index, // 11bit
  in bit<32> xyhash,
  inout bit<32> short_level)
{
    bit<32> base_1;
    bit<32> base_2;
    bit<32> mem_index;

    Register<bit<1>, bit<32>>(262144) bitmap;

    RegisterAction<bit<1>, bit<32>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        base_1 = (index << 7);
        mem_index = (bit<32>)xyhash[4:0];
    }

    action step2() {
        base_2 = (short_level << 5);
        mem_index = mem_index + base_1;
    }

    action step3() {
        mem_index = mem_index + base_2;
    }

    apply {
        step1();
        step2();
        step3();
        bitmap_action.execute(mem_index);
    }
}

control SS_UPDATE_LOG (
    in bit<32> srcIP,
    in bit<32> index,
    in bit<32> level)
{
    Register<pair, bit<32>>(2048) store_max_level;

    RegisterAction<pair, bit<32>, bit<1>>(store_max_level) max_level_action = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = srcIP;
            }
        }
    };

    apply{
        max_level_action.execute(index);
    }
}
