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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T4_INIT_1( 1, 100, 65536)
    UM_INIT_1( 2, 100, 10, 16384)
    T2_INIT_HH_2( 3, 100, 8192)
    MRAC_INIT_1( 4, 100, 16384, 11,  8)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_res_hash_call;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_2;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_3;
        T3_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_4;
        T3_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_5;
    //
    T1_INIT_5( 7, 110, 524288)
    T4_INIT_1( 8, 110, 32768)
    T3_INIT_HH_1( 9, 110, 4096)
    UM_INIT_1(11, 110, 11, 32768)
    UM_INIT_2(10, 110, 11, 32768)
    T3_INIT_HH_2(12, 220, 8192)
    T1_INIT_3(13, 221, 524288)
    T1_INIT_5(14, 221, 262144)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T4_RUN_1_KEY_1( 1, SRCIP)
        UM_RUN_AFTER_1_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_2_KEY_1( 3, DSTIP, 1)
        MRAC_RUN_1_KEY_1( 4, DSTIP)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash);
            update_6_1.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[3:3], 1, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[4:4], ig_md.d_6_est_4);
            update_6_5.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[5:5], ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //
        T1_RUN_5_KEY_2( 7, SRCIP, SRCPORT) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0 || ig_md.d_7_est1_4 == 0 || ig_md.d_7_est1_5 == 0) { /* process_new_flow() */ }
        T4_RUN_1_KEY_2( 8, SRCIP, SRCPORT)
        T3_RUN_AFTER_1_KEY_2( 9, SRCIP, SRCPORT, 1)
        UM_RUN_AFTER_1_KEY_2(11, DSTIP, DSTPORT, 1)
        UM_RUN_AFTER_2_KEY_2(10, DSTIP, DSTPORT, 1)
        T3_RUN_AFTER_2_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_3_KEY_5(13, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_5(14, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0 || ig_md.d_14_est1_5 == 0) { /* process_new_flow() */ }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport); 
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