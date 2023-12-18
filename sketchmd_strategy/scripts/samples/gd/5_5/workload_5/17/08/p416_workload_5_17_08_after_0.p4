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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    UM_INIT_1( 2, 100, 11, 32768)
    T2_INIT_HH_4( 3, 100, 8192)
    T3_INIT_HH_5( 4, 100, 16384)
    UM_INIT_3( 5, 100, 11, 32768)
    T1_INIT_1( 6, 200, 131072)
    UM_INIT_4( 7, 200, 10, 16384)
    T3_INIT_HH_2( 8, 110, 8192)
    T1_INIT_4( 9, 110, 524288)
    T3_INIT_HH_4(10, 110, 4096)
    T1_INIT_1(12, 220, 524288)
    T1_INIT_2(11, 220, 131072)
    T4_INIT_1(13, 220, 16384)
    T3_INIT_HH_2(14, 220, 8192)
    UM_INIT_3(15, 220, 10, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(17, 221)
        ABOVE_THRESHOLD_5() d_17_above_threshold;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_17_1;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_17_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_17_2;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_17_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_17_3;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_17_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_17_4;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_17_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_17_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_32);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            UM_RUN_END_1(2, ig_md.d_2_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(2) 
        //

        T2_RUN_AFTER_4_KEY_1( 3, DSTIP, SIZE)
        T3_RUN_AFTER_5_KEY_1( 4, DSTIP, 1)
        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, ig_md.d_5_index2_16); 
            d_5_index_hash_call_3.apply(DSTIP, ig_md.d_5_index3_16); 
            UM_RUN_END_3(5, ig_md.d_5_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(5) 
        //

        T1_RUN_1_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_7_index4_16); 
            UM_RUN_END_4(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(7) 
        //

        T3_RUN_AFTER_2_KEY_2( 8, SRCIP, SRCPORT, 1)
        T1_RUN_4_KEY_2( 9, DSTIP, DSTPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0 || ig_md.d_9_est1_4 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_2(10, DSTIP, DSTPORT, 1)
        T1_RUN_1_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_12_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_4(11, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0) { /* process_new_flow() */ }
        // HLL for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_32, ig_md.d_13_level);
            update_13.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_level);
        //

        T3_RUN_AFTER_2_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // UnivMon for inst 15
            d_15_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index3_16); 
            UM_RUN_END_3(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(15) 
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_17_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], SIZE, ig_md.d_17_est_1);
        d_17_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index2_16);
        update_17_2.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index2_16, ig_md.d_17_res_hash[2:2], SIZE, ig_md.d_17_est_2);
        d_17_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index3_16);
        update_17_3.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index3_16, ig_md.d_17_res_hash[3:3], SIZE, ig_md.d_17_est_3);
        d_17_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index4_16);
        update_17_4.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index4_16, ig_md.d_17_res_hash[4:4], SIZE, ig_md.d_17_est_4);
        d_17_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index5_16);
        update_17_5.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index5_16, ig_md.d_17_res_hash[5:5], SIZE, ig_md.d_17_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(17)
        // 

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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