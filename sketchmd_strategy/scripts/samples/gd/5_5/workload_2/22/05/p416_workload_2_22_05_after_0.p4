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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T1_INIT_1( 2, 200, 262144)
    T1_INIT_2( 1, 200, 524288)
    T3_INIT_HH_2( 7, 200, 8192)

    // apply O2
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
    // 

    T2_INIT_HH_3(15, 200, 8192)

    // apply O2
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_6_above_threshold;
    // 

    T3_INIT_HH_4( 8, 200, 16384)
    T2_INIT_HH_4( 9, 200, 8192)
    T2_INIT_HH_4(16, 200, 8192)

    // apply O2
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
    // 

    T2_INIT_HH_5(10, 200, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(17, 200)
        ABOVE_THRESHOLD_1() d_17_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_17_1;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(22, 200)
        ABOVE_THRESHOLD_5() d_22_above_threshold;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_22_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_22_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_22_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_22_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_22_index_hash_call_3;
        T3_T2_INDEX_UPDATE_32768() update_22_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_22_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_22_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_22_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_22_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_17_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_22_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 2, SRCIP, DSTIP)
        T1_RUN_2_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_2_KEY_2( 7, SRCIP, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_3_KEY_2(5, SRCIP, DSTIP, SIZE)
        // 

        T2_RUN_AFTER_3_KEY_2(15, SRCIP, DSTIP, SIZE)

        // apply O2
        T2_RUN_AFTER_4_KEY_2(6, SRCIP, DSTIP, SIZE)
        // 

        T3_RUN_AFTER_4_KEY_2( 8, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_4_KEY_2( 9, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_4_KEY_2(16, SRCIP, DSTIP, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(3, SRCIP, DSTIP, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(4, SRCIP, DSTIP, 1)
        // 

        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_17_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], 1, ig_md.d_17_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(17)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_22_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_22_res_hash);
        d_22_tcam_lpm_2.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16_1024, ig_md.d_22_base_16_2048, ig_md.d_22_threshold);
        d_22_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_22_index1_16);
        update_22_1.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index1_16, ig_md.d_22_res_hash[1:1], 1, ig_md.d_22_est_1);
        d_22_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_22_index2_16);
        update_22_2.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index2_16, ig_md.d_22_res_hash[2:2], 1, ig_md.d_22_est_2);
        d_22_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_22_index3_16);
        update_22_3.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index3_16, ig_md.d_22_res_hash[3:3], 1, ig_md.d_22_est_3);
        d_22_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_22_index4_16);
        update_22_4.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index4_16, ig_md.d_22_res_hash[4:4], 1, ig_md.d_22_est_4);
        d_22_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_22_index5_16);
        update_22_5.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index5_16, ig_md.d_22_res_hash[5:5], 1, ig_md.d_22_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(22)
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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