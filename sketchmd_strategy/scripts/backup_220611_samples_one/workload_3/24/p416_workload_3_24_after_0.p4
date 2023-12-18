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
    T1_INIT_1( 1, 100, 131072)
    UM_INIT_5( 2, 100, 10, 16384)
    T4_INIT_1( 3, 100, 16384)
    T2_INIT_4( 4, 100, 4096)
    MRAC_INIT_1( 5, 100, 16384, 10, 16)
    T1_INIT_5( 6, 200, 262144)
    T2_INIT_HH_2( 7, 200, 8192)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(9, 200)
        ABOVE_THRESHOLD_2() d_9_above_threshold;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_9_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_9_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_9_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_9_2;
    // 

    T2_INIT_HH_4(10, 110, 4096)
    MRAC_INIT_1(11, 110, 8192, 10,  8)
    T1_INIT_5(12, 110, 262144)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_2;
    //
    UM_INIT_2(15, 110, 10, 16384)
    MRB_INIT_1(16, 220, 262144, 15,  8)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_18_above_threshold;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_17_1;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_17_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_17_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_17_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_17_5;
    //

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(21, 220)
        ABOVE_THRESHOLD_3() d_21_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_21_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_21_2;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_21_3;
    // 


    // apply O2
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_22_1;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_22_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_22_above_threshold;
    // 

    T2_INIT_HH_3(24, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_1_KEY_1( 1, SRCIP)
        UM_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)
        T4_RUN_1_KEY_1( 3, DSTIP)
        T2_RUN_4_KEY_1( 4, DSTIP, 1)
        MRAC_RUN_1_KEY_1( 5, DSTIP)
        T1_RUN_5_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0 || ig_md.d_6_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2( 7, SRCIP, DSTIP, 1)

        // apply O3; big - UnivMon / small - many MRACs 
        d_9_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);
        d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048, ig_md.d_9_threshold);
        d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
        update_9_1.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index1_16, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
        d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16);
        update_9_2.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index2_16, ig_md.d_9_res_hash[2:2], 1, ig_md.d_9_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(9)
        // 

        T2_RUN_AFTER_4_KEY_2(10, SRCIP, SRCPORT, 1)
        MRAC_RUN_1_KEY_2(11, SRCIP, SRCPORT)
        T1_RUN_5_KEY_2(12, DSTIP, DSTPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0 || ig_md.d_12_est1_3 == 0 || ig_md.d_12_est1_4 == 0 || ig_md.d_12_est1_5 == 0) { /* process_new_flow() */ }

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_13_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_13_est_1);
            update_13_2.apply(DSTIP, DSTPORT, 1, ig_md.d_13_est_2);
        //
        UM_RUN_AFTER_2_KEY_2(15, DSTIP, DSTPORT, 1)
        MRB_RUN_1_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_17_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_17_est_1);
            update_17_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_17_est_2);
            d_18_above_threshold.apply(ig_md.d_17_est_1, ig_md.d_17_est_2, ig_md.d_18_above_threshold);
            update_17_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_17_est_3);
            update_17_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_17_est_4);
            update_17_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_17_est_5);
        //

        // apply O3; big - UnivMon / small - many MRACs 
        d_21_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);
        d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], 1, ig_md.d_21_est_1);
        d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16);
        update_21_2.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index2_16, ig_md.d_21_res_hash[2:2], 1, ig_md.d_21_est_2);
        d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16);
        update_21_3.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index3_16, ig_md.d_21_res_hash[3:3], 1, ig_md.d_21_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(21)
        // 


        // apply O2
        T2_RUN_AFTER_2_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 

        T2_RUN_AFTER_3_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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