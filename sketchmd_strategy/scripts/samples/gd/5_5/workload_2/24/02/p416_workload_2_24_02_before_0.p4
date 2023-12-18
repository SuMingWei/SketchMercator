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
    T1_INIT_5( 1, 100, 524288)
    T1_INIT_2( 2, 100, 524288)
    T1_INIT_2( 3, 100, 131072)
    T1_INIT_1( 4, 100, 524288)
    T2_INIT_4( 5, 100, 8192)
    T2_INIT_2( 6, 100, 8192)
    T2_INIT_2( 7, 100, 8192)
    T2_INIT_5( 8, 100, 16384)
    T2_INIT_HH_3( 9, 100, 16384)
    T2_INIT_HH_4(10, 100, 4096)
    T3_INIT_HH_3(11, 100, 16384)
    T3_INIT_HH_4(12, 100, 16384)
    T2_INIT_HH_4(13, 100, 16384)
    T2_INIT_HH_5(14, 100, 16384)
    T2_INIT_HH_2(15, 100, 16384)
    T2_INIT_HH_2(16, 100, 4096)
    T2_INIT_HH_5(17, 100, 4096)
    MRAC_INIT_1(18, 100, 32768, 11, 16)
    MRAC_INIT_1(19, 100, 16384, 11,  8)
    MRAC_INIT_1(20, 100, 32768, 11, 16)
    MRAC_INIT_1(21, 100, 32768, 11, 16)
    UM_INIT_2(22, 100, 11, 32768)
    UM_INIT_2(23, 100, 10, 16384)
    UM_INIT_4(24, 100, 10, 16384)
    apply {
        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_1( 3, SRCIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_1( 4, SRCIP)
        T2_RUN_4_KEY_1( 5, SRCIP, 1)
        T2_RUN_2_KEY_1( 6, SRCIP, 1)
        T2_RUN_2_KEY_1( 7, SRCIP, 1)
        T2_RUN_5_KEY_1( 8, SRCIP, 1)
        T2_RUN_HH_3_KEY_1( 9, SRCIP, 1)
        T2_RUN_HH_4_KEY_1(10, SRCIP, 1)
        T3_RUN_HH_3_KEY_1(11, SRCIP, 1)
        T3_RUN_HH_4_KEY_1(12, SRCIP, SIZE)
        T2_RUN_HH_4_KEY_1(13, SRCIP, 1)
        T2_RUN_HH_5_KEY_1(14, SRCIP, 1)
        T2_RUN_HH_2_KEY_1(15, SRCIP, SIZE)
        T2_RUN_HH_2_KEY_1(16, SRCIP, SIZE)
        T2_RUN_HH_5_KEY_1(17, SRCIP, SIZE)
        MRAC_RUN_1_KEY_1(18, SRCIP)
        MRAC_RUN_1_KEY_1(19, SRCIP)
        MRAC_RUN_1_KEY_1(20, SRCIP)
        MRAC_RUN_1_KEY_1(21, SRCIP)
        UM_RUN_2_KEY_1(22, SRCIP, SIZE)
        UM_RUN_2_KEY_1(23, SRCIP, SIZE)
        UM_RUN_4_KEY_1(24, SRCIP, SIZE)
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