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
    T4_INIT_1( 1, 100, 4096)
    T2_INIT_3( 2, 100, 16384)
    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T2_INIT_3( 4, 100, 16384)
    T3_INIT_HH_3( 5, 100, 8192)
    T1_INIT_4( 6, 200, 262144)
    MRB_INIT_1( 7, 200, 131072, 14,  8)
    MRAC_INIT_1( 8, 200, 32768, 11, 16)
    T4_INIT_1( 9, 110, 8192)
    T2_INIT_5(10, 110, 8192)
    T3_INIT_HH_3(11, 110, 4096)
    MRAC_INIT_1(12, 110, 16384, 11,  8)
    T3_INIT_HH_5(13, 110, 4096)
    T2_INIT_HH_5(14, 110, 16384)
    UM_INIT_4(15, 110, 11, 32768)
    T2_INIT_4(16, 220, 16384)
    MRAC_INIT_1(17, 220, 16384, 11,  8)
    T2_INIT_1(18, 221, 8192)
    T2_INIT_HH_3(19, 221, 16384)
    MRAC_INIT_1(20, 221, 32768, 11, 16)
    apply {
        T4_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_3_KEY_1( 2, SRCIP, 1)
        MRAC_RUN_1_KEY_1( 3, SRCIP)
        T2_RUN_3_KEY_1( 4, DSTIP, SIZE)
        T3_RUN_HH_3_KEY_1( 5, DSTIP, SIZE)
        T1_RUN_4_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_2( 7, SRCIP, DSTIP)
        MRAC_RUN_1_KEY_2( 8, SRCIP, DSTIP)
        T4_RUN_1_KEY_2( 9, SRCIP, SRCPORT)
        T2_RUN_5_KEY_2(10, SRCIP, SRCPORT, SIZE)
        T3_RUN_HH_3_KEY_2(11, SRCIP, SRCPORT, SIZE)
        MRAC_RUN_1_KEY_2(12, SRCIP, SRCPORT)
        T3_RUN_HH_5_KEY_2(13, DSTIP, DSTPORT, 1)
        T2_RUN_HH_5_KEY_2(14, DSTIP, DSTPORT, SIZE)
        UM_RUN_4_KEY_2(15, DSTIP, DSTPORT, SIZE)
        T2_RUN_4_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        MRAC_RUN_1_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_1_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_HH_3_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        MRAC_RUN_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
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