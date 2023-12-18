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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T1_INIT_1( 1, 110, 524288)
    T1_INIT_2( 2, 110, 131072)

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_3_1;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_3_2;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_3_3;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_3_4;
    // 

    T4_INIT_1( 4, 110, 16384)
    T3_INIT_HH_1(10, 110, 16384)
    T2_INIT_HH_2(14, 110, 8192)
    T2_INIT_HH_2(16, 110, 16384)
    T2_INIT_HH_2(18, 110, 16384)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_5;
    //

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
    // 

    T3_INIT_HH_4(12, 110, 16384)
    T2_INIT_HH_4(17, 110, 8192)
    T3_INIT_HH_5(11, 110, 16384)
    T2_INIT_HH_5(13, 110, 8192)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(20, 110)
        ABOVE_THRESHOLD_1() d_20_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_20_1;
    // 


    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(25, 110)
        ABOVE_THRESHOLD_5() d_25_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_25_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_25_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_25_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_25_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_25_index_hash_call_3;
        T3_T2_INDEX_UPDATE_32768() update_25_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_25_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_25_4;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_25_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_25_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_1_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_4_KEY_2(3, SRCIP, SRCPORT) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        // 

        T4_RUN_1_KEY_2( 4, SRCIP, SRCPORT)
        T3_RUN_AFTER_1_KEY_2(10, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_2_KEY_2(14, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_2_KEY_2(16, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_2_KEY_2(18, SRCIP, SRCPORT, SIZE)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_6_1.apply(SRCIP, SRCPORT, 1, SIZE, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, SRCPORT, 1, SIZE, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, SRCPORT, 1, SIZE, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, SRCPORT, 1, ig_md.d_6_est_4);
            update_6_5.apply(SRCIP, SRCPORT, 1, ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //

        // apply O2
        T2_RUN_AFTER_3_KEY_2(8, SRCIP, SRCPORT, SIZE)
        // 

        T3_RUN_AFTER_4_KEY_2(12, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_4_KEY_2(17, SRCIP, SRCPORT, SIZE)
        T3_RUN_AFTER_5_KEY_2(11, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_5_KEY_2(13, SRCIP, SRCPORT, 1)

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_20_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_20_sampling_hash_16);
        d_20_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_1024, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(20)
        // 


        // apply O3; big - UnivMon / small - many MRACs 
        d_25_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_25_sampling_hash_16);
        d_25_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_25_res_hash);
        d_25_tcam_lpm_2.apply(ig_md.d_25_sampling_hash_16, ig_md.d_25_base_16_1024, ig_md.d_25_base_16_2048, ig_md.d_25_threshold);
        d_25_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_25_index1_16);
        update_25_1.apply(ig_md.d_25_base_16_2048, ig_md.d_25_index1_16, ig_md.d_25_res_hash[1:1], 1, ig_md.d_25_est_1);
        d_25_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_25_index2_16);
        update_25_2.apply(ig_md.d_25_base_16_2048, ig_md.d_25_index2_16, ig_md.d_25_res_hash[2:2], 1, ig_md.d_25_est_2);
        d_25_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_25_index3_16);
        update_25_3.apply(ig_md.d_25_base_16_2048, ig_md.d_25_index3_16, ig_md.d_25_res_hash[3:3], 1, ig_md.d_25_est_3);
        d_25_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_25_index4_16);
        update_25_4.apply(ig_md.d_25_base_16_2048, ig_md.d_25_index4_16, ig_md.d_25_res_hash[4:4], 1, ig_md.d_25_est_4);
        d_25_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_25_index5_16);
        update_25_5.apply(ig_md.d_25_base_16_2048, ig_md.d_25_index5_16, ig_md.d_25_res_hash[5:5], 1, ig_md.d_25_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(25)
        // 

        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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