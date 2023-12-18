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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 28672)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_25_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 131072)
    T1_INIT_2( 2, 100, 131072)
    T2_INIT_HH_1( 3, 100, 16384)
    T2_INIT_HH_3( 4, 100, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(6, 100)
        ABOVE_THRESHOLD_2() d_6_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_6_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_6_2;
    // 

    T2_INIT_3( 7, 100, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(9, 100)
        ABOVE_THRESHOLD_5() d_9_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_9_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_9_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_9_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_9_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_9_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_9_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_9_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_9_4;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_9_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_9_5;
    // 

    T1_INIT_1(11, 200, 524288)
    T1_INIT_3(10, 200, 262144)
    T2_INIT_2(12, 200, 16384)
    UM_INIT_4(13, 200, 10, 16384)
    T1_INIT_3(14, 110, 131072)
    T2_INIT_HH_3(15, 110, 16384)
    UM_INIT_1(16, 110, 10, 16384)
    T1_INIT_4(17, 220, 524288)
    T2_INIT_HH_2(20, 220, 8192)
    T2_INIT_HH_4(18, 220, 16384)
    T2_INIT_HH_5(19, 220, 8192)
    UM_INIT_4(21, 220, 10, 16384)
    T2_INIT_HH_1(24, 221, 16384)

    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_4;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_22_above_threshold;
    // 

    UM_INIT_3(25, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(SRCIP, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_13_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_25_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_1( 3, SRCIP, 1)
        T2_RUN_AFTER_3_KEY_1( 4, SRCIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_6_res_hash_call.apply(SRCIP, ig_md.d_6_res_hash);
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048, ig_md.d_6_threshold);
        d_6_index_hash_call_1.apply(SRCIP, ig_md.d_6_index1_16);
        update_6_1.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index1_16, ig_md.d_6_res_hash[1:1], SIZE, ig_md.d_6_est_1);
        d_6_index_hash_call_2.apply(SRCIP, ig_md.d_6_index2_16);
        update_6_2.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index2_16, ig_md.d_6_res_hash[2:2], SIZE, ig_md.d_6_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(6)
        // 

        T2_RUN_3_KEY_1( 7, DSTIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_9_res_hash_call.apply(DSTIP, ig_md.d_9_res_hash);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048, ig_md.d_9_threshold);
        d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16);
        update_9_1.apply(ig_md.d_9_base_16_2048, ig_md.d_9_index1_16, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
        d_9_index_hash_call_2.apply(DSTIP, ig_md.d_9_index2_16);
        update_9_2.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index2_16, ig_md.d_9_res_hash[2:2], 1, ig_md.d_9_est_2);
        d_9_index_hash_call_3.apply(DSTIP, ig_md.d_9_index3_16);
        update_9_3.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index3_16, ig_md.d_9_res_hash[3:3], 1, ig_md.d_9_est_3);
        d_9_index_hash_call_4.apply(DSTIP, ig_md.d_9_index4_16);
        update_9_4.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index4_16, ig_md.d_9_res_hash[4:4], 1, ig_md.d_9_est_4);
        d_9_index_hash_call_5.apply(DSTIP, ig_md.d_9_index5_16);
        update_9_5.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index5_16, ig_md.d_9_res_hash[5:5], 1, ig_md.d_9_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(9)
        // 

        T1_RUN_1_KEY_2(11, SRCIP, DSTIP)
        T1_RUN_3_KEY_2(10, SRCIP, DSTIP) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_2_KEY_2(12, SRCIP, DSTIP, SIZE)
        // UnivMon for inst 13
            d_13_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_13_index3_16); 
            d_13_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_13_index4_16); 
            UM_RUN_END_4(13, ig_md.d_13_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(13) 
        //

        T1_RUN_3_KEY_2(14, SRCIP, SRCPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_2(15, DSTIP, DSTPORT, SIZE)
        // UnivMon for inst 16
            d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16); 
            UM_RUN_END_1(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(16) 
        //

        T1_RUN_4_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_AFTER_4_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16); 
            d_21_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index4_16); 
            UM_RUN_END_4(21, ig_md.d_21_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(21) 
        //

        T2_RUN_AFTER_1_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 

        // UnivMon for inst 25
            d_25_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_res_hash); 
            d_25_tcam_lpm.apply(ig_md.d_25_sampling_hash_16, ig_md.d_25_base_16, ig_md.d_25_threshold); 
            d_25_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index1_16); 
            d_25_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index2_16); 
            d_25_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index3_16); 
            UM_RUN_END_3(25, ig_md.d_25_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(25) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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