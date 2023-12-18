struct pair {
    bit<32>     first;
    bit<32>     second;
}

control UM_SS_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
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

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control d_1_UM_SS_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
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

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE04
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE09
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control UM_SS_MRAC_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<pair, bit<16>>(16384) um_ca; // 1024 * 16
    RegisterAction<pair, bit<16>, bit<32>>(um_ca) um_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (res == 0) {
                register_data.first = register_data.first-1;
            }
            else {
                register_data.first = register_data.first+1;
            }
            result = register_data.first;
            register_data.second = register_data.second+1;
        }
    };

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}


control d_1_UM_SS_MRAC_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<pair, bit<16>>(16384) um_ca; // 1024 * 16
    RegisterAction<pair, bit<16>, bit<32>>(um_ca) um_ca_action = {
        void apply(inout pair register_data, out bit<32> result) {
            if (res == 0) {
                register_data.first = register_data.first-1;
            }
            else {
                register_data.first = register_data.first+1;
            }
            result = register_data.first;
            register_data.second = register_data.second+1;
        }
    };

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE04
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE09
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control d_2_UM_SS_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
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

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE05
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE10
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control d_2_UM_SS_MRAC_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<pair, bit<16>>(16384) um_ca; // 1024 * 16
    RegisterAction<pair, bit<16>, bit<32>>(um_ca) um_ca_action = {
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

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE05
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE10
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control d_3_UM_SS_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
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

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE07
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE11
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control d_3_UM_SS_MRAC_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  in bit<16> ss_base,
  in bit<16> xyhash,
  inout bit<32> est)
{
    bit<16> um_mem_index;
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<pair, bit<16>>(16384) um_ca; // 1024 * 16
    RegisterAction<pair, bit<16>, bit<32>>(um_ca) um_ca_action = {
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

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        um_mem_index = um_base + index;
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE07
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE11
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
        step2();
        ss_sketch_table.apply();
    }
}

control UM_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  inout bit<32> est)
{
    bit<16> um_mem_index;

    Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
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
        um_mem_index = um_base + index;
    }

    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }

    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
    }
}

control d_4_UM_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  inout bit<32> est)
{
    bit<16> um_mem_index;

    Register<bit<32>, bit<16>>(16384) um_ca; // 1024 * 16

    RegisterAction<bit<32>, bit<16>, bit<32>>(um_ca) um_ca_action = {
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
        um_mem_index = um_base + index;
    }

    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE06
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }

    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
    }
}

control UM_MRAC_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  inout bit<32> est)
{
    bit<16> um_mem_index;

    Register<pair, bit<16>>(16384) um_ca; // 1024 * 16
    RegisterAction<pair, bit<16>, bit<32>>(um_ca) um_ca_action = {
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
        um_mem_index = um_base + index;
    }

    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }

    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
    }
}

control d_4_UM_MRAC_UPDATE(
  in bit<16> index,
  in bit<1> res,
  in bit<16> um_base,
  inout bit<32> est)
{
    bit<16> um_mem_index;

    Register<pair, bit<16>>(16384) um_ca; // 1024 * 16
    RegisterAction<pair, bit<16>, bit<32>>(um_ca) um_ca_action = {
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
        um_mem_index = um_base + index;
    }

    action um_sketch_table_act()
    {
        est = um_ca_action.execute(um_mem_index);
    }
    @pragma placement_priority STAGE06
    table um_sketch_table {
        actions = {
            um_sketch_table_act;
        }
        const default_action = um_sketch_table_act;
        size = 16;
    }

    apply {
        step1();
        um_sketch_table.apply();
        if (res == 0) {
            est = -est;
        }
    }
}

control SS_UPDATE(
  in bit<16> index,
  in bit<16> ss_base,
  in bit<16> xyhash)
{
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        step2();
        ss_sketch_table.apply();
    }
}

control d_4_SS_UPDATE(
  in bit<16> index,
  in bit<16> ss_base,
  in bit<16> xyhash)
{
    bit<16> ss_mem_index;
    bit<16> xyhash_mask;

    Register<bit<1>, bit<16>>(65536) bitmap; // 1024 * 4 * 16

    RegisterAction<bit<1>, bit<16>, bit<32>>(bitmap) bitmap_action = {
        void apply(inout bit<1> register_data, out bit<32> result) {
            register_data = 1;
        }
    };

    action step1() {
        ss_mem_index = ss_base + index;
        xyhash_mask = xyhash & 15360; // 0b11110000000000
    }

    action step2() {
        ss_mem_index = ss_mem_index + xyhash_mask;
    }
    action ss_sketch_table_act()
    {
        bitmap_action.execute(ss_mem_index);
    }
    @pragma placement_priority STAGE10
    table ss_sketch_table {
        actions = {
            ss_sketch_table_act;
        }
        const default_action = ss_sketch_table_act;
        size = 16;
    }
    apply {
        step1();
        step2();
        ss_sketch_table.apply();
    }
}


