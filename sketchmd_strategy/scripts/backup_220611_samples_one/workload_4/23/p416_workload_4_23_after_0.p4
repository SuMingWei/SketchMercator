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
    T4_INIT_1( 1, 100, 65536)
    T2_INIT_4( 2, 100, 16384)
    MRAC_INIT_1( 3, 100, 8192, 10,  8)
    T1_INIT_4( 4, 100, 262144)
    T2_INIT_HH_3( 5, 100, 16384)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(7, 100)
        ABOVE_THRESHOLD_4() d_7_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_7_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_7_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_7_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_7_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_7_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_7_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_7_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_7_4;
    // 

    T1_INIT_2( 8, 200, 262144)
    T4_INIT_1( 9, 200, 65536)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_2;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_4;
    //
    T1_INIT_4(13, 110, 131072)
    T2_INIT_HH_3(14, 110, 8192)
    T4_INIT_1(15, 110, 65536)
    T1_INIT_3(16, 220, 524288)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_18_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_18_hash_call;
        TCAM_LPM_HLLPCSA() d_18_tcam_lpm;
        GET_BITMASK() d_18_get_bitmask;
        T2_T5_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_5;
    //
    T3_INIT_HH_5(20, 220, 16384)
    MRAC_INIT_1(21, 220, 32768, 11, 16)
    T2_INIT_HH_4(22, 221, 16384)
    UM_INIT_1(23, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T4_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_4_KEY_1( 2, SRCIP, SIZE)
        MRAC_RUN_1_KEY_1( 3, SRCIP)
        T1_RUN_4_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_1( 5, DSTIP, SIZE)

        // apply O3; big - UnivMon / small - many MRACs 
        d_7_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);
        d_7_res_hash_call.apply(DSTIP, ig_md.d_7_res_hash);
        d_7_tcam_lpm_2.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16_1024, ig_md.d_7_base_16_2048, ig_md.d_7_threshold);
        d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
        update_7_1.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index1_16, ig_md.d_7_res_hash[1:1], 1, ig_md.d_7_est_1);
        d_7_index_hash_call_2.apply(DSTIP, ig_md.d_7_index2_16);
        update_7_2.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index2_16, ig_md.d_7_res_hash[2:2], 1, ig_md.d_7_est_2);
        d_7_index_hash_call_3.apply(DSTIP, ig_md.d_7_index3_16);
        update_7_3.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index3_16, ig_md.d_7_res_hash[3:3], 1, ig_md.d_7_est_3);
        d_7_index_hash_call_4.apply(DSTIP, ig_md.d_7_index4_16);
        update_7_4.apply(ig_md.d_7_base_16_1024, ig_md.d_7_index4_16, ig_md.d_7_res_hash[4:4], 1, ig_md.d_7_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(7)
        // 

        T1_RUN_2_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0) { /* process_new_flow() */ }
        T4_RUN_1_KEY_2( 9, SRCIP, DSTIP)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_10_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_10_est_3);
            d_11_above_threshold.apply(ig_md.d_10_est_1, ig_md.d_10_est_2, ig_md.d_10_est_3, ig_md.d_11_above_threshold);
            update_10_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_est_4);
        //
        T1_RUN_4_KEY_2(13, SRCIP, SRCPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0 || ig_md.d_13_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_2(14, SRCIP, SRCPORT, SIZE)
        T4_RUN_1_KEY_2(15, DSTIP, DSTPORT)
        T1_RUN_3_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0) { /* process_new_flow() */ }

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_18_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_32);
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_18_level);
            d_18_get_bitmask.apply(ig_md.d_18_level, ig_md.d_18_bitmask);
            update_18_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_bitmask, ig_md.d_18_est_1);
            update_18_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_2);
            update_18_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_3);
            update_18_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_4);
            update_18_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(18)
        //
        T3_RUN_AFTER_5_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        MRAC_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_AFTER_4_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        UM_RUN_AFTER_1_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
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