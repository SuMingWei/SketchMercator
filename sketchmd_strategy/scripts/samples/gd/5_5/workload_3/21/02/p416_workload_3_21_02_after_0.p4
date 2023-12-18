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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_5;
    //

    MRAC_INIT_1( 3, 100, 16384, 10, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_3;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_5;
    //

    MRAC_INIT_1( 6, 100, 16384, 10, 16)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 200)
        ABOVE_THRESHOLD_4() d_8_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_8_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_8_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_8_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_8_4;
    // 

    T3_INIT_HH_5( 9, 110, 8192)
    MRAC_INIT_1(10, 110, 16384, 10, 16)
    T1_INIT_1(11, 110, 131072)
    T2_INIT_HH_2(12, 110, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(14, 110)
        ABOVE_THRESHOLD_5() d_14_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_14_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_14_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_14_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_14_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_14_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_14_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_14_4;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_14_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_14_5;
    // 

    T4_INIT_1(15, 220, 32768)
    MRB_INIT_1(16, 220, 131072, 14,  8)
    T2_INIT_HH_5(17, 220, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_20_above_threshold;
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_20_hash_call;
        TCAM_LPM_HLLPCSA() d_20_tcam_lpm;
        GET_BITMASK() d_20_get_bitmask;
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_20_res_hash_call;
        T3_T5_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_1;
        T3_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_2;
        T3_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_3;
        T3_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_4;
    //

    MRAC_INIT_1(21, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_32);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_1_1.apply(SRCIP, 1, 1, ig_md.d_1_est_1);
            update_1_2.apply(SRCIP, 1, ig_md.d_1_est_2);
            update_1_3.apply(SRCIP, 1, ig_md.d_1_est_3);
            update_1_4.apply(SRCIP, 1, ig_md.d_1_est_4);
            update_1_5.apply(SRCIP, 1, ig_md.d_1_est_5);
        //

        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_4_1.apply(DSTIP, 1, 1, ig_md.d_4_est_1);
            update_4_2.apply(DSTIP, 1, 1, ig_md.d_4_est_2);
            update_4_3.apply(DSTIP, 1, 1, ig_md.d_4_est_3);
            update_4_4.apply(DSTIP, 1, 1, ig_md.d_4_est_4);
            update_4_5.apply(DSTIP, 1, ig_md.d_4_est_5);
        //

        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        d_8_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_8_index4_16);
        update_8_4.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index4_16, ig_md.d_8_res_hash[4:4], 1, ig_md.d_8_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(8)
        // 

        T3_RUN_AFTER_5_KEY_2( 9, SRCIP, SRCPORT, 1)
        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T1_RUN_1_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(12, DSTIP, DSTPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
        d_14_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_14_index2_16);
        update_14_2.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index2_16, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
        d_14_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_14_index3_16);
        update_14_3.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index3_16, ig_md.d_14_res_hash[3:3], 1, ig_md.d_14_est_3);
        d_14_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_14_index4_16);
        update_14_4.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index4_16, ig_md.d_14_res_hash[4:4], 1, ig_md.d_14_est_4);
        d_14_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_14_index5_16);
        update_14_5.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index5_16, ig_md.d_14_res_hash[5:5], 1, ig_md.d_14_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(14)
        // 

        // HLL for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_32, ig_md.d_15_level);
            update_15.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_level);
        //

        // MRB for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_32);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_32, ig_md.d_16_index1_16);
        //

        T2_RUN_AFTER_5_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_20_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_res_hash);
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_res_hash[1:1], ig_md.d_20_bitmask, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
            update_20_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_res_hash[3:3], ig_md.d_20_est_3);
            update_20_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_res_hash[4:4], ig_md.d_20_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(20)
        //

        // MRAC for inst 21
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16);
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
            update_21.apply(ig_md.d_21_base_16, ig_md.d_21_index1_16);
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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