control SS_UPDATE_LOG_KEY32 (
    in bit<32> key1,
    in bit<32> level)
    (bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<10>>(1024) store_max_level;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level) max_level_action = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
            }
        }
    };

    action ss_sketch_log_table_act()
    {
        max_level_action.execute(hash.get({key1}));
    }
    table ss_sketch_log_table {
        actions = {
            ss_sketch_log_table_act;
        }
        const default_action = ss_sketch_log_table_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table.apply();
    }
}

control SS_UPDATE_LOG_KEY32_STAGE2 (
    in bit<32> key1,
    in bit<32> level)
    (bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<10>>(1024) store_max_level;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level) max_level_action = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
            }
        }
    };

    action ss_sketch_log_table_act()
    {
        max_level_action.execute(hash.get({key1}));
    }
    @pragma placement_priority STAGE02
    table ss_sketch_log_table {
        actions = {
            ss_sketch_log_table_act;
        }
        const default_action = ss_sketch_log_table_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table.apply();
    }
}

control SS_UPDATE_LOG_KEY32_STAGE3 (
    in bit<32> key1,
    in bit<32> level)
    (bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<10>>(1024) store_max_level;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level) max_level_action = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
            }
        }
    };

    action ss_sketch_log_table_act()
    {
        max_level_action.execute(hash.get({key1}));
    }
    @pragma placement_priority STAGE03
    table ss_sketch_log_table {
        actions = {
            ss_sketch_log_table_act;
        }
        const default_action = ss_sketch_log_table_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table.apply();
    }
}

control SS_UPDATE_LOG_KEY32_STAGE4 (
    in bit<32> key1,
    in bit<32> level)
    (bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<10>>(1024) store_max_level;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level) max_level_action = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
            }
        }
    };

    action ss_sketch_log_table_act()
    {
        max_level_action.execute(hash.get({key1}));
    }
    @pragma placement_priority STAGE04
    table ss_sketch_log_table {
        actions = {
            ss_sketch_log_table_act;
        }
        const default_action = ss_sketch_log_table_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table.apply();
    }
}

control SS_UPDATE_LOG_KEY32_STAGE5 (
    in bit<32> key1,
    in bit<32> level)
    (bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    Register<pair, bit<10>>(1024) store_max_level;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level) max_level_action = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
            }
        }
    };

    action ss_sketch_log_table_act()
    {
        max_level_action.execute(hash.get({key1}));
    }
    @pragma placement_priority STAGE05
    table ss_sketch_log_table {
        actions = {
            ss_sketch_log_table_act;
        }
        const default_action = ss_sketch_log_table_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table.apply();
    }
}

control SS_UPDATE_LOG_KEY32_KEY32_KEY16 (
    in bit<32> key1,
    in bit<32> key2,
    in bit<16> key3,
    in bit<32> level)
    (bit<32> polynomial)
{
    bit<1> res;
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash1;

    Register<pair, bit<10>>(1024) store_max_level1;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level1) max_level_action1 = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
                res = 1;
            }
        }
    };

    action ss_sketch_log_table1_act()
    {
        res = max_level_action1.execute(hash1.get({key1, key2}));
    }
    table ss_sketch_log_table1 {
        actions = {
            ss_sketch_log_table1_act;
        }
        const default_action = ss_sketch_log_table1_act;
        size = 16;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly2;
    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly2) hash2;

    Register<pair, bit<10>>(1024) store_max_level2;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level2) max_level_action2 = {
        void apply(inout pair register_data, out bit<1> result) {
            register_data.first = key2;
            register_data.second = (bit<32>)key3;
        }
    };
    action ss_sketch_log_table2_act()
    {
        max_level_action2.execute(hash2.get({key1, key2}));
    }
    table ss_sketch_log_table2 {
        actions = {
            ss_sketch_log_table2_act;
        }
        const default_action = ss_sketch_log_table2_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table1.apply();
        if (res == 1) {
            ss_sketch_log_table2.apply();
        }
    }
}


