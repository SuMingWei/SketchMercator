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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T4_INIT_1( 1, 100, 32768)
    T5_INIT_1( 2, 100, 16384)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(5, 100)
        ABOVE_THRESHOLD_2() d_5_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_5_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_5_2;
    // 

    T2_INIT_HH_2( 7, 100, 4096)
    T2_INIT_HH_3( 6, 100, 8192)
    UM_INIT_5( 8, 100, 11, 32768)
    T1_INIT_2( 9, 200, 131072)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_11_hash_call;
        TCAM_LPM_HLLPCSA() d_11_tcam_lpm;
        GET_BITMASK() d_11_get_bitmask;
        T2_T5_KEY_UPDATE_200_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_5;
    //
    MRAC_INIT_1(13, 200, 8192, 10,  8)
    T5_INIT_1(14, 110, 4096)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_16_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_15_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_15_3;
    //
    T1_INIT_5(17, 220, 131072)
    T2_INIT_HH_4(18, 220, 4096)
    T3_INIT_HH_4(19, 220, 8192)
    T2_INIT_HH_5(20, 220, 8192)
    MRAC_INIT_1(21, 220, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T4_RUN_1_KEY_1( 1, SRCIP)
        T5_RUN_1_KEY_1( 2, SRCIP)

        // apply O3; big - UnivMon / small - many MRACs 
        d_5_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);
        d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash);
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048, ig_md.d_5_threshold);
        d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
        update_5_1.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index1_16, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
        d_5_index_hash_call_2.apply(SRCIP, ig_md.d_5_index2_16);
        update_5_2.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index2_16, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(5)
        // 

        T2_RUN_AFTER_2_KEY_1( 7, DSTIP, 1)
        T2_RUN_AFTER_3_KEY_1( 6, DSTIP, 1)
        UM_RUN_AFTER_5_KEY_1( 8, DSTIP, 1)
        T1_RUN_2_KEY_2( 9, SRCIP, DSTIP) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0) { /* process_new_flow() */ }

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_11_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_32);
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_32, ig_md.d_11_level);
            d_11_get_bitmask.apply(ig_md.d_11_level, ig_md.d_11_bitmask);
            update_11_1.apply(SRCIP, DSTIP, 1, ig_md.d_11_bitmask, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(11)
        //
        MRAC_RUN_1_KEY_2(13, SRCIP, DSTIP)
        T5_RUN_1_KEY_2(14, SRCIP, SRCPORT)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_15_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_15_est_1);
            d_16_above_threshold.apply(ig_md.d_15_est_1, ig_md.d_16_above_threshold);
            update_15_2.apply(DSTIP, DSTPORT, 1, ig_md.d_15_est_2);
            update_15_3.apply(DSTIP, DSTPORT, 1, ig_md.d_15_est_3);
        //
        T1_RUN_5_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0 || ig_md.d_17_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T3_RUN_AFTER_4_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        MRAC_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT)
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport); 
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