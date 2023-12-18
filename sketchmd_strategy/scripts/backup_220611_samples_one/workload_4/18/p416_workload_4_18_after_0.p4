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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_1_above_threshold;
    // 

    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T1_INIT_5( 4, 100, 524288)
    MRB_INIT_1( 5, 100, 262144, 15,  8)
    MRAC_INIT_1( 6, 100, 32768, 11, 16)
    T3_INIT_HH_5( 7, 200, 4096)
    T1_INIT_2( 8, 110, 131072)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 110)
        ABOVE_THRESHOLD_4() d_10_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_10_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_10_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_10_4;
    // 

    T4_INIT_1(11, 110, 65536)
    T2_INIT_4(12, 110, 4096)
    T1_INIT_1(13, 220, 262144)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_16_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_3;
    //
    T3_INIT_HH_2(15, 220, 4096)
    MRAC_INIT_1(17, 220, 8192, 10,  8)
    T2_INIT_HH_5(18, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {

        // apply O2
        T2_RUN_AFTER_4_KEY_1(1, SRCIP, SIZE)
        // 

        MRAC_RUN_1_KEY_1( 3, SRCIP)
        T1_RUN_5_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_1( 5, DSTIP)
        MRAC_RUN_1_KEY_1( 6, DSTIP)
        T3_RUN_AFTER_5_KEY_2( 7, SRCIP, DSTIP, SIZE)
        T1_RUN_2_KEY_2( 8, SRCIP, SRCPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0) { /* process_new_flow() */ }

        // apply O3; big - UnivMon / small - many MRACs 
        d_10_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_16);
        d_10_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], SIZE, ig_md.d_10_est_3);
        d_10_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_10_index4_16);
        update_10_4.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index4_16, ig_md.d_10_res_hash[4:4], SIZE, ig_md.d_10_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(10)
        // 

        T4_RUN_1_KEY_2(11, DSTIP, DSTPORT)
        T2_RUN_4_KEY_2(12, DSTIP, DSTPORT, 1)
        T1_RUN_1_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_16_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_16_est_1);
            update_16_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_16_est_2);
            update_16_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_16_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(16)
        //
        T3_RUN_AFTER_2_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        MRAC_RUN_1_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_AFTER_5_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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