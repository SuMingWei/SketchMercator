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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_25_auto_sampling_hash_call;

    //

    T2_INIT_2( 1, 100, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_5;
    //

    UM_INIT_1( 4, 100, 11, 32768)
    UM_INIT_2( 5, 100, 11, 32768)
    T1_INIT_1( 7, 200, 524288)
    T1_INIT_2( 8, 200, 262144)
    T1_INIT_4( 6, 200, 524288)
    T2_INIT_HH_1( 9, 200, 4096)
    T2_INIT_HH_2(10, 200, 16384)
    T2_INIT_HH_5(11, 200, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_200_16_8(32w0x30244f0b) d_12_sampling_hash_call;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        LPM_OPT_MRAC_2() d_12_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_12;
    // 

    T2_INIT_HH_1(14, 110, 8192)
    T1_INIT_4(15, 110, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_16_tcam_lpm;
        GET_BITMASK() d_16_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_18_above_threshold;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_1;
    //

    T3_INIT_HH_5(17, 110, 4096)
    MRB_INIT_1(19, 220, 262144, 14, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_21_tcam_lpm;
        GET_BITMASK() d_21_get_bitmask;
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_res_hash_call;
        T5_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_21_1;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_22_above_threshold;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_2;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_21_4;
    //

    MRAC_INIT_1(23, 220, 16384, 10, 16)
    T1_INIT_4(24, 221, 524288)
    UM_INIT_5(25, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_32);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_32);

            d_25_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_sampling_hash_16);

        //

        T2_RUN_2_KEY_1( 1, SRCIP, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, 1, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, 1, ig_md.d_2_est_4);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_2_est_4, ig_md.d_3_above_threshold);
            update_2_5.apply(SRCIP, 1, ig_md.d_2_est_5);
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            UM_RUN_END_1(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(4) 
        //

        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, ig_md.d_5_index2_16); 
            UM_RUN_END_2(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(5) 
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2( 9, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_2(10, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_2(11, SRCIP, DSTIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048);
        d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
        update_12.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16);
        // 

        T2_RUN_AFTER_1_KEY_2(14, SRCIP, SRCPORT, 1)
        T1_RUN_4_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_16_level);
            d_16_get_bitmask.apply(ig_md.d_16_level, ig_md.d_16_bitmask);
            update_16_1.apply(DSTIP, DSTPORT, 1, ig_md.d_16_bitmask, ig_md.d_16_est_1);
            d_18_above_threshold.apply(ig_md.d_16_est_1, ig_md.d_18_above_threshold);
        //

        T3_RUN_AFTER_5_KEY_2(17, DSTIP, DSTPORT, 1)
        // MRB for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_32);
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16);
            update_19.apply(ig_md.d_19_base_32, ig_md.d_19_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_21_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_21_level);
            d_21_get_bitmask.apply(ig_md.d_21_level, ig_md.d_21_bitmask);
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash);
            update_21_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_bitmask, ig_md.d_21_est_1);
            update_21_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_res_hash[2:2], 1, ig_md.d_21_est_2);
            update_21_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_res_hash[3:3], 1, ig_md.d_21_est_3);
            d_22_above_threshold.apply(ig_md.d_21_est_2, ig_md.d_21_est_3, ig_md.d_22_above_threshold);
            update_21_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_est_4);
        //

        // MRAC for inst 23
            d_23_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_23_base_16);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_16, ig_md.d_23_index1_16);
        //

        T1_RUN_4_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_24_est1_1 == 0 || ig_md.d_24_est1_2 == 0 || ig_md.d_24_est1_3 == 0 || ig_md.d_24_est1_4 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 25
            d_25_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_res_hash); 
            d_25_tcam_lpm.apply(ig_md.d_25_sampling_hash_16, ig_md.d_25_base_16, ig_md.d_25_threshold); 
            d_25_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index1_16); 
            d_25_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index2_16); 
            d_25_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index3_16); 
            d_25_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index4_16); 
            d_25_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index5_16); 
            UM_RUN_END_5(25, ig_md.d_25_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(25) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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