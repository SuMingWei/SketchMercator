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
    T1_INIT_2( 1, 100, 524288)
    T2_INIT_HH_5( 2, 100, 8192)
    T2_INIT_2( 3, 100, 8192)
    T2_INIT_1( 4, 100, 4096)
    T2_INIT_HH_1( 5, 100, 16384)
    T2_INIT_HH_1( 6, 100, 16384)
    MRAC_INIT_1( 7, 100, 8192, 10,  8)
    T1_INIT_4( 8, 200, 131072)
    T2_INIT_5( 9, 200, 16384)
    T2_INIT_5(10, 200, 8192)
    T3_INIT_HH_4(11, 200, 16384)
    T2_INIT_HH_5(12, 200, 4096)
    MRB_INIT_1(13, 110, 524288, 15, 16)
    T2_INIT_HH_3(14, 110, 16384)
    T2_INIT_HH_5(15, 110, 16384)
    MRAC_INIT_1(16, 110, 16384, 10, 16)
    UM_INIT_3(17, 110, 11, 32768)
    T2_INIT_HH_5(18, 220, 16384)
    MRAC_INIT_1(19, 220, 32768, 11, 16)
    UM_INIT_3(20, 220, 10, 16384)
    T1_INIT_1(21, 221, 131072)
    MRB_INIT_1(22, 221, 262144, 15,  8)
    apply {
        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_HH_5_KEY_1( 2, SRCIP, 1)
        T2_RUN_2_KEY_1( 3, DSTIP, 1)
        T2_RUN_1_KEY_1( 4, DSTIP, SIZE)
        T2_RUN_HH_1_KEY_1( 5, DSTIP, 1)
        T2_RUN_HH_1_KEY_1( 6, DSTIP, 1)
        MRAC_RUN_1_KEY_1( 7, DSTIP)
        T1_RUN_4_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_5_KEY_2( 9, SRCIP, DSTIP, 1)
        T2_RUN_5_KEY_2(10, SRCIP, DSTIP, SIZE)
        T3_RUN_HH_4_KEY_2(11, SRCIP, DSTIP, 1)
        T2_RUN_HH_5_KEY_2(12, SRCIP, DSTIP, SIZE)
        MRB_RUN_1_KEY_2(13, SRCIP, SRCPORT)
        T2_RUN_HH_3_KEY_2(14, SRCIP, SRCPORT, SIZE)
        T2_RUN_HH_5_KEY_2(15, SRCIP, SRCPORT, 1)
        MRAC_RUN_1_KEY_2(16, SRCIP, SRCPORT)
        UM_RUN_3_KEY_2(17, DSTIP, DSTPORT, 1)
        T2_RUN_HH_5_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        MRAC_RUN_1_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT)
        UM_RUN_3_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T1_RUN_1_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
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