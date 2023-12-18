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
    T3_INIT_HH_2( 1, 100, 8192)
    MRAC_INIT_1( 2, 100, 8192, 10,  8)
    T2_INIT_HH_5( 3, 100, 8192)
    T1_INIT_3( 4, 200, 262144)
    T2_INIT_HH_1( 5, 200, 8192)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(7, 200)
        ABOVE_THRESHOLD_4() d_7_above_threshold;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_7_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_7_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_7_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_7_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_7_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_7_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_7_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_7_4;
    // 

    T1_INIT_2( 8, 110, 262144)
    MRB_INIT_1( 9, 110, 262144, 15,  8)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
    // 

    T3_INIT_HH_5(12, 110, 16384)
    MRAC_INIT_1(13, 110, 16384, 10, 16)
    T1_INIT_1(14, 110, 524288)
    T2_INIT_3(15, 110, 4096)
    MRAC_INIT_1(16, 110, 8192, 10,  8)
    T1_INIT_3(17, 220, 131072)
    MRB_INIT_1(18, 220, 524288, 15, 16)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_20_above_threshold;
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_res_hash_call;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_1;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_2;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_3;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_4;
        T3_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_5;
    //
    MRAC_INIT_1(21, 220, 8192, 10,  8)
    T2_INIT_HH_5(22, 221, 8192)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(24, 221)
        ABOVE_THRESHOLD_3() d_24_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_24_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_24_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_24_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_24_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_24_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_24_3;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T3_RUN_AFTER_2_KEY_1( 1, SRCIP, 1)
        MRAC_RUN_1_KEY_1( 2, SRCIP)
        T2_RUN_AFTER_5_KEY_1( 3, DSTIP, SIZE)
        T1_RUN_3_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2( 5, SRCIP, DSTIP, SIZE)

        // apply O3; big - UnivMon / small - many MRACs 
        d_7_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);
        d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash);
        d_7_tcam_lpm_2.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16_1024, ig_md.d_7_base_16_2048, ig_md.d_7_threshold);
        d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16);
        update_7_1.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index1_16, ig_md.d_7_res_hash[1:1], 1, ig_md.d_7_est_1);
        d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16);
        update_7_2.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index2_16, ig_md.d_7_res_hash[2:2], 1, ig_md.d_7_est_2);
        d_7_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_7_index3_16);
        update_7_3.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index3_16, ig_md.d_7_res_hash[3:3], 1, ig_md.d_7_est_3);
        d_7_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_7_index4_16);
        update_7_4.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index4_16, ig_md.d_7_res_hash[4:4], 1, ig_md.d_7_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(7)
        // 

        T1_RUN_2_KEY_2( 8, SRCIP, SRCPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_2( 9, SRCIP, SRCPORT)

        // apply O2
        T2_RUN_AFTER_3_KEY_2(10, SRCIP, SRCPORT, SIZE)
        // 

        T3_RUN_AFTER_5_KEY_2(12, SRCIP, SRCPORT, 1)
        MRAC_RUN_1_KEY_2(13, SRCIP, SRCPORT)
        T1_RUN_1_KEY_2(14, DSTIP, DSTPORT)
        T2_RUN_3_KEY_2(15, DSTIP, DSTPORT, SIZE)
        MRAC_RUN_1_KEY_2(16, DSTIP, DSTPORT)
        T1_RUN_3_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_res_hash);
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
            update_20_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_res_hash[3:3], 1, ig_md.d_20_est_3);
            update_20_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_res_hash[4:4], 1, ig_md.d_20_est_4);
            update_20_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_res_hash[5:5], ig_md.d_20_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(20)
        //
        MRAC_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_AFTER_5_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply O3; big - UnivMon / small - many MRACs 
        d_24_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_sampling_hash_16);
        d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_res_hash);
        d_24_tcam_lpm_2.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16_1024, ig_md.d_24_base_16_2048, ig_md.d_24_threshold);
        d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16);
        update_24_1.apply(ig_md.d_24_base_16_2048, ig_md.d_24_index1_16, ig_md.d_24_res_hash[1:1], SIZE, ig_md.d_24_est_1);
        d_24_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index2_16);
        update_24_2.apply(ig_md.d_24_base_16_2048, ig_md.d_24_index2_16, ig_md.d_24_res_hash[2:2], SIZE, ig_md.d_24_est_2);
        d_24_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index3_16);
        update_24_3.apply(ig_md.d_24_base_16_2048, ig_md.d_24_index3_16, ig_md.d_24_res_hash[3:3], SIZE, ig_md.d_24_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(24)
        // 

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
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
        ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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