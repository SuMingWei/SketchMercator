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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T2_INIT_HH_3( 1, 100, 8192)
    T3_INIT_HH_4( 2, 100, 4096)
    T2_INIT_HH_2( 3, 100, 8192)
    T2_INIT_HH_2( 5, 100, 16384)
    T3_INIT_HH_3( 4, 100, 16384)
    UM_INIT_1( 6, 100, 11, 32768)
    T1_INIT_1( 7, 200, 131072)
    T2_INIT_2( 8, 200, 4096)
    T1_INIT_1( 9, 110, 262144)
    T4_INIT_1(10, 110, 32768)
    T2_INIT_HH_4(11, 110, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_5() d_13_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_13_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_13_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_13_4;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_13_5;
    // 

    T1_INIT_3(14, 110, 131072)
    T2_INIT_HH_2(15, 110, 8192)
    MRB_INIT_1(16, 220, 262144, 14, 16)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 220)
        ABOVE_THRESHOLD_2() d_18_above_threshold;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_18_1;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_18_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_18_2;
    // 

    UM_INIT_2(19, 220, 10, 16384)
    T2_INIT_HH_4(20, 221, 8192)
    UM_INIT_3(21, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        T2_RUN_AFTER_3_KEY_1( 1, SRCIP, 1)
        T3_RUN_AFTER_4_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_2_KEY_1( 3, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_1( 5, DSTIP, 1)
        T3_RUN_AFTER_3_KEY_1( 4, DSTIP, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            UM_RUN_END_1(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(6) 
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP)
        T2_RUN_2_KEY_2( 8, SRCIP, DSTIP, 1)
        T1_RUN_1_KEY_2( 9, SRCIP, SRCPORT) if (ig_md.d_9_est1_1 == 0) { /* process_new_flow() */ }
        // HLL for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
            update_10.apply(SRCIP, SRCPORT, ig_md.d_10_level);
        //

        T2_RUN_AFTER_4_KEY_2(11, SRCIP, SRCPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        d_13_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_13_index3_16);
        update_13_3.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index3_16, ig_md.d_13_res_hash[3:3], 1, ig_md.d_13_est_3);
        d_13_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_13_index4_16);
        update_13_4.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index4_16, ig_md.d_13_res_hash[4:4], 1, ig_md.d_13_est_4);
        d_13_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_13_index5_16);
        update_13_5.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index5_16, ig_md.d_13_res_hash[5:5], 1, ig_md.d_13_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(13)
        // 

        T1_RUN_3_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(15, DSTIP, DSTPORT, 1)
        // MRB for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_32);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_32, ig_md.d_16_index1_16);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], 1, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], 1, ig_md.d_18_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(18)
        // 

        // UnivMon for inst 19
            d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index2_16); 
            UM_RUN_END_2(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(19) 
        //

        T2_RUN_AFTER_4_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index3_16); 
            UM_RUN_END_3(21, ig_md.d_21_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(21) 
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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