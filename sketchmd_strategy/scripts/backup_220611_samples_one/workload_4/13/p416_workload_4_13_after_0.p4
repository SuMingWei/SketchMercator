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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_2_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_hash_call;
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        GET_BITMASK() d_2_get_bitmask;
        T2_T5_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_5;
    //
    T2_INIT_HH_1( 3, 100, 8192)
    MRAC_INIT_1( 4, 100, 16384, 11,  8)
    T2_INIT_HH_3( 5, 200, 4096)
    MRAC_INIT_1( 6, 200, 16384, 10, 16)
    T1_INIT_5( 7, 110, 262144)
    T1_INIT_4( 8, 110, 524288)
    T2_INIT_HH_2( 9, 110, 8192)
    UM_INIT_4(10, 110, 11, 32768)
    T4_INIT_1(11, 220, 32768)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_12_hash_call;
        TCAM_LPM_HLLPCSA() d_12_tcam_lpm;
        GET_BITMASK() d_12_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_13_above_threshold;
        T2_T5_KEY_UPDATE_221_16384(32w0x30243f0b) update_12_1;
    //

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_2_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            d_2_get_bitmask.apply(ig_md.d_2_level, ig_md.d_2_bitmask);
            update_2_1.apply(SRCIP, SIZE, ig_md.d_2_bitmask, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, SIZE, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, SIZE, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, SIZE, ig_md.d_2_est_4);
            update_2_5.apply(SRCIP, SIZE, ig_md.d_2_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(2)
        //
        T2_RUN_AFTER_1_KEY_1( 3, DSTIP, SIZE)
        MRAC_RUN_1_KEY_1( 4, DSTIP)
        T2_RUN_AFTER_3_KEY_2( 5, SRCIP, DSTIP, SIZE)
        MRAC_RUN_1_KEY_2( 6, SRCIP, DSTIP)
        T1_RUN_5_KEY_2( 7, SRCIP, SRCPORT) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0 || ig_md.d_7_est1_4 == 0 || ig_md.d_7_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 8, DSTIP, DSTPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2( 9, DSTIP, DSTPORT, SIZE)
        UM_RUN_AFTER_4_KEY_2(10, DSTIP, DSTPORT, SIZE)
        T4_RUN_1_KEY_4(11, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_12_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_32);
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            d_12_get_bitmask.apply(ig_md.d_12_level, ig_md.d_12_bitmask);
            update_12_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_12_bitmask, ig_md.d_12_est_1);
            d_13_above_threshold.apply(ig_md.d_12_est_1, ig_md.d_13_above_threshold);
        //
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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