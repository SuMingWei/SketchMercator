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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T1_INIT_2( 1, 100, 262144)
    T1_INIT_4( 2, 100, 524288)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(4, 100)
        ABOVE_THRESHOLD_2() d_4_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_4_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_4_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_4_2;
    // 

    MRB_INIT_1( 5, 100, 524288, 15, 16)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_7_hash_call;
        TCAM_LPM_HLLPCSA() d_7_tcam_lpm;
        GET_BITMASK() d_7_get_bitmask;
        T5_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_5;
    //
    T1_INIT_1( 9, 200, 524288)
    T2_INIT_HH_5(10, 200, 16384)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(12, 200)
        ABOVE_THRESHOLD_3() d_12_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_12_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_12_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_12_3;
    // 

    T1_INIT_3(13, 110, 524288)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_15_above_threshold;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_14_1;
    //
    MRAC_INIT_1(16, 110, 32768, 11, 16)
    T1_INIT_3(17, 220, 262144)
    T1_INIT_5(18, 220, 131072)

    // apply O2
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_19_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_19_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_19_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_19_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_19_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_19_above_threshold;
    // 


    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(23, 220)
        ABOVE_THRESHOLD_4() d_23_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_23_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_23_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_23_2;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_23_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_23_3;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_23_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_23_4;
    // 

    UM_INIT_3(22, 220, 10, 16384)
    MRB_INIT_1(24, 221, 262144, 14, 16)
    T2_INIT_4(25, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }

        // apply O3; big - UnivMon / small - many MRACs 
        d_4_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);
        d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash);
        d_4_tcam_lpm_2.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16_1024, ig_md.d_4_base_16_2048, ig_md.d_4_threshold);
        d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
        update_4_1.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index1_16, ig_md.d_4_res_hash[1:1], 1, ig_md.d_4_est_1);
        d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16);
        update_4_2.apply(ig_md.d_4_base_16_1024, ig_md.d_4_index2_16, ig_md.d_4_res_hash[2:2], 1, ig_md.d_4_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(4)
        // 

        MRB_RUN_1_KEY_1( 5, DSTIP)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_7_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_32);
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            d_7_get_bitmask.apply(ig_md.d_7_level, ig_md.d_7_bitmask);
            update_7_1.apply(DSTIP, 1, ig_md.d_7_bitmask, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, 1, ig_md.d_7_est_2);
            d_8_above_threshold.apply(ig_md.d_7_est_2, ig_md.d_8_above_threshold);
            update_7_3.apply(DSTIP, 1, ig_md.d_7_est_3);
            update_7_4.apply(DSTIP, 1, ig_md.d_7_est_4);
            update_7_5.apply(DSTIP, 1, ig_md.d_7_est_5);
        //
        T1_RUN_1_KEY_2( 9, SRCIP, DSTIP) if (ig_md.d_9_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)

        // apply O3; big - UnivMon / small - many MRACs 
        d_12_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);
        d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], 1, ig_md.d_12_est_1);
        d_12_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_12_index2_16);
        update_12_2.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index2_16, ig_md.d_12_res_hash[2:2], 1, ig_md.d_12_est_2);
        d_12_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_12_index3_16);
        update_12_3.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index3_16, ig_md.d_12_res_hash[3:3], 1, ig_md.d_12_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(12)
        // 

        T1_RUN_3_KEY_2(13, SRCIP, SRCPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash);
            update_14_1.apply(DSTIP, DSTPORT, 1, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
            d_15_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_15_above_threshold);
        //
        MRAC_RUN_1_KEY_2(16, DSTIP, DSTPORT)
        T1_RUN_3_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0 || ig_md.d_18_est1_4 == 0 || ig_md.d_18_est1_5 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_5_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 


        // apply O3; big - UnivMon / small - many MRACs 
        d_23_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_sampling_hash_16);
        d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], 1, ig_md.d_23_est_1);
        d_23_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index2_16);
        update_23_2.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index2_16, ig_md.d_23_res_hash[2:2], 1, ig_md.d_23_est_2);
        d_23_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index3_16);
        update_23_3.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index3_16, ig_md.d_23_res_hash[3:3], 1, ig_md.d_23_est_3);
        d_23_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index4_16);
        update_23_4.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index4_16, ig_md.d_23_res_hash[4:4], 1, ig_md.d_23_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(23)
        // 

        UM_RUN_AFTER_3_KEY_4(22, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        MRB_RUN_1_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_4_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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