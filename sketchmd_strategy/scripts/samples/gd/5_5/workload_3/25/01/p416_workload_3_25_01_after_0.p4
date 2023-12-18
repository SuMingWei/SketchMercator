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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_25_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 131072)
    T1_INIT_2( 2, 100, 524288)
    T4_INIT_1( 3, 100, 65536)
    MRB_INIT_1( 4, 100, 131072, 14,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 100)
        ABOVE_THRESHOLD_3() d_8_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_8_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_8_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_8_3;
    // 

    T1_INIT_1( 9, 100, 524288)
    UM_INIT_2(10, 100, 11, 32768)
    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_11_tcam_lpm;
        T4_T4_KEY_UPDATE_200_32768(32w0x30243f0b) update_11_1;
    //


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_13_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_13_above_threshold;
    // 

    T2_INIT_HH_5(14, 200, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_17_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_3;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_17_5;
    //

    T1_INIT_1(18, 220, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_21_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_21_hash_call;
        TCAM_LPM_HLLPCSA() d_21_tcam_lpm;
        GET_BITMASK() d_21_get_bitmask;
        T2_T5_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_21_5;
    //


    // apply O2
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_20_above_threshold;
    // 

    T3_INIT_HH_2(23, 221, 4096)
    T3_INIT_HH_4(24, 221, 4096)
    MRAC_INIT_1(25, 221, 8192, 10,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, ig_md.d_8_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(DSTIP, ig_md.d_10_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_32);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_32);

            d_25_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0) { /* process_new_flow() */ }
        // HLL for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_3_level);
            update_3.apply(SRCIP, ig_md.d_3_level);
        //

        // MRB for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_32);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_32, ig_md.d_4_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_6_1.apply(SRCIP, 1, 1, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, 1, 1, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, 1, 1, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, 1, 1, ig_md.d_6_est_4);
            update_6_5.apply(SRCIP, 1, ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(SRCIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(SRCIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(SRCIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(SRCIP, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(8)
        // 

        T1_RUN_1_KEY_1( 9, DSTIP) if (ig_md.d_9_est1_1 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 10
            d_10_res_hash_call.apply(DSTIP, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(DSTIP, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(DSTIP, ig_md.d_10_index2_16); 
            UM_RUN_END_2(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(10) 
        //

        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_32, ig_md.d_11_level);
            update_11_1.apply(SRCIP, DSTIP, ig_md.d_11_level);
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(13, SRCIP, DSTIP, 1)
        // 

        T2_RUN_AFTER_5_KEY_2(14, SRCIP, DSTIP, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_17_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_1);
            update_17_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_2);
            update_17_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_3);
            update_17_4.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_4);
            update_17_5.apply(DSTIP, DSTPORT, 1, ig_md.d_17_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(17)
        //

        T1_RUN_1_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_21_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_21_level);
            d_21_get_bitmask.apply(ig_md.d_21_level, ig_md.d_21_bitmask);
            update_21_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_bitmask, ig_md.d_21_est_1);
            update_21_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_est_2);
            update_21_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_est_3);
            update_21_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_est_4);
            update_21_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_21_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(21)
        //


        // apply O2
        T2_RUN_AFTER_4_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 

        T3_RUN_AFTER_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T3_RUN_AFTER_4_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 25
            d_25_tcam_lpm.apply(ig_md.d_25_sampling_hash_16, ig_md.d_25_base_16);
            d_25_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index1_16);
            update_25.apply(ig_md.d_25_base_16, ig_md.d_25_index1_16);
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
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