control SS_UPDATE_LOG_KEY32_KEY32_KEY16_6_7 (
    in bit<32> key1,
    in bit<32> key2,
    in bit<16> key3,
    in bit<32> level)
    (bit<32> polynomial)
{
    bit<1> res;
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash1;

    Register<pair, bit<10>>(1024) store_max_level1;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level1) max_level_action1 = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
                res = 1;
            }
        }
    };

    action ss_sketch_log_table1_act()
    {
        res = max_level_action1.execute(hash1.get({key1, key2}));
    }
    @pragma placement_priority STAGE06
    table ss_sketch_log_table1 {
        actions = {
            ss_sketch_log_table1_act;
        }
        const default_action = ss_sketch_log_table1_act;
        size = 16;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly2;
    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly2) hash2;

    Register<pair, bit<10>>(1024) store_max_level2;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level2) max_level_action2 = {
        void apply(inout pair register_data, out bit<1> result) {
            register_data.first = key2;
            register_data.second = (bit<32>)key3;
        }
    };
    action ss_sketch_log_table2_act()
    {
        max_level_action2.execute(hash2.get({key1, key2}));
    }
    @pragma placement_priority STAGE07
    table ss_sketch_log_table2 {
        actions = {
            ss_sketch_log_table2_act;
        }
        const default_action = ss_sketch_log_table2_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table1.apply();
        if (res == 1) {
            ss_sketch_log_table2.apply();
        }
    }
}

control SS_UPDATE_LOG_KEY32_KEY32_KEY16_8_9 (
    in bit<32> key1,
    in bit<32> key2,
    in bit<16> key3,
    in bit<32> level)
    (bit<32> polynomial)
{
    bit<1> res;
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash1;

    Register<pair, bit<10>>(1024) store_max_level1;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level1) max_level_action1 = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
                res = 1;
            }
        }
    };

    action ss_sketch_log_table1_act()
    {
        res = max_level_action1.execute(hash1.get({key1, key2}));
    }
    @pragma placement_priority STAGE08
    table ss_sketch_log_table1 {
        actions = {
            ss_sketch_log_table1_act;
        }
        const default_action = ss_sketch_log_table1_act;
        size = 16;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly2;
    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly2) hash2;

    Register<pair, bit<10>>(1024) store_max_level2;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level2) max_level_action2 = {
        void apply(inout pair register_data, out bit<1> result) {
            register_data.first = key2;
            register_data.second = (bit<32>)key3;
        }
    };
    action ss_sketch_log_table2_act()
    {
        max_level_action2.execute(hash2.get({key1, key2}));
    }
    @pragma placement_priority STAGE09
    table ss_sketch_log_table2 {
        actions = {
            ss_sketch_log_table2_act;
        }
        const default_action = ss_sketch_log_table2_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table1.apply();
        if (res == 1) {
            ss_sketch_log_table2.apply();
        }
    }
}

control SS_UPDATE_LOG_KEY32_KEY32_KEY16_10_11 (
    in bit<32> key1,
    in bit<32> key2,
    in bit<16> key3,
    in bit<32> level)
    (bit<32> polynomial)
{
    bit<1> res;
    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash1;

    Register<pair, bit<10>>(1024) store_max_level1;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level1) max_level_action1 = {
        void apply(inout pair register_data, out bit<1> result) {
            if (level > register_data.first) {
                register_data.first = level;
                register_data.second = key1;
                res = 1;
            }
        }
    };

    action ss_sketch_log_table1_act()
    {
        res = max_level_action1.execute(hash1.get({key1, key2}));
    }
    @pragma placement_priority STAGE10
    table ss_sketch_log_table1 {
        actions = {
            ss_sketch_log_table1_act;
        }
        const default_action = ss_sketch_log_table1_act;
        size = 16;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly2;
    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly2) hash2;

    Register<pair, bit<10>>(1024) store_max_level2;
    RegisterAction<pair, bit<10>, bit<1>>(store_max_level2) max_level_action2 = {
        void apply(inout pair register_data, out bit<1> result) {
            register_data.first = key2;
            register_data.second = (bit<32>)key3;
        }
    };
    action ss_sketch_log_table2_act()
    {
        max_level_action2.execute(hash2.get({key1, key2}));
    }
    @pragma placement_priority STAGE11
    table ss_sketch_log_table2 {
        actions = {
            ss_sketch_log_table2_act;
        }
        const default_action = ss_sketch_log_table2_act;
        size = 16;
    }

    apply{
        ss_sketch_log_table1.apply();
        if (res == 1) {
            ss_sketch_log_table2.apply();
        }
    }
}
