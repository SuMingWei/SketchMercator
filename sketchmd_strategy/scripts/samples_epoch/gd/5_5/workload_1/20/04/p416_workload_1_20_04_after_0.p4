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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(131072, 17, 40960)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
    //

    T2_INIT_HH_1( 1, 100, 8192)
    T2_INIT_HH_2( 3, 100, 4096)
    T2_INIT_HH_2( 2, 100, 8192)
    T2_INIT_HH_2( 4, 100, 16384)
    T2_INIT_HH_4( 5, 100, 16384)
    T2_INIT_HH_5( 7, 100, 16384)
    T2_INIT_HH_1( 8, 100, 16384)
    T2_INIT_HH_4( 6, 100, 4096)
    T2_INIT_HH_2( 9, 200, 4096)
    T2_INIT_HH_5(10, 200, 4096)
    T2_INIT_HH_3(11, 200, 4096)
    T2_INIT_HH_2(12, 110, 4096)
    T2_INIT_HH_4(13, 110, 8192)
    T2_INIT_HH_4(15, 110, 16384)
    T2_INIT_HH_4(14, 110, 8192)
    T2_INIT_HH_3(16, 110, 8192)
    T2_INIT_HH_4(17, 110, 4096)
    T2_INIT_HH_1(18, 220, 4096)
    T2_INIT_HH_3(19, 221, 4096)
    T2_INIT_HH_1(20, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
        //

        T2_RUN_AFTER_1_KEY_1( 1, SRCIP, 1)
        T2_RUN_AFTER_2_KEY_1( 3, SRCIP, SIZE)
        T2_RUN_AFTER_2_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_2_KEY_1( 4, SRCIP, SIZE)
        T2_RUN_AFTER_4_KEY_1( 5, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_1( 7, DSTIP, SIZE)
        T2_RUN_AFTER_1_KEY_1( 8, DSTIP, SIZE)
        T2_RUN_AFTER_4_KEY_1( 6, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_2( 9, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_3_KEY_2(11, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_2(12, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_4_KEY_2(13, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_4_KEY_2(15, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_4_KEY_2(14, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_3_KEY_2(16, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_4_KEY_2(17, DSTIP, DSTPORT, SIZE)
        T2_RUN_AFTER_1_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_3_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_AFTER_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport, ig_md.hf_proto); 
        }

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