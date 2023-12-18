#define ETHERTYPE_TO_CPU 0xBF01

#if SIMULATOR == 0
const PortId_t CPU_PORT = 192; // pipeline 2
#else
const PortId_t CPU_PORT = 64; // simulator
#endif
// const PortId_t CPU_PORT = 320; // pipeline 4

control heavy_flowkey_storage_key32_3 (
    inout header_t hdr,
    in bit<32> flowkey,
    inout bit<32> threshold,
    inout bit<32> est_1,
    inout bit<32> est_2,
    inout bit<32> est_3,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
    (bit<32> polynomial)
{
    bit<1> c_1;
    bit<1> c_2;
    bit<1> c_3;
    bit<1> above_threshold;

    // threshold table
    action tbl_threshold_above_action() {
        above_threshold = 1;
    }

    table tbl_threshold {
        key = {
            c_1 : exact;
            c_2 : exact;
            c_3 : exact;
        }
        actions = {
            tbl_threshold_above_action;
        }
    }

    // hash table
    // bit<32> : entry size
    // bit<16> : index size
    // 65536   : SRAM size

    Register<bit<32>, bit<16>>(32w16384) flowkey_hash_table;

    RegisterAction<bit<32>, bit<16>, bit<32>>(flowkey_hash_table) flowkey_action = {
        void apply(inout bit<32> register_data, out bit<32> result) {
            if (register_data == 0) {
                register_data = flowkey;
                result = 0;
            }
            else {
                result = register_data;
            }
        }
    };


    // exact table
    action tbl_exact_match_miss() {

        hdr.cpu_ethernet.setValid();
        hdr.cpu_ethernet.dst_addr   = 0xFFFFFFFFFFFF;
        hdr.cpu_ethernet.src_addr   = 0xAAAAAAAAAAAA;
        hdr.cpu_ethernet.ether_type = ETHERTYPE_TO_CPU;
        ig_tm_md.ucast_egress_port = CPU_PORT;
    }

    action tbl_exact_match_hit() {
    }

    table tbl_exact_match {
        key = {
            flowkey : exact;
        }
        actions = {
            tbl_exact_match_miss;
            tbl_exact_match_hit;
        }
        const default_action = tbl_exact_match_miss;
        size = 4096;
    }

    CRCPolynomial<bit<32>>(polynomial,
                           true,
                           false,
                           false,
                           32w0xFFFFFFFF,
                           32w0xFFFFFFFF
                           ) poly1;

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action subtract() {
        est_1 = est_1 - threshold;
        est_2 = est_2 - threshold;
        est_3 = est_3 - threshold;
    }

    action shift() {
        c_1 = (bit<1>) est_1 >> 31;
        c_2 = (bit<1>) est_2 >> 31;
        c_3 = (bit<1>) est_3 >> 31;
    }

    apply {
        subtract();
        shift();
        tbl_threshold.apply();

        if(above_threshold == 1) {
            bit<32> hash_entry = flowkey_action.execute(hash.get({flowkey}));

            if (hash_entry != 0) {
                if (hash_entry != flowkey) {
                    tbl_exact_match.apply();
                }
            }
        }
    }
}
