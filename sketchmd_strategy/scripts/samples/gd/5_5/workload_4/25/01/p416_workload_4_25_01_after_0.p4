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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 24576)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_1_tcam_lpm;
        GET_BITMASK() d_1_get_bitmask;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_2_above_threshold;
        T3_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
    //

    T2_INIT_HH_5( 3, 100, 4096)
    MRAC_INIT_1( 4, 100, 8192, 10,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_5_tcam_lpm;
        GET_BITMASK() d_5_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_6_above_threshold;
        T2_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
    //

    MRAC_INIT_1( 7, 100, 16384, 10, 16)
    T1_INIT_3( 8, 200, 524288)
    UM_INIT_5( 9, 200, 11, 32768)

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_10_1;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_2;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_3;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_4;
    // 

    T3_INIT_HH_3(13, 110, 4096)
    T2_INIT_HH_5(12, 110, 8192)
    T1_INIT_1(14, 110, 262144)
    MRB_INIT_1(15, 110, 262144, 15,  8)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_16_above_threshold;
    // 

    MRAC_INIT_1(18, 110, 16384, 11,  8)
    T2_INIT_HH_4(19, 220, 4096)
    T2_INIT_HH_5(20, 220, 8192)
    UM_INIT_3(21, 220, 11, 32768)
    T1_INIT_3(22, 221, 262144)
    MRB_INIT_1(23, 221, 131072, 14,  8)
    T2_INIT_HH_1(25, 221, 4096)
    T3_INIT_HH_4(24, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            d_1_get_bitmask.apply(ig_md.d_1_level, ig_md.d_1_bitmask);
            d_1_res_hash_call.apply(SRCIP, ig_md.d_1_res_hash);
            update_1_1.apply(SRCIP, SIZE, ig_md.d_1_res_hash[1:1], ig_md.d_1_bitmask, ig_md.d_1_est_1);
            d_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_2_above_threshold);
        //

        T2_RUN_AFTER_5_KEY_1( 3, SRCIP, 1)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            d_5_get_bitmask.apply(ig_md.d_5_level, ig_md.d_5_bitmask);
            update_5_1.apply(DSTIP, 1, ig_md.d_5_bitmask, ig_md.d_5_est_1);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_6_above_threshold);
        //

        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        T1_RUN_3_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_9_index3_16); 
            d_9_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_9_index4_16); 
            d_9_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_9_index5_16); 
            UM_RUN_END_5(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(9) 
        //


        // apply O2
        T1_RUN_4_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0) { /* process_new_flow() */ }
        // 

        T3_RUN_AFTER_3_KEY_2(13, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_5_KEY_2(12, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0) { /* process_new_flow() */ }
        // MRB for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_32);
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_32, ig_md.d_15_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(16, DSTIP, DSTPORT, 1)
        // 

        // MRAC for inst 18
            d_18_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_18_base_16);
            d_18_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_18_index1_16);
            update_18.apply(ig_md.d_18_base_16, ig_md.d_18_index1_16);
        //

        T2_RUN_AFTER_4_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16); 
            UM_RUN_END_3(21, ig_md.d_21_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(21) 
        //

        T1_RUN_3_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_22_est1_1 == 0 || ig_md.d_22_est1_2 == 0 || ig_md.d_22_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_32);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_32, ig_md.d_23_index1_16);
        //

        T2_RUN_AFTER_1_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        T3_RUN_AFTER_4_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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