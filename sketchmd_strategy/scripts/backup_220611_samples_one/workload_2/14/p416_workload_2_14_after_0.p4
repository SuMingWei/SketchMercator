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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T1_INIT_3( 2, 110, 262144)
    T1_INIT_4( 1, 110, 131072)
    T4_INIT_1( 3, 110, 32768)
    T3_INIT_HH_1( 7, 110, 4096)
    T2_INIT_HH_2( 5, 110, 8192)
    T2_INIT_HH_3( 6, 110, 4096)
    T2_INIT_HH_3( 9, 110, 8192)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_4_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
    // 


    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(14, 110)
        ABOVE_THRESHOLD_5() d_14_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_14_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_14_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_14_4;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_14_5;
    // 


    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(11, 110)
        ABOVE_THRESHOLD_1() d_11_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_11_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_3_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T4_RUN_1_KEY_2( 3, SRCIP, SRCPORT)
        T3_RUN_AFTER_1_KEY_2( 7, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_2_KEY_2( 5, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_3_KEY_2( 6, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_3_KEY_2( 9, SRCIP, SRCPORT, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(4, SRCIP, SRCPORT, 1)
        // 


        // apply O3; big - UnivMon / small - many MRACs 
        d_14_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_16);
        d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
        d_14_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_14_index2_16);
        update_14_2.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index2_16, ig_md.d_14_res_hash[2:2], SIZE, ig_md.d_14_est_2);
        d_14_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_14_index3_16);
        update_14_3.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index3_16, ig_md.d_14_res_hash[3:3], SIZE, ig_md.d_14_est_3);
        d_14_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_14_index4_16);
        update_14_4.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index4_16, ig_md.d_14_res_hash[4:4], SIZE, ig_md.d_14_est_4);
        d_14_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_14_index5_16);
        update_14_5.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index5_16, ig_md.d_14_res_hash[5:5], SIZE, ig_md.d_14_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(14)
        // 


        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_11_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);
        d_11_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_res_hash);
        d_11_tcam_lpm_2.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16_1024, ig_md.d_11_base_16_2048, ig_md.d_11_threshold);
        d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
        update_11_1.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index1_16, ig_md.d_11_res_hash[1:1], 1, ig_md.d_11_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(11)
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
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