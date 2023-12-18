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
    T2_INIT_HH_4( 1, 100, 8192)
    UM_INIT_4( 2, 100, 11, 32768)
    T2_INIT_HH_1( 3, 100, 4096)
    MRAC_INIT_1( 4, 100, 16384, 10, 16)
    UM_INIT_3( 5, 100, 11, 32768)
    UM_INIT_3( 6, 100, 11, 32768)
    T1_INIT_5( 7, 200, 524288)
    UM_INIT_3( 8, 200, 10, 16384)
    UM_INIT_4( 9, 200, 10, 16384)
    T1_INIT_4(10, 110, 262144)
    UM_INIT_5(11, 110, 10, 16384)
    UM_INIT_1(12, 110, 11, 32768)
    MRB_INIT_1(13, 110, 131072, 14,  8)
    T2_INIT_HH_1(14, 110, 8192)
    T5_INIT_1(15, 220, 4096)
    T5_INIT_1(16, 221, 8192)
    T2_INIT_HH_3(17, 221, 4096)
    apply {
        T2_RUN_HH_4_KEY_1( 1, SRCIP, 1)
        UM_RUN_4_KEY_1( 2, SRCIP, 1)
        T2_RUN_HH_1_KEY_1( 3, DSTIP, SIZE)
        MRAC_RUN_1_KEY_1( 4, DSTIP)
        UM_RUN_3_KEY_1( 5, DSTIP, 1)
        UM_RUN_3_KEY_1( 6, DSTIP, SIZE)
        T1_RUN_5_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0 || ig_md.d_7_est1_4 == 0 || ig_md.d_7_est1_5 == 0) { /* process_new_flow() */ }
        UM_RUN_3_KEY_2( 8, SRCIP, DSTIP, 1)
        UM_RUN_4_KEY_2( 9, SRCIP, DSTIP, SIZE)
        T1_RUN_4_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0) { /* process_new_flow() */ }
        UM_RUN_5_KEY_2(11, SRCIP, SRCPORT, 1)
        UM_RUN_1_KEY_2(12, SRCIP, SRCPORT, SIZE)
        MRB_RUN_1_KEY_2(13, DSTIP, DSTPORT)
        T2_RUN_HH_1_KEY_2(14, DSTIP, DSTPORT, SIZE)
        T5_RUN_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T5_RUN_1_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_HH_3_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
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