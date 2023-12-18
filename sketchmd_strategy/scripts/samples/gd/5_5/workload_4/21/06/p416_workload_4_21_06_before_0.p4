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
    T2_INIT_3( 1, 100, 16384)
    MRAC_INIT_1( 2, 100, 16384, 10, 16)
    UM_INIT_4( 3, 100, 10, 16384)
    MRB_INIT_1( 4, 100, 262144, 15,  8)
    T2_INIT_2( 5, 100, 8192)
    T2_INIT_HH_2( 6, 100, 16384)
    T2_INIT_HH_2( 7, 100, 16384)
    MRAC_INIT_1( 8, 100, 32768, 11, 16)
    T1_INIT_1( 9, 200, 131072)
    T2_INIT_4(10, 200, 8192)
    T2_INIT_HH_3(11, 200, 8192)
    T5_INIT_1(12, 110, 4096)
    T1_INIT_3(13, 110, 262144)
    MRB_INIT_1(14, 110, 131072, 14,  8)
    T3_INIT_HH_2(15, 110, 8192)
    T2_INIT_HH_3(16, 110, 16384)
    T2_INIT_HH_3(17, 110, 4096)
    T2_INIT_HH_1(18, 220, 16384)
    T1_INIT_3(19, 221, 131072)
    MRAC_INIT_1(20, 221, 16384, 10, 16)
    UM_INIT_1(21, 221, 10, 16384)
    apply {
        T2_RUN_3_KEY_1( 1, SRCIP, SIZE)
        MRAC_RUN_1_KEY_1( 2, SRCIP)
        UM_RUN_4_KEY_1( 3, SRCIP, 1)
        MRB_RUN_1_KEY_1( 4, DSTIP)
        T2_RUN_2_KEY_1( 5, DSTIP, 1)
        T2_RUN_HH_2_KEY_1( 6, DSTIP, SIZE)
        T2_RUN_HH_2_KEY_1( 7, DSTIP, 1)
        MRAC_RUN_1_KEY_1( 8, DSTIP)
        T1_RUN_1_KEY_2( 9, SRCIP, DSTIP)
        T2_RUN_4_KEY_2(10, SRCIP, DSTIP, SIZE)
        T2_RUN_HH_3_KEY_2(11, SRCIP, DSTIP, SIZE)
        T5_RUN_1_KEY_2(12, SRCIP, SRCPORT)
        T1_RUN_3_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_2(14, DSTIP, DSTPORT)
        T3_RUN_HH_2_KEY_2(15, DSTIP, DSTPORT, SIZE)
        T2_RUN_HH_3_KEY_2(16, DSTIP, DSTPORT, 1)
        T2_RUN_HH_3_KEY_2(17, DSTIP, DSTPORT, SIZE)
        T2_RUN_HH_1_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T1_RUN_3_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_19_est1_1 == 0 || ig_md.d_19_est1_2 == 0 || ig_md.d_19_est1_3 == 0) { /* process_new_flow() */ }
        MRAC_RUN_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        UM_RUN_1_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
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