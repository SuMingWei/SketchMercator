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
    T2_INIT_1( 1, 100, 4096)
    T1_INIT_4( 2, 100, 131072)
    T2_INIT_HH_1( 3, 100, 4096)
    T1_INIT_1( 4, 200, 524288)
    T5_INIT_1( 5, 200, 8192)
    T2_INIT_HH_2( 6, 200, 8192)
    MRB_INIT_1( 7, 110, 131072, 14,  8)
    MRAC_INIT_1( 8, 110, 16384, 11,  8)
    MRAC_INIT_1( 9, 110, 8192, 10,  8)
    T1_INIT_1(10, 110, 262144)
    T1_INIT_1(11, 110, 262144)
    T4_INIT_1(12, 220, 65536)
    MRB_INIT_1(13, 220, 131072, 14,  8)
    MRB_INIT_1(14, 220, 524288, 15, 16)
    MRAC_INIT_1(15, 220, 32768, 11, 16)
    T1_INIT_1(16, 221, 131072)
    T5_INIT_1(17, 221, 8192)
    T2_INIT_3(18, 221, 4096)
    T2_INIT_HH_1(19, 221, 8192)
    apply {
        T2_RUN_1_KEY_1( 1, SRCIP, SIZE)
        T1_RUN_4_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_HH_1_KEY_1( 3, DSTIP, 1)
        T1_RUN_1_KEY_2( 4, SRCIP, DSTIP)
        T5_RUN_1_KEY_2( 5, SRCIP, DSTIP)
        T2_RUN_HH_2_KEY_2( 6, SRCIP, DSTIP, 1)
        MRB_RUN_1_KEY_2( 7, SRCIP, SRCPORT)
        MRAC_RUN_1_KEY_2( 8, SRCIP, SRCPORT)
        MRAC_RUN_1_KEY_2( 9, SRCIP, SRCPORT)
        T1_RUN_1_KEY_2(10, DSTIP, DSTPORT) if (ig_md.d_10_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2(11, DSTIP, DSTPORT)
        T4_RUN_1_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT)
        MRB_RUN_1_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT)
        MRB_RUN_1_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT)
        MRAC_RUN_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T1_RUN_1_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_16_est1_1 == 0) { /* process_new_flow() */ }
        T5_RUN_1_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_3_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_HH_1_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
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