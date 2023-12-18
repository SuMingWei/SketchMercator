/*
let's try four tuple
compilation fail
 44 The following fields were not allocated:
 45     ingress::d_1_heavy_flowkey_diff_both_port<32b>[31:16]
 46     ingress::d_1_heavy_flowkey_entry_both_port<32b>[31:16]
 47     ingress::hdr.cpu.both_port<32b>[31:16]
 48     ingress::ig_md.src_port<16b>
 49     ingress::d_1_heavy_flowkey_diff_both_port<32b>[15:0]
 50     ingress::d_1_heavy_flowkey_entry_both_port<32b>[15:0]
 51     ingress::hdr.cpu.both_port<32b>[15:0]
*/

#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<1> d_##D##_is_above_threshold; \

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> both_port;

    METADATA_DIM(1)
}

#include "parser.p4"
#include "API_S1_hash.p4"
#include "API_S3_salu.p4"
#include "API_S4_above_threshold.p4"

#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define BOTHPORT ig_md.both_port
#define PROTO hdr.ipv4.protocol

#define ETHERTYPE_TO_CPU 0xBF01
#if SIMULATOR == 0
const PortId_t CPU_PORT = 192; // pipeline 2
#else
const PortId_t CPU_PORT = 64; // simulator
#endif
#define HT_SIZE 32768
#define HT_BITLEN 15

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

    action subtract_values() {
        diff_srcip = entry_srcip - srcip;
        diff_dstip = entry_dstip - dstip;
        diff_both_port = entry_both_port - both_port;
    }

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

#define CONTROL_DIM(D) \
    CM_UPDATE_32_32_32_8(32w0x30243f0b) d_##D##_cm_update_1; \
    CM_UPDATE_32_32_32_8(32w0x30243f0b) d_##D##_cm_update_2; \
    CM_UPDATE_32_32_32_8(32w0x30243f0b) d_##D##_cm_update_3; \
    above_threshold() d_##D##_above_threshold; \
    heavy_flowkey_storage_four_tuple(32w0x30243f0b) d_##D##_heavy_flowkey; \

    // heavy_flowkey_storage_srcIP(32w0x30243f0b) d_##D##_heavy_flowkey; \

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    
    CONTROL_DIM(1)
    action get_both_port() {
        ig_md.both_port = ig_md.src_port ++ ig_md.src_port;
    }

    apply {
        get_both_port();
        // d_1_cm_update_1.apply(SRCIP, DSTIP, BOTHPORT, PROTO, ig_md.d_1_est_1);
        // d_1_cm_update_2.apply(SRCIP, DSTIP, BOTHPORT, PROTO, ig_md.d_1_est_2);
        // d_1_cm_update_3.apply(SRCIP, DSTIP, BOTHPORT, PROTO, ig_md.d_1_est_3);

        // d_1_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_is_above_threshold);
        if(ig_md.d_1_is_above_threshold == 1) {
            // d_1_heavy_flowkey.apply(hdr, SRCIP, ig_tm_md);
            d_1_heavy_flowkey.apply(hdr, SRCIP, DSTIP, BOTHPORT, ig_tm_md);
        }
    }
}

struct my_egress_headers_t {
}
/********  G L O B A L   E G R E S S   M E T A D A T A  *********/

struct my_egress_metadata_t {
}

parser EgressParser(packet_in        pkt,
    /* User */
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}

control EmptyEgress(
        inout my_egress_headers_t hdr,
        inout my_egress_metadata_t eg_md,
        in egress_intrinsic_metadata_t eg_intr_md,
        in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
        inout egress_intrinsic_metadata_for_deparser_t ig_intr_dprs_md,
        inout egress_intrinsic_metadata_for_output_port_t eg_intr_oport_md) {
    apply {}
}

control EgressDeparser(packet_out pkt,
    /* User */
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    /* Intrinsic */
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
    apply {
        pkt.emit(hdr);
    }
}


Pipeline(
    SwitchIngressParser(),
    SwitchIngress(),
    SwitchIngressDeparser(),
    EgressParser(),
    EmptyEgress(),
    EgressDeparser()
) pipe;

Switch(pipe) main;
