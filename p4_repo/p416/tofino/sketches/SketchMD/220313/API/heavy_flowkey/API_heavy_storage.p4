#define HT_SIZE 32768
#define HT_BITLEN 15


control heavy_flowkey_storage_four_tuple_full (
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    in bit<32> srcip,
    in bit<32> dstip,
    in bit<16> src_port,
    in bit<16> dst_port)
    (bit<32> polynomial)
{
    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) srcip_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(srcip_hash_table) srcip_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = srcip;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) dstip_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(dstip_hash_table) dstip_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = dstip;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<16>, bit<HT_BITLEN>>(HT_SIZE) src_port_hash_table;
    RegisterAction<bit<16>, bit<HT_BITLEN>, bit<16>>(src_port_hash_table) src_port_action = {
        void apply(inout bit<16> register_data, out bit<16> result) {
            if (register_data == 0) {
                register_data = src_port;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<16>, bit<HT_BITLEN>>(HT_SIZE) dst_port_hash_table;
    RegisterAction<bit<16>, bit<HT_BITLEN>, bit<16>>(dst_port_hash_table) dst_port_action = {
        void apply(inout bit<16> register_data, out bit<16> result) {
            if (register_data == 0) {
                register_data = dst_port;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    // exact table
    action tbl_exact_match_miss() {
        ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            srcip : exact;
            dstip : exact;
            src_port : exact;
            dst_port : exact;
        }
        actions = {
            tbl_exact_match_miss;
            tbl_exact_match_hit;
        }
        const default_action = tbl_exact_match_miss;
        size = 8192;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash1;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash2;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash3;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash4;

    bit<32> entry_srcip;
    bit<32> entry_dstip;
    bit<16> entry_src_port;
    bit<16> entry_dst_port;

    action srcip_ht_table_act()
    {
        entry_srcip = srcip_action.execute(hash1.get({srcip, dstip, src_port, dst_port}));
    }

    table srcip_ht_table {
        actions = {
            srcip_ht_table_act;
        }
        const default_action = srcip_ht_table_act;
        size = 16;
    }

    action dstip_ht_table_act()
    {
        entry_dstip = dstip_action.execute(hash2.get({srcip, dstip, src_port, dst_port}));
    }

    table dstip_ht_table {
        actions = {
            dstip_ht_table_act;
        }
        const default_action = dstip_ht_table_act;
        size = 16;
    }

    action src_port_ht_table_act()
    {
        entry_src_port = src_port_action.execute(hash3.get({srcip, dstip, src_port, dst_port}));
    }

    table src_port_ht_table {
        actions = {
            src_port_ht_table_act;
        }
        const default_action = src_port_ht_table_act;
        size = 16;
    }

    action dst_port_ht_table_act()
    {
        entry_dst_port = dst_port_action.execute(hash4.get({srcip, dstip, src_port, dst_port}));
    }

    table dst_port_ht_table {
        actions = {
            dst_port_ht_table_act;
        }
        const default_action = dst_port_ht_table_act;
        size = 16;
    }

    apply {
        srcip_ht_table.apply();
        dstip_ht_table.apply();
        src_port_ht_table.apply();
        dst_port_ht_table.apply();

        if (entry_srcip != 0 && entry_dstip != 0 && entry_src_port != 0 && entry_dst_port != 0) {
            if(entry_srcip != srcip) {
                tbl_exact_match.apply();
            }
            else {
                if(entry_dstip != dstip) {
                    tbl_exact_match.apply();
                }
                else {
                    if(entry_src_port != src_port) {
                        tbl_exact_match.apply();
                    }
                    else {
                        if(entry_dst_port != dst_port) {
                            tbl_exact_match.apply();
                        }
                    }
                }
            }
        }
    }
}


control heavy_flowkey_storage_five_tuple (
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    in bit<32> srcip,
    in bit<32> dstip,
    in bit<32> both_port,
    in bit<8> proto)
    (bit<32> polynomial)
{
    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) srcip_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(srcip_hash_table) srcip_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = srcip;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) dstip_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(dstip_hash_table) dstip_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = dstip;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) port_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(port_hash_table) port_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = both_port;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<8>, bit<HT_BITLEN>>(HT_SIZE) proto_hash_table;
    RegisterAction<bit<8>, bit<HT_BITLEN>, bit<8>>(proto_hash_table) proto_action = {
        void apply(inout bit<8> register_data, out bit<8> result) {
            if (register_data == 0) {
                register_data = proto;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    // exact table
    action tbl_exact_match_miss() {
        ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            srcip : exact;
            dstip : exact;
            both_port : exact;
            proto : exact;
        }
        actions = {
            tbl_exact_match_miss;
            tbl_exact_match_hit;
        }
        const default_action = tbl_exact_match_miss;
        size = 8192;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash1;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash2;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash3;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash4;

    bit<32> entry_srcip;
    bit<32> entry_dstip;
    bit<32> entry_both_port;
    bit<8> entry_proto;

    action srcip_ht_table_act()
    {
        entry_srcip = srcip_action.execute(hash1.get({srcip, dstip, both_port, proto}));
    }

    table srcip_ht_table {
        actions = {
            srcip_ht_table_act;
        }
        const default_action = srcip_ht_table_act;
        size = 16;
    }

    action dstip_ht_table_act()
    {
        entry_dstip = dstip_action.execute(hash2.get({srcip, dstip, both_port, proto}));
    }

    table dstip_ht_table {
        actions = {
            dstip_ht_table_act;
        }
        const default_action = dstip_ht_table_act;
        size = 16;
    }

    action port_ht_table_act()
    {
        entry_both_port = port_action.execute(hash3.get({srcip, dstip, both_port, proto}));
    }

    table port_ht_table {
        actions = {
            port_ht_table_act;
        }
        const default_action = port_ht_table_act;
        size = 16;
    }

    action proto_ht_table_act()
    {
        entry_proto = proto_action.execute(hash4.get({srcip, dstip, both_port, proto}));
    }

    table proto_ht_table {
        actions = {
            proto_ht_table_act;
        }
        const default_action = proto_ht_table_act;
        size = 16;
    }

    apply {
        srcip_ht_table.apply();
        dstip_ht_table.apply();
        port_ht_table.apply();
        proto_ht_table.apply();

        if (entry_srcip != 0 && entry_dstip != 0 && entry_both_port != 0 && entry_proto != 0) {
            if(entry_srcip != srcip) {
                tbl_exact_match.apply();
            }
            else {
                if(entry_dstip != dstip) {
                    tbl_exact_match.apply();
                }
                else {
                    if(entry_both_port != both_port) {
                        tbl_exact_match.apply();
                    }
                    else {
                        if(entry_proto != proto) {
                            tbl_exact_match.apply();
                        }
                    }
                }
            }
        }
    }
}



control heavy_flowkey_storage_five_tuple_full (
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    in bit<32> srcip,
    in bit<32> dstip,
    in bit<16> src_port,
    in bit<16> dst_port,
    in bit<8> proto)
    (bit<32> polynomial)
{
    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) srcip_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(srcip_hash_table) srcip_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = srcip;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<32>, bit<HT_BITLEN>>(HT_SIZE) dstip_hash_table;
    RegisterAction<bit<32>, bit<HT_BITLEN>, bit<32>>(dstip_hash_table) dstip_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = dstip;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<16>, bit<HT_BITLEN>>(HT_SIZE) src_port_hash_table;
    RegisterAction<bit<16>, bit<HT_BITLEN>, bit<16>>(src_port_hash_table) src_port_action = {
        void apply(inout bit<16> register_data, out bit<16> result) {
            if (register_data == 0) {
                register_data = src_port;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<16>, bit<HT_BITLEN>>(HT_SIZE) dst_port_hash_table;
    RegisterAction<bit<16>, bit<HT_BITLEN>, bit<16>>(dst_port_hash_table) dst_port_action = {
        void apply(inout bit<16> register_data, out bit<16> result) {
            if (register_data == 0) {
                register_data = dst_port;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    Register<bit<8>, bit<HT_BITLEN>>(HT_SIZE) proto_hash_table;
    RegisterAction<bit<8>, bit<HT_BITLEN>, bit<8>>(proto_hash_table) proto_action = {
        void apply(inout bit<8> register_data, out bit<8> result) {
            if (register_data == 0) {
                register_data = proto;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };

    // exact table
    action tbl_exact_match_miss() {
        ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            srcip : exact;
            dstip : exact;
            src_port : exact;
            dst_port : exact;
            proto : exact;
        }
        actions = {
            tbl_exact_match_miss;
            tbl_exact_match_hit;
        }
        const default_action = tbl_exact_match_miss;
        size = 8192;
    }

    CRCPolynomial<bit<32>>(polynomial,
                         true,
                         false,
                         false,
                         32w0xFFFFFFFF,
                         32w0xFFFFFFFF
                         ) poly1;

    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash1;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash2;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash3;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash4;
    Hash<bit<HT_BITLEN>>(HashAlgorithm_t.CUSTOM, poly1) hash5;

    bit<32> entry_srcip;
    bit<32> entry_dstip;
    bit<16> entry_src_port;
    bit<16> entry_dst_port;
    bit<8> entry_proto;

    action srcip_ht_table_act()
    {
        entry_srcip = srcip_action.execute(hash1.get({srcip, dstip, src_port, dst_port, proto}));
    }

    table srcip_ht_table {
        actions = {
            srcip_ht_table_act;
        }
        const default_action = srcip_ht_table_act;
        size = 16;
    }

    action dstip_ht_table_act()
    {
        entry_dstip = dstip_action.execute(hash2.get({srcip, dstip, src_port, dst_port, proto}));
    }

    table dstip_ht_table {
        actions = {
            dstip_ht_table_act;
        }
        const default_action = dstip_ht_table_act;
        size = 16;
    }

    action src_port_ht_table_act()
    {
        entry_src_port = src_port_action.execute(hash3.get({srcip, dstip, src_port, dst_port, proto}));
    }

    table src_port_ht_table {
        actions = {
            src_port_ht_table_act;
        }
        const default_action = src_port_ht_table_act;
        size = 16;
    }

    action dst_port_ht_table_act()
    {
        entry_dst_port = dst_port_action.execute(hash4.get({srcip, dstip, src_port, dst_port, proto}));
    }

    table dst_port_ht_table {
        actions = {
            dst_port_ht_table_act;
        }
        const default_action = dst_port_ht_table_act;
        size = 16;
    }

    action proto_ht_table_act()
    {
        entry_proto = proto_action.execute(hash5.get({srcip, dstip, src_port, dst_port, proto}));
    }

    table proto_ht_table {
        actions = {
            proto_ht_table_act;
        }
        const default_action = proto_ht_table_act;
        size = 16;
    }

    apply {
        srcip_ht_table.apply();
        dstip_ht_table.apply();
        src_port_ht_table.apply();
        dst_port_ht_table.apply();
        proto_ht_table.apply();

        if (entry_srcip != 0 && entry_dstip != 0 && entry_src_port != 0 && entry_dst_port != 0 && entry_proto != 0) {
            if(entry_srcip != srcip) {
                tbl_exact_match.apply();
            }
            else {
                if(entry_dstip != dstip) {
                    tbl_exact_match.apply();
                }
                else {
                    if(entry_src_port != src_port) {
                        tbl_exact_match.apply();
                    }
                    else {
                        if(entry_dst_port != dst_port) {
                            tbl_exact_match.apply();
                        }
                        else {
                            if(entry_proto != proto) {
                                tbl_exact_match.apply();
                            }
                        }
                    }
                }
            }
        }
    }
}
