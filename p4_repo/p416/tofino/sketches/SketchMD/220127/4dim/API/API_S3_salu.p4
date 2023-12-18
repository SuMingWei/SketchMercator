control UM_UPDATE(
  in bit<BASE_BITLEN> index,
  in bit<1> res,
  in bit<BASE_BITLEN> base,
  inout bit<32> est)
{
    bit<BASE_BITLEN> masked_index;
    bit<BASE_BITLEN> mem_index;

    Register<bit<32>, bit<BASE_BITLEN>>(UM_TOTAL_SIZE) um_ca;

    RegisterAction<bit<32>, bit<BASE_BITLEN>, bit<32>>(um_ca) um_ca_action = {
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
        masked_index = index & 1023;
    }
    action step2() {
        mem_index = base + masked_index;
    }

    apply {
        step1();
        step2();
        est = um_ca_action.execute(mem_index);
        if (res == 0) {
            est = -est;
        }
    }
}

control SS_UPDATE(
  in bit<16> index,
  in bit<16> base,
  in bit<16> xyhash)
{
    bit<16> index_shift_mask;
    bit<16> xyhash_mask;
    bit<16> mem_index;

    Register<bit<1>, bit<16>>(65536) bitmap; // 2048 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };
    action step1() {
        index_shift_mask = index_shift_mask << 4;
        xyhash_mask = xyhash & 15;
    }

    action step2() {
        mem_index = base + xyhash_mask;
    }

    action step3() {
        mem_index = mem_index + index_shift_mask;
    }

    apply {
        step1();
        step2();
        step3();
        bitmap_action.execute(mem_index);
    }
}