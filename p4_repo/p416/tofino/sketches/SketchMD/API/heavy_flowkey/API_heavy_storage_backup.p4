#define ETHERTYPE_TO_CPU 0xBF01

#if SIMULATOR == 0
const PortId_t CPU_PORT = 192; // pipeline 2
#else
const PortId_t CPU_PORT = 64; // simulator
#endif


#define HT_SIZE 32768
#define HT_BITLEN 15


control heavy_flowkey_storage_32 (
    inout header_t hdr,
    in bit<32> srcip,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
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

    // exact table
    action tbl_exact_match_miss() {
        hdr.cpu.setValid();
        hdr.cpu.type = ETHERTYPE_TO_CPU;
        hdr.cpu.src_addr = srcip;
        ig_tm_md.ucast_egress_port = CPU_PORT;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            srcip : exact;
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

    bit<32> entry_srcip;

    action srcip_ht_table_act()
    {
        entry_srcip = srcip_action.execute(hash1.get({srcip}));
    }

    table srcip_ht_table {
        actions = {
            srcip_ht_table_act;
        }
        const default_action = srcip_ht_table_act;
        size = 16;
    }

    apply {
        srcip_ht_table.apply();
        if (entry_srcip != 0) {
            if(entry_srcip != srcip) {
                tbl_exact_match.apply();
            }
        }
    }
}


control heavy_flowkey_storage_two_tuple (
    inout header_t hdr,
    in bit<32> srcip,
    in bit<32> dstip,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
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

    // exact table
    action tbl_exact_match_miss() {
        hdr.cpu.setValid();
        hdr.cpu.type = ETHERTYPE_TO_CPU;
        hdr.cpu.src_addr = srcip;
        hdr.cpu.dst_addr = dstip;
        ig_tm_md.ucast_egress_port = CPU_PORT;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            srcip : exact;
            dstip : exact;
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

    bit<32> entry_srcip;
    bit<32> entry_dstip;

    bit<32> diff_srcip;
    bit<32> diff_dstip;

    action srcip_ht_table_act()
    {
        entry_srcip = srcip_action.execute(hash1.get({srcip, dstip}));
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
        entry_dstip = dstip_action.execute(hash2.get({srcip, dstip}));
    }

    table dstip_ht_table {
        actions = {
            dstip_ht_table_act;
        }
        const default_action = dstip_ht_table_act;
        size = 16;
    }

    apply {
        srcip_ht_table.apply();
        dstip_ht_table.apply();

        if (entry_srcip != 0 && entry_dstip != 0) {
            if(entry_srcip != srcip) {
                tbl_exact_match.apply();
            }
            else {
                if(entry_dstip != dstip) {
                    tbl_exact_match.apply();
                }
            }
        }
    }
}

control heavy_flowkey_storage_four_tuple (
    inout header_t hdr,
    in bit<32> srcip,
    in bit<32> dstip,
    in bit<32> both_port,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
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

    // exact table
    action tbl_exact_match_miss() {
        hdr.cpu.setValid();
        hdr.cpu.type = ETHERTYPE_TO_CPU;
        hdr.cpu.src_addr = srcip;
        hdr.cpu.dst_addr = dstip;
        hdr.cpu.both_port = both_port;
        ig_tm_md.ucast_egress_port = CPU_PORT;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            srcip : exact;
            dstip : exact;
            both_port : exact;
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

    bit<32> entry_srcip;
    bit<32> entry_dstip;
    bit<32> entry_both_port;

    bit<32> diff_srcip;
    bit<32> diff_dstip;
    bit<32> diff_both_port;

    action srcip_ht_table_act()
    {
        entry_srcip = srcip_action.execute(hash1.get({srcip, dstip, both_port}));
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
        entry_dstip = dstip_action.execute(hash2.get({srcip, dstip, both_port}));
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
        entry_both_port = port_action.execute(hash3.get({srcip, dstip, both_port}));
    }

    table port_ht_table {
        actions = {
            port_ht_table_act;
        }
        const default_action = port_ht_table_act;
        size = 16;
    }

    apply {
        srcip_ht_table.apply();
        dstip_ht_table.apply();
        port_ht_table.apply();

        if (entry_srcip != 0 && entry_dstip != 0 && entry_both_port != 0) {
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
                }
            }
        }
    }
}

control heavy_flowkey_storage_five_tuple (
    inout header_t hdr,
    in bit<32> srcip,
    in bit<32> dstip,
    in bit<32> both_port,
    in bit<8> proto,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
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
        hdr.cpu.setValid();
        hdr.cpu.type = ETHERTYPE_TO_CPU;
        hdr.cpu.src_addr = srcip;
        hdr.cpu.dst_addr = dstip;
        hdr.cpu.both_port = both_port;
        hdr.cpu.proto = proto;
        ig_tm_md.ucast_egress_port = CPU_PORT;
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

    bit<32> diff_srcip;
    bit<32> diff_dstip;
    bit<32> diff_both_port;
    bit<8> diff_proto;

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
