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
    METADATA_DIM(9)
    METADATA_DIM(10)
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
    MRAC_INIT_1( 1, 100, 32768, 11, 16)
    MRAC_INIT_1( 2, 110, 16384, 11,  8)
    MRAC_INIT_1( 3, 110, 16384, 11,  8)
    T2_INIT_1( 4, 110, 4096)
    MRAC_INIT_1( 5, 110, 32768, 11, 16)
    UM_INIT_5( 6, 110, 11, 32768)
    UM_INIT_5( 7, 220, 11, 32768)
    UM_INIT_5( 8, 220, 11, 32768)
    T5_INIT_1( 9, 221, 16384)
    MRAC_INIT_1(10, 221, 32768, 11, 16)
    apply {
        MRAC_RUN_1_KEY_1( 1, DSTIP)
        MRAC_RUN_1_KEY_2( 2, SRCIP, SRCPORT)
        MRAC_RUN_1_KEY_2( 3, SRCIP, SRCPORT)
        T2_RUN_1_KEY_2( 4, DSTIP, DSTPORT, 1)
        MRAC_RUN_1_KEY_2( 5, DSTIP, DSTPORT)
        UM_RUN_5_KEY_2( 6, DSTIP, DSTPORT, 1)
        UM_RUN_5_KEY_4( 7, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        UM_RUN_5_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T5_RUN_1_KEY_5( 9, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        MRAC_RUN_1_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
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