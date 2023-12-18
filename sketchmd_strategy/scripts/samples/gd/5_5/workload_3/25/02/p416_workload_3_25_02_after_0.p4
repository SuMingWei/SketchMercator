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
    METADATA_DIM(25)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_5_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_hash_call;
        TCAM_LPM_HLLPCSA() d_5_tcam_lpm;
        GET_BITMASK() d_5_get_bitmask;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_res_hash_call;
        T3_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_2;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_3;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_4;
    //

    T3_INIT_HH_1( 4, 100, 4096)
    T2_INIT_HH_2( 3, 100, 8192)
    T4_INIT_1( 6, 100, 32768)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_7_above_threshold;
    // 

    MRAC_INIT_1( 9, 100, 32768, 11, 16)
    T2_INIT_HH_5(10, 200, 16384)
    T1_INIT_5(11, 110, 524288)
    T2_INIT_HH_1(12, 110, 4096)
    T2_INIT_HH_1(13, 110, 8192)
    UM_INIT_2(14, 110, 11, 32768)
    T1_INIT_2(16, 110, 131072)
    T1_INIT_4(15, 110, 524288)
    T1_INIT_5(17, 110, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_19_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_19_hash_call;
        TCAM_LPM_HLLPCSA() d_19_tcam_lpm;
        GET_BITMASK() d_19_get_bitmask;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_19_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_19_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_19_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_19_4;
    //

    UM_INIT_1(20, 110, 11, 32768)
    T1_INIT_1(21, 220, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_22_tcam_lpm;
        GET_BITMASK() d_22_get_bitmask;
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_22_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_23_above_threshold;
        T3_T5_KEY_UPDATE_220_8192(32w0x30243f0b) update_22_1;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_24_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_25_above_threshold;
        T3_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_1;
        T3_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_2;
        T3_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_3;
        T3_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_4;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_24_5;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_32);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_32);

            d_20_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_20_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_sampling_hash_32);

        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_5_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_5_level);
            d_5_get_bitmask.apply(ig_md.d_5_level, ig_md.d_5_bitmask);
            d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, 1, ig_md.d_5_res_hash[1:1], ig_md.d_5_bitmask, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, 1, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, 1, ig_md.d_5_res_hash[3:3], 1, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, 1, ig_md.d_5_res_hash[4:4], 1, ig_md.d_5_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(5)
        //

        T3_RUN_AFTER_1_KEY_1( 4, SRCIP, 1)
        T2_RUN_AFTER_2_KEY_1( 3, SRCIP, 1)
        // HLL for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_6_level);
            update_6.apply(DSTIP, ig_md.d_6_level);
        //


        // apply O2
        T2_RUN_AFTER_1_KEY_1(7, DSTIP, 1)
        // 

        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)
        T1_RUN_5_KEY_2(11, SRCIP, SRCPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0 || ig_md.d_11_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2(12, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_1_KEY_2(13, SRCIP, SRCPORT, 1)
        // UnivMon for inst 14
            d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_14_index2_16); 
            UM_RUN_END_2(14, ig_md.d_14_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(14) 
        //

        T1_RUN_2_KEY_2(16, DSTIP, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2(17, DSTIP, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0 || ig_md.d_17_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_19_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_19_level);
            d_19_get_bitmask.apply(ig_md.d_19_level, ig_md.d_19_bitmask);
            update_19_1.apply(DSTIP, DSTPORT, 1, ig_md.d_19_bitmask, ig_md.d_19_est_1);
            update_19_2.apply(DSTIP, DSTPORT, 1, ig_md.d_19_est_2);
            update_19_3.apply(DSTIP, DSTPORT, 1, ig_md.d_19_est_3);
            update_19_4.apply(DSTIP, DSTPORT, 1, ig_md.d_19_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(19)
        //

        // UnivMon for inst 20
            d_20_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_20_res_hash); 
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16, ig_md.d_20_threshold); 
            d_20_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_20_index1_16); 
            UM_RUN_END_1(20, ig_md.d_20_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(20) 
        //

        T1_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_32, ig_md.d_22_level);
            d_22_get_bitmask.apply(ig_md.d_22_level, ig_md.d_22_bitmask);
            d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_res_hash);
            update_22_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_22_res_hash[1:1], ig_md.d_22_bitmask, ig_md.d_22_est_1);
            d_23_above_threshold.apply(ig_md.d_22_est_1, ig_md.d_23_above_threshold);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_res_hash);
            update_24_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_res_hash[1:1], 1, ig_md.d_24_est_1);
            update_24_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_res_hash[2:2], 1, ig_md.d_24_est_2);
            update_24_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_res_hash[3:3], 1, ig_md.d_24_est_3);
            update_24_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_res_hash[4:4], 1, ig_md.d_24_est_4);
            d_25_above_threshold.apply(ig_md.d_24_est_1, ig_md.d_24_est_2, ig_md.d_24_est_3, ig_md.d_24_est_4, ig_md.d_25_above_threshold);
            update_24_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_est_5);
        //

        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
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