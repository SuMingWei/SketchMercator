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
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_4_tcam_lpm;
        GET_BITMASK() d_4_get_bitmask;
        T5_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_4_1;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_4_2;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_4_4;
    //

    UM_INIT_3( 6, 100, 10, 16384)
    T2_INIT_HH_4( 7, 100, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_sampling_hash_call;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_8_index_hash_call_1;
        LPM_OPT_MRAC_2() d_8_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_8;
    // 

    T1_INIT_1(10, 200, 524288)
    T3_INIT_HH_5(11, 200, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_14_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_3;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(16, 110)
        ABOVE_THRESHOLD_2() d_16_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_16_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_16_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_16_2;
    // 

    T2_INIT_HH_5(17, 110, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 110)
        ABOVE_THRESHOLD_4() d_20_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_20_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_20_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_20_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_20_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_20_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_20_4;
    // 

    T2_INIT_HH_2(22, 220, 16384)
    T3_INIT_HH_3(21, 220, 8192)
    T1_INIT_1(23, 221, 524288)
    T2_INIT_5(24, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(SRCIP, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_16_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_20_sampling_hash_16);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_4_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_4_level);
            d_4_get_bitmask.apply(ig_md.d_4_level, ig_md.d_4_bitmask);
            update_4_1.apply(SRCIP, 1, ig_md.d_4_bitmask, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, 1, 1, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, 1, 1, ig_md.d_4_est_3);
            d_5_above_threshold.apply(ig_md.d_4_est_3, ig_md.d_5_above_threshold);
            update_4_4.apply(SRCIP, 1, ig_md.d_4_est_4);
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(SRCIP, ig_md.d_6_index3_16); 
            UM_RUN_END_3(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(6) 
        //

        T2_RUN_AFTER_4_KEY_1( 7, DSTIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048);
        d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16);
        update_8.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index1_16);
        // 

        T1_RUN_1_KEY_2(10, SRCIP, DSTIP) if (ig_md.d_10_est1_1 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_5_KEY_2(11, SRCIP, DSTIP, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_13_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_13_est_1);
            update_13_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_13_est_2);
            update_13_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_13_est_3);
            update_13_4.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_13_est_4);
            d_14_above_threshold.apply(ig_md.d_13_est_3, ig_md.d_13_est_4, ig_md.d_14_above_threshold);
            update_13_5.apply(SRCIP, SRCPORT, 1, ig_md.d_13_est_5);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_16_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_16_res_hash);
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048, ig_md.d_16_threshold);
        d_16_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_16_index1_16);
        update_16_1.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16, ig_md.d_16_res_hash[1:1], 1, ig_md.d_16_est_1);
        d_16_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_16_index2_16);
        update_16_2.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index2_16, ig_md.d_16_res_hash[2:2], 1, ig_md.d_16_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(16)
        // 

        T2_RUN_AFTER_5_KEY_2(17, DSTIP, DSTPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
        d_20_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_20_index3_16);
        update_20_3.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index3_16, ig_md.d_20_res_hash[3:3], 1, ig_md.d_20_est_3);
        d_20_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_20_index4_16);
        update_20_4.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index4_16, ig_md.d_20_res_hash[4:4], 1, ig_md.d_20_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(20)
        // 

        T2_RUN_AFTER_2_KEY_4(22, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T3_RUN_AFTER_3_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_1_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_5_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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