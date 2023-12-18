#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif
#include "headers.p4"
#include "util.p4"
#include "metadata.p4"
struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> hf_srcip;
    bit<32> hf_dstip;
    bit<16> hf_srcport;
    bit<16> hf_dstport;
    bit<8> hf_proto;
    METADATA_DIM(1)
    METADATA_DIM(2)
    METADATA_DIM(3)
    METADATA_DIM(4)
    METADATA_DIM(5)
    METADATA_DIM(6)
    METADATA_DIM(7)
    METADATA_DIM(8)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T4_INIT_1( 1, 110, 16384)
    MRB_INIT_1( 2, 110, 131072, 14,  8)
    MRB_INIT_1( 3, 110, 262144, 14, 16)
    T5_INIT_1( 4, 110, 4096)
    T4_INIT_1( 5, 110, 16384)
    MRAC_INIT_1( 6, 110, 16384, 11,  8)
    T4_INIT_1( 7, 220, 16384)
    MRAC_INIT_1( 8, 220, 16384, 11,  8)
    apply {
        T4_RUN_1_KEY_2( 1, SRCIP, SRCPORT)
        MRB_RUN_1_KEY_2( 2, SRCIP, SRCPORT)
        MRB_RUN_1_KEY_2( 3, SRCIP, SRCPORT)
        T5_RUN_1_KEY_2( 4, SRCIP, SRCPORT)
        T4_RUN_1_KEY_2( 5, DSTIP, DSTPORT)
        MRAC_RUN_1_KEY_2( 6, DSTIP, DSTPORT)
        T4_RUN_1_KEY_4( 7, SRCIP, DSTIP, SRCPORT, DSTPORT)
        MRAC_RUN_1_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT)
    }
}
struct my_egress_headers_t {}
struct my_egress_metadata_t {}
parser EgressParser(packet_in        pkt,
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    out egress_intrinsic_metadata_t  eg_intr_md)
{
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
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
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