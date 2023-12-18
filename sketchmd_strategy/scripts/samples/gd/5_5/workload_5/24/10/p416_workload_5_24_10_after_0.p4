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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(65536, 16, 32768)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 100, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(5, 100)
        ABOVE_THRESHOLD_2() d_5_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_5_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_5_2;
    // 

    T2_INIT_HH_1( 7, 100, 8192)
    T3_INIT_HH_2( 6, 100, 16384)
    T1_INIT_5( 8, 200, 524288)
    T2_INIT_HH_2(10, 200, 16384)
    T2_INIT_HH_4( 9, 200, 4096)
    UM_INIT_1(12, 200, 11, 32768)
    UM_INIT_2(11, 200, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_14_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_res_hash_call;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_3;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_4;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_5;
    //

    T1_INIT_4(15, 110, 524288)
    T2_INIT_HH_2(16, 110, 8192)
    T2_INIT_HH_3(18, 110, 4096)
    T2_INIT_HH_4(17, 110, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_20_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_hash_call;
        TCAM_LPM_HLLPCSA() d_20_tcam_lpm;
        GET_BITMASK() d_20_get_bitmask;
        T2_T5_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_2;
    //

    T2_INIT_HH_3(21, 220, 8192)
    T2_INIT_HH_4(22, 220, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_24_above_threshold;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_23_1;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_23_2;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_23_3;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_32);

        //

        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, SIZE, 1, ig_md.d_2_est_1);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_3_above_threshold);
            update_2_2.apply(SRCIP, SIZE, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, SIZE, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, SIZE, ig_md.d_2_est_4);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash);
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048, ig_md.d_5_threshold);
        d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
        update_5_1.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index1_16, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
        d_5_index_hash_call_2.apply(SRCIP, ig_md.d_5_index2_16);
        update_5_2.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index2_16, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(5)
        // 

        T2_RUN_AFTER_1_KEY_1( 7, DSTIP, 1)
        T3_RUN_AFTER_2_KEY_1( 6, DSTIP, SIZE)
        T1_RUN_5_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0 || ig_md.d_8_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(10, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_4_KEY_2( 9, SRCIP, DSTIP, SIZE)
        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16); 
            UM_RUN_END_1(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(12) 
        //

        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_11_index2_16); 
            UM_RUN_END_2(11, ig_md.d_11_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(11) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash);
            update_14_1.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[2:2], SIZE, ig_md.d_14_est_2);
            update_14_3.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[3:3], SIZE, ig_md.d_14_est_3);
            update_14_4.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[4:4], ig_md.d_14_est_4);
            update_14_5.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[5:5], ig_md.d_14_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(14)
        //

        T1_RUN_4_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(16, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_3_KEY_2(18, DSTIP, DSTPORT, SIZE)
        T2_RUN_AFTER_4_KEY_2(17, DSTIP, DSTPORT, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_20_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_20_bitmask, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_20_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(20)
        //

        T2_RUN_AFTER_3_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_AFTER_4_KEY_4(22, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_23_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_23_est_1);
            update_23_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_23_est_2);
            update_23_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_23_est_3);
            d_24_above_threshold.apply(ig_md.d_23_est_1, ig_md.d_23_est_2, ig_md.d_23_est_3, ig_md.d_24_above_threshold);
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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