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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T4_INIT_1( 1, 110, 65536)
    MRB_INIT_1( 2, 110, 262144, 14, 16)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_3_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
    // 

    T2_INIT_HH_2(10, 110, 16384)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
    // 

    T2_INIT_HH_3( 6, 110, 16384)
    T3_INIT_HH_5( 7, 110, 8192)
    T2_INIT_HH_5( 9, 110, 4096)
    T2_INIT_HH_5(12, 110, 16384)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(17, 110)
        ABOVE_THRESHOLD_4() d_17_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_17_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_17_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_17_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_17_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_17_4;
    // 


    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 110)
        ABOVE_THRESHOLD_4() d_18_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_18_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_18_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_18_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T4_RUN_1_KEY_2( 1, SRCIP, SRCPORT)
        MRB_RUN_1_KEY_2( 2, SRCIP, SRCPORT)

        // apply O2
        T2_RUN_AFTER_2_KEY_2(3, SRCIP, SRCPORT, 1)
        // 

        T2_RUN_AFTER_2_KEY_2(10, SRCIP, SRCPORT, 1)

        // apply O2
        T2_RUN_AFTER_3_KEY_2(5, SRCIP, SRCPORT, SIZE)
        // 

        T2_RUN_AFTER_3_KEY_2( 6, SRCIP, SRCPORT, SIZE)
        T3_RUN_AFTER_5_KEY_2( 7, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_5_KEY_2( 9, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_5_KEY_2(12, SRCIP, SRCPORT, SIZE)

        // apply O3; big - UnivMon / small - many MRACs 
        d_17_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_17_sampling_hash_16);
        d_17_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], 1, ig_md.d_17_est_1);
        d_17_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_17_index2_16);
        update_17_2.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index2_16, ig_md.d_17_res_hash[2:2], 1, ig_md.d_17_est_2);
        d_17_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_17_index3_16);
        update_17_3.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index3_16, ig_md.d_17_res_hash[3:3], 1, ig_md.d_17_est_3);
        d_17_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_17_index4_16);
        update_17_4.apply(ig_md.d_17_base_16_1024, ig_md.d_17_index4_16, ig_md.d_17_res_hash[4:4], 1, ig_md.d_17_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(17)
        // 


        // apply O3; big - UnivMon / small - many MRACs 
        d_18_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_sampling_hash_16);
        d_18_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
        d_18_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_18_index3_16);
        update_18_3.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index3_16, ig_md.d_18_res_hash[3:3], SIZE, ig_md.d_18_est_3);
        d_18_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_18_index4_16);
        update_18_4.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index4_16, ig_md.d_18_res_hash[4:4], SIZE, ig_md.d_18_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(18)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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