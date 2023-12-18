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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 524288)
    T4_INIT_1( 2, 100, 32768)
    T2_INIT_HH_1( 4, 100, 4096)
    T3_INIT_HH_1( 6, 100, 16384)
    T2_INIT_HH_2( 5, 100, 8192)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
    // 

    T4_INIT_1( 8, 200, 65536)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 200)
        ABOVE_THRESHOLD_5() d_10_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_10_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_10_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_10_4;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_10_5;
    // 

    T1_INIT_2(11, 110, 262144)
    T1_INIT_2(12, 110, 524288)
    T1_INIT_3(13, 110, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_15_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_5;
    //

    UM_INIT_4(16, 110, 11, 32768)
    UM_INIT_4(17, 110, 11, 32768)
    T1_INIT_3(18, 220, 524288)
    T5_INIT_1(19, 220, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(21, 220)
        ABOVE_THRESHOLD_4() d_21_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_21_1;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_21_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_21_2;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_21_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_21_3;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_21_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_21_4;
    // 

    T1_INIT_5(22, 221, 131072)
    T4_INIT_1(23, 221, 32768)
    T2_INIT_HH_1(24, 221, 8192)
    T3_INIT_HH_1(25, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_32);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_16_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_32);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_32);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2.apply(SRCIP, ig_md.d_2_level);
        //

        T2_RUN_AFTER_1_KEY_1( 4, DSTIP, 1)
        T3_RUN_AFTER_1_KEY_1( 6, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_1( 5, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_3_KEY_1(3, DSTIP, 1)
        // 

        // HLL for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            update_8.apply(SRCIP, DSTIP, ig_md.d_8_level);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], 1, ig_md.d_10_est_3);
        d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16);
        update_10_4.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index4_16, ig_md.d_10_res_hash[4:4], 1, ig_md.d_10_est_4);
        d_10_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_10_index5_16);
        update_10_5.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index5_16, ig_md.d_10_res_hash[5:5], 1, ig_md.d_10_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(10)
        // 

        T1_RUN_2_KEY_2(11, SRCIP, SRCPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2(12, SRCIP, SRCPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_2(13, SRCIP, SRCPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash);
            update_14_1.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
            update_14_3.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[3:3], 1, ig_md.d_14_est_3);
            d_15_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_14_est_2, ig_md.d_14_est_3, ig_md.d_15_above_threshold);
            update_14_4.apply(SRCIP, SRCPORT, 1, ig_md.d_14_est_4);
            update_14_5.apply(SRCIP, SRCPORT, 1, ig_md.d_14_est_5);
        //

        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_16_index3_16); 
            d_16_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_16_index4_16); 
            UM_RUN_END_4(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(16) 
        //

        // UnivMon for inst 17
            d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_17_index3_16); 
            d_17_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_17_index4_16); 
            UM_RUN_END_4(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(17) 
        //

        T1_RUN_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0) { /* process_new_flow() */ }
        // PCSA for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_19_level);
            d_19_get_bitmask.apply(ig_md.d_19_level, ig_md.d_19_bitmask);
            update_19.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_bitmask);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], 1, ig_md.d_21_est_1);
        d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16);
        update_21_2.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index2_16, ig_md.d_21_res_hash[2:2], 1, ig_md.d_21_est_2);
        d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16);
        update_21_3.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index3_16, ig_md.d_21_res_hash[3:3], 1, ig_md.d_21_est_3);
        d_21_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index4_16);
        update_21_4.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index4_16, ig_md.d_21_res_hash[4:4], 1, ig_md.d_21_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(21)
        // 

        T1_RUN_5_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_22_est1_1 == 0 || ig_md.d_22_est1_2 == 0 || ig_md.d_22_est1_3 == 0 || ig_md.d_22_est1_4 == 0 || ig_md.d_22_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_32, ig_md.d_23_level);
            update_23.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_level);
        //

        T2_RUN_AFTER_1_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T3_RUN_AFTER_1_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
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