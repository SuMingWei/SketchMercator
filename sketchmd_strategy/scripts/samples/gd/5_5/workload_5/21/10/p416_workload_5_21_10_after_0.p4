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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_2;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_6_above_threshold;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_2;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_3;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_4;
    //

    MRAC_INIT_1( 7, 100, 16384, 11,  8)
    T3_INIT_HH_4( 9, 200, 4096)
    T2_INIT_HH_5( 8, 200, 8192)
    T2_INIT_HH_5(10, 200, 16384)
    T1_INIT_1(11, 110, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_3;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_15_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_3;
    //

    T1_INIT_4(17, 220, 131072)
    T1_INIT_4(18, 220, 131072)
    T1_INIT_5(16, 220, 524288)
    T5_INIT_1(19, 220, 8192)
    T1_INIT_4(20, 221, 524288)
    T2_INIT_HH_2(21, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_32);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_4_1.apply(DSTIP, 1, SIZE, ig_md.d_4_est_1);
            update_4_2.apply(DSTIP, 1, ig_md.d_4_est_2);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_3_res_hash_call.apply(DSTIP, ig_md.d_3_res_hash);
            update_3_1.apply(DSTIP, 1, ig_md.d_3_res_hash[1:1], 1, ig_md.d_3_est_1);
            d_6_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_6_above_threshold);
            update_3_2.apply(DSTIP, 1, ig_md.d_3_res_hash[2:2], 1, ig_md.d_3_est_2);
            update_3_3.apply(DSTIP, 1, ig_md.d_3_res_hash[3:3], 1, ig_md.d_3_est_3);
            update_3_4.apply(DSTIP, 1, ig_md.d_3_res_hash[4:4], 1, ig_md.d_3_est_4);
            d_5_above_threshold.apply(ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_3_est_4, ig_md.d_5_above_threshold);
        //

        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        T3_RUN_AFTER_4_KEY_2( 9, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2( 8, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)
        T1_RUN_1_KEY_2(11, SRCIP, SRCPORT)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_13_1.apply(SRCIP, SRCPORT, 1, SIZE, ig_md.d_13_est_1);
            update_13_2.apply(SRCIP, SRCPORT, 1, ig_md.d_13_est_2);
            update_13_3.apply(SRCIP, SRCPORT, 1, ig_md.d_13_est_3);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_14_1.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_14_est_1);
            update_14_2.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_14_est_2);
            d_15_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_14_est_2, ig_md.d_15_above_threshold);
            update_14_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_14_est_3);
        //

        T1_RUN_4_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0 || ig_md.d_18_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0 || ig_md.d_16_est1_4 == 0 || ig_md.d_16_est1_5 == 0) { /* process_new_flow() */ }
        // PCSA for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_19_level);
            d_19_get_bitmask.apply(ig_md.d_19_level, ig_md.d_19_bitmask);
            update_19.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_bitmask);
        //

        T1_RUN_4_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0 || ig_md.d_20_est1_3 == 0 || ig_md.d_20_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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