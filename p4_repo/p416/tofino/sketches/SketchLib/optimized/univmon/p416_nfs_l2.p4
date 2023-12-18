#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

struct metadata_t {
    bit<16> sampling_hash_value;
    bit<16> level;
    bit<16> base;
    bit<32> threshold;

    bit<16> index_1;
    bit<16> index_2;
    bit<16> index_3;
    bit<16> index_4;
    bit<16> index_5;

    // bit<5> res_all;
    bit<16> res_all;
    bit<1> res_1;
    bit<1> res_2;
    bit<1> res_3;
    bit<1> res_4;
    bit<1> res_5;

    bit<32> est_1;
    bit<32> est_2;
    bit<32> est_3;
    bit<32> est_4;
    bit<32> est_5;

    bit<16> base_1;
    bit<16> base_2;
    bit<16> base_3;
    bit<16> base_4;
    bit<16> base_5;

    bit<16> mem_index_1;
    bit<16> mem_index_2;
    bit<16> mem_index_3;
    bit<16> mem_index_4;
    bit<16> mem_index_5;

    bit<1> c_1;
    bit<1> c_2;
    bit<1> c_3;
    bit<1> c_4;
    bit<1> c_5;

    bit<1> above_threshold;

    bit<1> is_ext;
}

#include "parser.p4"

#include "API_common.p4"
#include "API_O1_hash.p4"
#include "API_O2_hash.p4"
#include "API_O3_tcam.p4"
#include "API_O5_salu.p4"
#include "API_O6_flowkey.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    lpm_optimization() tcam;

    #if HASH_SET == 1
        HASH_COMPUTE_SRCIP_16_16(32w0x790900f3) sampling_hash;
        hash_consolidate_and_split_srcip(32w0x5b445b31) res_split;
        HASH_COMPUTE_SRCIP_16_11(32w0x30243f0b) index_hash_1;
        HASH_COMPUTE_SRCIP_16_11(32w0x0f79f523) index_hash_2;
        HASH_COMPUTE_SRCIP_16_11(32w0x6b8cb0c5) index_hash_3;
        HASH_COMPUTE_SRCIP_16_11(32w0x00390fc3) index_hash_4;
        HASH_COMPUTE_SRCIP_16_11(32w0x298ac673) index_hash_5;
    #elif HASH_SET == 2
        HASH_COMPUTE_SRCIP_16_16(32w0x37205c43) sampling_hash;
        hash_consolidate_and_split_srcip(32w0x10820a15) res_split;
        HASH_COMPUTE_SRCIP_16_11(32w0x0a9d4719) index_hash_1;
        HASH_COMPUTE_SRCIP_16_11(32w0x527f2ab1) index_hash_2;
        HASH_COMPUTE_SRCIP_16_11(32w0x503e1855) index_hash_3;
        HASH_COMPUTE_SRCIP_16_11(32w0x36a7edfd) index_hash_4;
        HASH_COMPUTE_SRCIP_16_11(32w0x009cbd15) index_hash_5;
    #elif HASH_SET == 3
        HASH_COMPUTE_SRCIP_16_16(32w0x133b38db) sampling_hash;
        hash_consolidate_and_split_srcip(32w0x2e34c2ab) res_split;
        HASH_COMPUTE_SRCIP_16_11(32w0x6fbf2213) index_hash_1;
        HASH_COMPUTE_SRCIP_16_11(32w0x7a9d09a3) index_hash_2;
        HASH_COMPUTE_SRCIP_16_11(32w0x4e303003) index_hash_3;
        HASH_COMPUTE_SRCIP_16_11(32w0x09b68d7b) index_hash_4;
        HASH_COMPUTE_SRCIP_16_11(32w0x439e0185) index_hash_5;
    #elif HASH_SET == 4
        HASH_COMPUTE_SRCIP_16_16(32w0x4235e3b3) sampling_hash;
        hash_consolidate_and_split_srcip(32w0x31f5901b) res_split;
        HASH_COMPUTE_SRCIP_16_11(32w0x63986f65) index_hash_1;
        HASH_COMPUTE_SRCIP_16_11(32w0x16261f2d) index_hash_2;
        HASH_COMPUTE_SRCIP_16_11(32w0x67c781ad) index_hash_3;
        HASH_COMPUTE_SRCIP_16_11(32w0x409900cd) index_hash_4;
        HASH_COMPUTE_SRCIP_16_11(32w0x08123a4d) index_hash_5;
    #elif HASH_SET == 5
        HASH_COMPUTE_SRCIP_16_16(32w0x66890575) sampling_hash;
        hash_consolidate_and_split_srcip(32w0x1ad7801f) res_split;
        HASH_COMPUTE_SRCIP_16_11(32w0x67bb5cbf) index_hash_1;
        HASH_COMPUTE_SRCIP_16_11(32w0x01891da9) index_hash_2;
        HASH_COMPUTE_SRCIP_16_11(32w0x234e0cc5) index_hash_3;
        HASH_COMPUTE_SRCIP_16_11(32w0x24db30cb) index_hash_4;
        HASH_COMPUTE_SRCIP_16_11(32w0x148238a5) index_hash_5;
    #endif


    consolidate_update_univmon() update_1;
    consolidate_update_univmon() update_2;
    consolidate_update_univmon() update_3;
    consolidate_update_univmon() update_4;
    consolidate_update_univmon() update_5;

    heavy_flowkey_storage() store_flowkey;


    action drop() {
        ig_dprsr_md.drop_ctl = 1;
    }

    // L2 forwarding
    action set_egr(bit<9> port){
        // ig_tm_md.ucast_egress_port = port;
    }
    
    @stage(0)
    table l2_forward {
        key = { 
            hdr.ethernet.dst_addr : exact;
        }
        actions = { set_egr; NoAction; }
        const default_action = NoAction();
        size=150000;
    }

    apply {
        l2_forward.apply();
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
