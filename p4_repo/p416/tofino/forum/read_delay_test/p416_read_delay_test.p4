#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "common_p4/headers.p4"
#include "common_p4/util.p4"

#if SIMULATOR == 0
const PortId_t CPU_PORT = 192; // pipeline 2
#else
const PortId_t CPU_PORT = 64; // simulator
#endif
// const PortId_t CPU_PORT = 320; // pipeline 4

#define ETHERTYPE_TO_CPU 0xBF01


struct metadata_t {
    bit<16> index_1;
    bit<32> est_1;
}

#include "common_p4/parser.p4"
#include "hash.p4"
#include "salu.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    HASH_COMPUTE_16(32w0x30243f0b) index_hash_1;

    CS_UPDATE() update_1;

    apply {
        if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            index_hash_1.apply(hdr.ipv4.src_addr, ig_md.index_1);
            update_1.apply(ig_md.index_1, ig_md.est_1);
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
