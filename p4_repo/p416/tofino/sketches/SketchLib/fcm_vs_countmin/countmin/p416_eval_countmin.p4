#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

struct metadata_t {
    bit<32> threshold;

    bit<32> est_1;
    bit<32> est_2;
    bit<32> est_3;
    bit<32> est_4;
    bit<32> est_5;
    bit<32> est_6;
    bit<32> est_7;
    // bit<32> est_8;

    bit<1> c_1;
    bit<1> c_2;
    bit<1> c_3;
    bit<1> c_4;
    bit<1> c_5;
    bit<1> c_6;
    bit<1> c_7;
    // bit<1> c_8;

    bit<1> above_threshold;

    bit<16> res_all;
}

#include "parser.p4"

#include "API_common.p4"
#include "API_O1_hash.p4"
#include "API_O2_hash.p4"
#include "API_O3_tcam.p4"
#include "API_O6_flowkey.p4"
#include "API_threshold.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    GET_THRESHOLD() get_threshold;

    CM_UPDATE_15(32w0x30243f0b) update_1;
    CM_UPDATE_15(32w0x0f79f523) update_2;
    CM_UPDATE_15(32w0x6b8cb0c5) update_3;
    CM_UPDATE_15(32w0x00390fc3) update_4;
    CM_UPDATE_15(32w0x298ac673) update_5;
    CM_UPDATE_15(32w0x298ac674) update_6;
    // CM_UPDATE_15(32w0x298ac675) update_7;
    // CM_UPDATE(32w0x298ac676) update_8;

    heavy_flowkey_storage() store_flowkey;

    HASH_COMPUTE_SRCIP_16_16(32w0x30243f0b) res_all_hash;

    apply {

        if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {

            get_threshold.apply(hdr, ig_md);
            res_all_hash.apply(hdr.ipv4.src_addr, ig_md.res_all);

            update_1.apply(hdr.ipv4.src_addr, ig_md.est_1);
            update_2.apply(hdr.ipv4.src_addr, ig_md.est_2);
            update_3.apply(hdr.ipv4.src_addr, ig_md.est_3);
            update_4.apply(hdr.ipv4.src_addr, ig_md.est_4);
            update_5.apply(hdr.ipv4.src_addr, ig_md.est_5);
            update_6.apply(hdr.ipv4.src_addr, ig_md.est_6);
            // update_7.apply(hdr.ipv4.src_addr, ig_md.est_7);
            // update_8.apply(hdr.ipv4.src_addr, ig_md.est_8);

            store_flowkey.apply(hdr, ig_md, ig_tm_md);
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

