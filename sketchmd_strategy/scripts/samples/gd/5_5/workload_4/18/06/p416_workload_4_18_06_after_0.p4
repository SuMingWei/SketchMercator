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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 100, 262144)
    T3_INIT_HH_4( 2, 100, 4096)
    T4_INIT_1( 3, 100, 16384)
    T1_INIT_4( 4, 200, 524288)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(6, 200)
        ABOVE_THRESHOLD_5() d_6_above_threshold;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_6_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_6_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_6_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_6_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_6_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_6_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_6_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_6_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_6_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_6_5;
    // 

    T2_INIT_HH_2( 8, 110, 4096)
    T3_INIT_HH_4( 7, 110, 16384)
    UM_INIT_5( 9, 110, 10, 16384)
    T1_INIT_5(10, 110, 524288)
    T2_INIT_HH_1(11, 110, 8192)
    UM_INIT_2(12, 110, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_14_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_14_hash_call;
        TCAM_LPM_HLLPCSA() d_14_tcam_lpm;
        GET_BITMASK() d_14_get_bitmask;
        T2_T5_KEY_UPDATE_220_4096(32w0x30243f0b) update_14_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_14_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_14_3;
    //

    T2_INIT_HH_4(15, 220, 4096)
    MRAC_INIT_1(16, 220, 16384, 10, 16)
    T1_INIT_1(17, 221, 131072)
    MRB_INIT_1(18, 221, 131072, 14,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

        //

        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_1( 2, SRCIP, SIZE)
        // HLL for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_3_level);
            update_3.apply(DSTIP, ig_md.d_3_level);
        //

        T1_RUN_4_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash);
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048, ig_md.d_6_threshold);
        d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16);
        update_6_1.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index1_16, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_1);
        d_6_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_6_index2_16);
        update_6_2.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index2_16, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_2);
        d_6_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_6_index3_16);
        update_6_3.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index3_16, ig_md.d_6_res_hash[3:3], 1, ig_md.d_6_est_3);
        d_6_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_6_index4_16);
        update_6_4.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index4_16, ig_md.d_6_res_hash[4:4], 1, ig_md.d_6_est_4);
        d_6_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_6_index5_16);
        update_6_5.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index5_16, ig_md.d_6_res_hash[5:5], 1, ig_md.d_6_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(6)
        // 

        T2_RUN_AFTER_2_KEY_2( 8, SRCIP, SRCPORT, 1)
        T3_RUN_AFTER_4_KEY_2( 7, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_9_index3_16); 
            d_9_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_9_index4_16); 
            d_9_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_9_index5_16); 
            UM_RUN_END_5(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(9) 
        //

        T1_RUN_5_KEY_2(10, DSTIP, DSTPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0 || ig_md.d_10_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2(11, DSTIP, DSTPORT, SIZE)
        // UnivMon for inst 12
            d_12_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_12_index2_16); 
            UM_RUN_END_2(12, ig_md.d_12_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(12) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_14_tcam_lpm.apply(ig_md.d_13_sampling_hash_32, ig_md.d_14_level);
            d_14_get_bitmask.apply(ig_md.d_14_level, ig_md.d_14_bitmask);
            update_14_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_bitmask, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_est_2);
            update_14_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(14)
        //

        T2_RUN_AFTER_4_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        T1_RUN_1_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_17_est1_1 == 0) { /* process_new_flow() */ }
        // MRB for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_32);
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index1_16);
            update_18.apply(ig_md.d_18_base_32, ig_md.d_18_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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