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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    T2_INIT_HH_2( 2, 100, 4096)
    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    MRB_INIT_1( 4, 100, 131072, 14,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 100)
        ABOVE_THRESHOLD_2() d_8_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_8_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_8_2;
    // 

    UM_INIT_3( 9, 100, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_10_tcam_lpm;
        GET_BITMASK() d_10_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_11_above_threshold;
        T2_T5_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 200)
        ABOVE_THRESHOLD_5() d_13_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_13_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_13_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_13_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_13_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_13_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_13_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_13_5;
    // 

    T1_INIT_5(14, 110, 524288)
    T3_INIT_HH_3(16, 110, 16384)
    T3_INIT_HH_4(15, 110, 16384)
    T1_INIT_3(17, 110, 262144)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_18_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_18_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_18_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_18_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_18_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_18_above_threshold;
    // 

    MRAC_INIT_1(20, 110, 32768, 11, 16)
    T1_INIT_1(21, 220, 524288)
    T1_INIT_1(22, 220, 524288)
    T2_INIT_4(23, 220, 16384)
    UM_INIT_2(24, 220, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_13_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_20_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_AFTER_2_KEY_1( 2, SRCIP, SIZE)
        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        // MRB for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_32);
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_32, ig_md.d_4_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_5_1.apply(DSTIP, SIZE, 1, ig_md.d_5_est_1);
            update_5_2.apply(DSTIP, SIZE, 1, ig_md.d_5_est_2);
            update_5_3.apply(DSTIP, SIZE, 1, ig_md.d_5_est_3);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_6_above_threshold);
            update_5_4.apply(DSTIP, SIZE, ig_md.d_5_est_4);
            update_5_5.apply(DSTIP, SIZE, ig_md.d_5_est_5);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(DSTIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(8)
        // 

        // UnivMon for inst 9
            d_9_res_hash_call.apply(DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(DSTIP, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(DSTIP, ig_md.d_9_index3_16); 
            UM_RUN_END_3(9, ig_md.d_9_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(9) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
            d_10_get_bitmask.apply(ig_md.d_10_level, ig_md.d_10_bitmask);
            update_10_1.apply(SRCIP, DSTIP, 1, ig_md.d_10_bitmask, ig_md.d_10_est_1);
            d_11_above_threshold.apply(ig_md.d_10_est_1, ig_md.d_11_above_threshold);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        d_13_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_13_index3_16);
        update_13_3.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index3_16, ig_md.d_13_res_hash[3:3], 1, ig_md.d_13_est_3);
        d_13_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_13_index4_16);
        update_13_4.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index4_16, ig_md.d_13_res_hash[4:4], 1, ig_md.d_13_est_4);
        d_13_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_13_index5_16);
        update_13_5.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index5_16, ig_md.d_13_res_hash[5:5], 1, ig_md.d_13_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(13)
        // 

        T1_RUN_5_KEY_2(14, SRCIP, SRCPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0 || ig_md.d_14_est1_5 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_3_KEY_2(16, SRCIP, SRCPORT, 1)
        T3_RUN_AFTER_4_KEY_2(15, SRCIP, SRCPORT, 1)
        T1_RUN_3_KEY_2(17, DSTIP, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_5_KEY_2(18, DSTIP, DSTPORT, 1)
        // 

        // MRAC for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16);
            d_20_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_20_index1_16);
            update_20.apply(ig_md.d_20_base_16, ig_md.d_20_index1_16);
        //

        T1_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T1_RUN_1_KEY_4(22, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_4_KEY_4(23, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 24
            d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_res_hash); 
            d_24_tcam_lpm.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16, ig_md.d_24_threshold); 
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_index1_16); 
            d_24_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_index2_16); 
            UM_RUN_END_2(24, ig_md.d_24_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(24) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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