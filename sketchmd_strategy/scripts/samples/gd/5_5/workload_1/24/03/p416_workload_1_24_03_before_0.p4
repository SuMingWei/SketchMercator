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
    METADATA_DIM(11)
    METADATA_DIM(12)
    METADATA_DIM(13)
    METADATA_DIM(14)
    METADATA_DIM(15)
    METADATA_DIM(16)
    METADATA_DIM(17)
    METADATA_DIM(18)
    METADATA_DIM(19)
    METADATA_DIM(20)
    METADATA_DIM(21)
    METADATA_DIM(22)
    METADATA_DIM(23)
    METADATA_DIM(24)
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
    T2_INIT_HH_5( 1, 100, 4096)
    T2_INIT_HH_2( 2, 100, 4096)
    T2_INIT_HH_4( 3, 100, 8192)
    T2_INIT_HH_4( 4, 100, 8192)
    T2_INIT_HH_1( 5, 100, 8192)
    T2_INIT_HH_2( 6, 100, 16384)
    T2_INIT_HH_4( 7, 100, 8192)
    T2_INIT_HH_5( 8, 100, 16384)
    T2_INIT_HH_4( 9, 200, 8192)
    T2_INIT_HH_4(10, 200, 16384)
    T2_INIT_HH_2(11, 110, 8192)
    T2_INIT_HH_4(12, 110, 4096)
    T2_INIT_HH_4(13, 110, 4096)
    T2_INIT_HH_4(14, 110, 8192)
    T2_INIT_HH_1(15, 110, 16384)
    T2_INIT_HH_1(16, 110, 8192)
    T2_INIT_HH_3(17, 110, 8192)
    T2_INIT_HH_4(18, 110, 4096)
    T2_INIT_HH_1(19, 220, 16384)
    T2_INIT_HH_3(20, 220, 4096)
    T2_INIT_HH_5(21, 220, 8192)
    T2_INIT_HH_5(22, 220, 8192)
    T2_INIT_HH_2(23, 221, 8192)
    T2_INIT_HH_3(24, 221, 16384)
    apply {
        T2_RUN_HH_5_KEY_1( 1, SRCIP, 1)
        T2_RUN_HH_2_KEY_1( 2, SRCIP, SIZE)
        T2_RUN_HH_4_KEY_1( 3, SRCIP, SIZE)
        T2_RUN_HH_4_KEY_1( 4, DSTIP, 1)
        T2_RUN_HH_1_KEY_1( 5, DSTIP, 1)
        T2_RUN_HH_2_KEY_1( 6, DSTIP, 1)
        T2_RUN_HH_4_KEY_1( 7, DSTIP, SIZE)
        T2_RUN_HH_5_KEY_1( 8, DSTIP, SIZE)
        T2_RUN_HH_4_KEY_2( 9, SRCIP, DSTIP, 1)
        T2_RUN_HH_4_KEY_2(10, SRCIP, DSTIP, 1)
        T2_RUN_HH_2_KEY_2(11, SRCIP, SRCPORT, 1)
        T2_RUN_HH_4_KEY_2(12, SRCIP, SRCPORT, 1)
        T2_RUN_HH_4_KEY_2(13, SRCIP, SRCPORT, 1)
        T2_RUN_HH_4_KEY_2(14, SRCIP, SRCPORT, SIZE)
        T2_RUN_HH_1_KEY_2(15, SRCIP, SRCPORT, SIZE)
        T2_RUN_HH_1_KEY_2(16, SRCIP, SRCPORT, SIZE)
        T2_RUN_HH_3_KEY_2(17, SRCIP, SRCPORT, SIZE)
        T2_RUN_HH_4_KEY_2(18, DSTIP, DSTPORT, 1)
        T2_RUN_HH_1_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_HH_3_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_HH_5_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_HH_5_KEY_4(22, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_HH_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_HH_3_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
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