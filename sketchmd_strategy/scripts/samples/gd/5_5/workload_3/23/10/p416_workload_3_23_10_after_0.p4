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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 28672)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 100, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
    //

    UM_INIT_5( 4, 100, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_5;
    //

    UM_INIT_5( 8, 100, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_5;
    //

    T5_INIT_1(12, 110, 16384)
    UM_INIT_4(13, 110, 10, 16384)

    // apply O2
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_14_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(17, 110)
        ABOVE_THRESHOLD_3() d_17_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_17_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_17_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_17_3;
    // 

    UM_INIT_5(18, 110, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_20_above_threshold;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_20_1;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_20_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_20_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_20_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_20_5;
    //

    UM_INIT_4(21, 220, 11, 32768)
    T2_INIT_HH_2(22, 221, 8192)
    UM_INIT_1(23, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
            update_2_1.apply(SRCIP, 1, ig_md.d_2_res_hash[1:1], 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_res_hash[2:2], 1, ig_md.d_2_est_2);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_3_above_threshold);
            update_2_3.apply(SRCIP, 1, ig_md.d_2_est_3);
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16); 
            d_4_index_hash_call_5.apply(SRCIP, ig_md.d_4_index5_16); 
            UM_RUN_END_5(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(4) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_6_1.apply(DSTIP, 1, 1, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, 1, 1, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, 1, 1, ig_md.d_6_est_3);
            d_5_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_5_above_threshold);
            update_6_4.apply(DSTIP, 1, ig_md.d_6_est_4);
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

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_10_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, 1, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, DSTIP, 1, ig_md.d_10_est_4);
            update_10_5.apply(SRCIP, DSTIP, 1, ig_md.d_10_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(10)
        //

        // PCSA for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            d_12_get_bitmask.apply(ig_md.d_12_level, ig_md.d_12_bitmask);
            update_12.apply(SRCIP, SRCPORT, ig_md.d_12_bitmask);
        //

        // UnivMon for inst 13
            d_13_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_13_index3_16); 
            d_13_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_13_index4_16); 
            UM_RUN_END_4(13, ig_md.d_13_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(13) 
        //


        // apply O2
        T2_RUN_AFTER_4_KEY_2(14, DSTIP, DSTPORT, 1)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], 1, ig_md.d_17_est_1);
        d_17_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_17_index2_16);
        update_17_2.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index2_16, ig_md.d_17_res_hash[2:2], 1, ig_md.d_17_est_2);
        d_17_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_17_index3_16);
        update_17_3.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index3_16, ig_md.d_17_res_hash[3:3], 1, ig_md.d_17_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(17)
        // 

        // UnivMon for inst 18
            d_18_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_18_index3_16); 
            d_18_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_18_index4_16); 
            d_18_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_18_index5_16); 
            UM_RUN_END_5(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(18) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_20_est_2);
            update_20_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_20_est_3);
            update_20_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_20_est_4);
            update_20_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_20_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(20)
        //

        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16); 
            d_21_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index4_16); 
            UM_RUN_END_4(21, ig_md.d_21_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(21) 
        //

        T2_RUN_AFTER_2_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // UnivMon for inst 23
            d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_res_hash); 
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16, ig_md.d_23_threshold); 
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16); 
            UM_RUN_END_1(23, ig_md.d_23_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(23) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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