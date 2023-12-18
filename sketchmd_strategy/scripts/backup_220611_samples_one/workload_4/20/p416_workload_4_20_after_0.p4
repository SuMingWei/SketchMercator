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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // apply O2
        T1_KEY_UPDATE_100_262144(32w0x30243f0b) update_1_1;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_2;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_3;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_4;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_5;
    // 


    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
    // 

    T3_INIT_HH_2( 4, 100, 4096)
    T3_INIT_HH_4( 5, 100, 16384)
    T2_INIT_5( 7, 100, 4096)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(8, 100)
        ABOVE_THRESHOLD_1() d_8_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_8_1;
    // 

    T2_INIT_4(10, 110, 8192)
    T5_INIT_1(11, 110, 4096)
    MRAC_INIT_1(12, 110, 8192, 10,  8)
    T1_INIT_3(13, 220, 262144)
    T2_INIT_HH_4(14, 220, 4096)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(15, 220)
        ABOVE_THRESHOLD_1() d_15_above_threshold;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_15_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_15_1;
    // 

    UM_INIT_4(16, 220, 11, 32768)
    T1_INIT_4(18, 221, 524288)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(19, 221)
        ABOVE_THRESHOLD_1() d_19_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_19_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_19_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {

        // apply O2
        T1_RUN_5_KEY_1(1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // 


        // apply O2
        T2_RUN_AFTER_2_KEY_1(3, SRCIP, SIZE)
        // 

        T3_RUN_AFTER_2_KEY_1( 4, SRCIP, 1)
        T3_RUN_AFTER_4_KEY_1( 5, SRCIP, SIZE)
        T2_RUN_5_KEY_1( 7, DSTIP, SIZE)

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_8_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);
        d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(8)
        // 

        T2_RUN_4_KEY_2(10, SRCIP, SRCPORT, 1)
        T5_RUN_1_KEY_2(11, DSTIP, DSTPORT)
        MRAC_RUN_1_KEY_2(12, DSTIP, DSTPORT)
        T1_RUN_3_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_15_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_sampling_hash_16);
        d_15_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_res_hash);
        d_15_tcam_lpm_2.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16_1024, ig_md.d_15_base_16_2048, ig_md.d_15_threshold);
        d_15_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index1_16);
        update_15_1.apply(ig_md.d_15_base_16_1024, ig_md.d_15_index1_16, ig_md.d_15_res_hash[1:1], SIZE, ig_md.d_15_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(15)
        // 

        UM_RUN_AFTER_4_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_4_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0 || ig_md.d_18_est1_4 == 0) { /* process_new_flow() */ }

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_19_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_16);
        d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_res_hash);
        d_19_tcam_lpm_2.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16_1024, ig_md.d_19_base_16_2048, ig_md.d_19_threshold);
        d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index1_16);
        update_19_1.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index1_16, ig_md.d_19_res_hash[1:1], SIZE, ig_md.d_19_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(19)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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