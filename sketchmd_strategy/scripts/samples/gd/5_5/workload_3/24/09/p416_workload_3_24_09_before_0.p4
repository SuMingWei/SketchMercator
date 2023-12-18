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
    T1_INIT_5( 1, 100, 262144)
    T5_INIT_1( 2, 100, 8192)
    T2_INIT_HH_3( 3, 100, 16384)
    T2_INIT_HH_3( 4, 100, 4096)
    MRAC_INIT_1( 5, 100, 16384, 10, 16)
    UM_INIT_3( 6, 100, 11, 32768)
    T2_INIT_HH_1( 7, 100, 4096)
    T1_INIT_1( 8, 200, 131072)
    T2_INIT_4( 9, 200, 4096)
    MRAC_INIT_1(10, 200, 32768, 11, 16)
    UM_INIT_3(11, 200, 11, 32768)
    T1_INIT_1(12, 110, 524288)
    T1_INIT_2(13, 110, 524288)
    T1_INIT_2(14, 110, 262144)
    T1_INIT_5(15, 220, 262144)
    T2_INIT_4(16, 220, 16384)
    T2_INIT_HH_1(17, 220, 8192)
    MRAC_INIT_1(18, 220, 32768, 11, 16)
    UM_INIT_3(19, 220, 11, 32768)
    T1_INIT_5(20, 221, 262144)
    T1_INIT_3(21, 221, 262144)
    T1_INIT_1(22, 221, 262144)
    T2_INIT_HH_3(23, 221, 8192)
    MRAC_INIT_1(24, 221, 8192, 10,  8)
    apply {
        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        T5_RUN_1_KEY_1( 2, SRCIP)
        T2_RUN_HH_3_KEY_1( 3, SRCIP, 1)
        T2_RUN_HH_3_KEY_1( 4, SRCIP, 1)
        MRAC_RUN_1_KEY_1( 5, SRCIP)
        UM_RUN_3_KEY_1( 6, SRCIP, 1)
        T2_RUN_HH_1_KEY_1( 7, DSTIP, 1)
        T1_RUN_1_KEY_2( 8, SRCIP, DSTIP)
        T2_RUN_4_KEY_2( 9, SRCIP, DSTIP, 1)
        MRAC_RUN_1_KEY_2(10, SRCIP, DSTIP)
        UM_RUN_3_KEY_2(11, SRCIP, DSTIP, 1)
        T1_RUN_1_KEY_2(12, SRCIP, SRCPORT) if (ig_md.d_12_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0 || ig_md.d_15_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_4_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_HH_1_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        MRAC_RUN_1_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT)
        UM_RUN_3_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_5_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0 || ig_md.d_20_est1_3 == 0 || ig_md.d_20_est1_4 == 0 || ig_md.d_20_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_HH_3_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        MRAC_RUN_1_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
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