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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        GET_BITMASK() d_2_get_bitmask;
        T5_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_5;
    //

    UM_INIT_3( 4, 100, 10, 16384)
    MRB_INIT_1( 5, 100, 262144, 15,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_7_above_threshold;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_2;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_3;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_5;
    //

    UM_INIT_5( 8, 100, 10, 16384)
    T1_INIT_4( 9, 200, 262144)
    T2_INIT_HH_5(10, 200, 16384)
    MRAC_INIT_1(11, 200, 32768, 11, 16)
    T2_INIT_4(12, 110, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(15, 110)
        ABOVE_THRESHOLD_5() d_15_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_15_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_15_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_15_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_15_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_15_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_15_4;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_15_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_15_5;
    // 

    T1_INIT_2(16, 220, 524288)
    T1_INIT_5(17, 220, 262144)
    T4_INIT_1(18, 220, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 220)
        ABOVE_THRESHOLD_2() d_20_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_20_2;
    // 

    T1_INIT_1(22, 221, 524288)
    T1_INIT_4(21, 221, 524288)
    T3_INIT_HH_2(23, 221, 4096)
    T3_INIT_HH_3(24, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_32);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_2_level);
            d_2_get_bitmask.apply(ig_md.d_2_level, ig_md.d_2_bitmask);
            update_2_1.apply(SRCIP, SIZE, ig_md.d_2_bitmask, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, SIZE, SIZE, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, SIZE, SIZE, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, SIZE, SIZE, ig_md.d_2_est_4);
            d_3_above_threshold.apply(ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_2_est_4, ig_md.d_3_above_threshold);
            update_2_5.apply(SRCIP, SIZE, ig_md.d_2_est_5);
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            UM_RUN_END_3(4, ig_md.d_4_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(4) 
        //

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash);
            update_6_1.apply(DSTIP, 1, ig_md.d_6_res_hash[1:1], SIZE, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, 1, ig_md.d_6_res_hash[2:2], SIZE, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, 1, ig_md.d_6_res_hash[3:3], SIZE, ig_md.d_6_est_3);
            update_6_4.apply(DSTIP, 1, ig_md.d_6_res_hash[4:4], SIZE, ig_md.d_6_est_4);
            d_7_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_6_est_4, ig_md.d_7_above_threshold);
            update_6_5.apply(DSTIP, 1, ig_md.d_6_est_5);
        //

        // UnivMon for inst 8
            d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(DSTIP, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(DSTIP, ig_md.d_8_index3_16); 
            d_8_index_hash_call_4.apply(DSTIP, ig_md.d_8_index4_16); 
            d_8_index_hash_call_5.apply(DSTIP, ig_md.d_8_index5_16); 
            UM_RUN_END_5(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(8) 
        //

        T1_RUN_4_KEY_2( 9, SRCIP, DSTIP) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0 || ig_md.d_9_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        T2_RUN_4_KEY_2(12, SRCIP, SRCPORT, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_15_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_res_hash);
        d_15_tcam_lpm_2.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16_1024, ig_md.d_15_base_16_2048, ig_md.d_15_threshold);
        d_15_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_15_index1_16);
        update_15_1.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index1_16, ig_md.d_15_res_hash[1:1], SIZE, ig_md.d_15_est_1);
        d_15_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_15_index2_16);
        update_15_2.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index2_16, ig_md.d_15_res_hash[2:2], SIZE, ig_md.d_15_est_2);
        d_15_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_15_index3_16);
        update_15_3.apply(ig_md.d_15_base_16_1024, ig_md.d_15_index3_16, ig_md.d_15_res_hash[3:3], SIZE, ig_md.d_15_est_3);
        d_15_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_15_index4_16);
        update_15_4.apply(ig_md.d_15_base_16_1024, ig_md.d_15_index4_16, ig_md.d_15_res_hash[4:4], SIZE, ig_md.d_15_est_4);
        d_15_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_15_index5_16);
        update_15_5.apply(ig_md.d_15_base_16_1024, ig_md.d_15_index5_16, ig_md.d_15_res_hash[5:5], SIZE, ig_md.d_15_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(15)
        // 

        T1_RUN_2_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0 || ig_md.d_17_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_18_level);
            update_18.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_level);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(20)
        // 

        T1_RUN_1_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T1_RUN_4_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0 || ig_md.d_21_est1_4 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T3_RUN_AFTER_3_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
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
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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