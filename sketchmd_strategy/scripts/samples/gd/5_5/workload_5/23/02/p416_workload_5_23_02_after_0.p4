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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 524288)
    T2_INIT_HH_3( 2, 100, 16384)
    UM_INIT_3( 3, 100, 10, 16384)
    T1_INIT_3( 4, 100, 524288)
    T1_INIT_3( 5, 100, 131072)
    T3_INIT_HH_3( 6, 100, 16384)
    UM_INIT_4( 7, 100, 10, 16384)
    T1_INIT_4( 8, 200, 524288)
    MRB_INIT_1( 9, 200, 262144, 15,  8)
    T2_INIT_3(10, 200, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_12_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_5;
    //


    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_1() d_13_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
    // 

    T4_INIT_1(15, 110, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_17_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_17_hash_call;
        TCAM_LPM_HLLPCSA() d_17_tcam_lpm;
        GET_BITMASK() d_17_get_bitmask;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_5;
    //

    T1_INIT_3(18, 220, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_20_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_hash_call;
        TCAM_LPM_HLLPCSA() d_20_tcam_lpm;
        GET_BITMASK() d_20_get_bitmask;
        T2_T5_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_2;
    //

    T3_INIT_HH_3(21, 220, 16384)
    UM_INIT_5(22, 220, 11, 32768)
    T3_INIT_HH_4(23, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_32);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_1( 2, SRCIP, SIZE)
        // UnivMon for inst 3
            d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash); 
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16, ig_md.d_3_threshold); 
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16); 
            d_3_index_hash_call_2.apply(SRCIP, ig_md.d_3_index2_16); 
            d_3_index_hash_call_3.apply(SRCIP, ig_md.d_3_index3_16); 
            UM_RUN_END_3(3, ig_md.d_3_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(3) 
        //

        T1_RUN_3_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_3_KEY_1( 6, DSTIP, SIZE)
        // UnivMon for inst 7
            d_7_res_hash_call.apply(DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(DSTIP, ig_md.d_7_index4_16); 
            UM_RUN_END_4(7, ig_md.d_7_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(7) 
        //

        T1_RUN_4_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_32);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_32, ig_md.d_9_index1_16);
        //

        T2_RUN_3_KEY_2(10, SRCIP, DSTIP, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_12_1.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_12_est_3);
            update_12_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_12_est_4);
            update_12_5.apply(SRCIP, SRCPORT, SIZE, ig_md.d_12_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(12)
        //


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_13_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(13)
        // 

        // HLL for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_32, ig_md.d_15_level);
            update_15.apply(DSTIP, DSTPORT, ig_md.d_15_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_17_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_17_level);
            d_17_get_bitmask.apply(ig_md.d_17_level, ig_md.d_17_bitmask);
            update_17_1.apply(DSTIP, DSTPORT, 1, ig_md.d_17_bitmask, ig_md.d_17_est_1);
            update_17_2.apply(DSTIP, DSTPORT, 1, ig_md.d_17_est_2);
            update_17_3.apply(DSTIP, DSTPORT, 1, ig_md.d_17_est_3);
            update_17_4.apply(DSTIP, DSTPORT, 1, ig_md.d_17_est_4);
            update_17_5.apply(DSTIP, DSTPORT, 1, ig_md.d_17_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(17)
        //

        T1_RUN_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_20_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_bitmask, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(20)
        //

        T3_RUN_AFTER_3_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 22
            d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index2_16); 
            d_22_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index3_16); 
            d_22_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index4_16); 
            d_22_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index5_16); 
            UM_RUN_END_5(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(22) 
        //

        T3_RUN_AFTER_4_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
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