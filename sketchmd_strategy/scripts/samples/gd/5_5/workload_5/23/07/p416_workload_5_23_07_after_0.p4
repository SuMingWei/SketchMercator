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

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 262144)
    T1_INIT_3( 2, 100, 524288)
    T2_INIT_2( 4, 100, 4096)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
    //

    MRAC_INIT_1( 6, 100, 32768, 11, 16)
    T1_INIT_2( 8, 100, 131072)
    T1_INIT_3( 7, 100, 524288)
    UM_INIT_2( 9, 100, 11, 32768)
    T1_INIT_5(10, 200, 262144)
    T3_INIT_HH_4(11, 200, 16384)
    UM_INIT_2(12, 200, 10, 16384)
    T1_INIT_1(13, 110, 524288)
    T1_INIT_1(14, 110, 262144)
    T5_INIT_1(15, 110, 8192)
    T1_INIT_2(16, 110, 262144)
    T1_INIT_2(17, 110, 131072)
    UM_INIT_2(18, 110, 11, 32768)
    T1_INIT_5(19, 220, 262144)
    T4_INIT_1(20, 220, 65536)
    T2_INIT_HH_3(21, 220, 4096)
    T2_INIT_HH_4(22, 220, 4096)
    T2_INIT_HH_2(23, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(SRCIP, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_32);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_2_KEY_1( 4, SRCIP, SIZE)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(SRCIP, 1, 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, 1, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, 1, 1, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, 1, 1, ig_md.d_3_est_4);
            d_5_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_3_est_4, ig_md.d_5_above_threshold);
        //

        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(SRCIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        T1_RUN_2_KEY_1( 8, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_1( 7, DSTIP) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 9
            d_9_res_hash_call.apply(DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(DSTIP, ig_md.d_9_index2_16); 
            UM_RUN_END_2(9, ig_md.d_9_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(9) 
        //

        T1_RUN_5_KEY_2(10, SRCIP, DSTIP) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0 || ig_md.d_10_est1_5 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_2(11, SRCIP, DSTIP, 1)
        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_12_index2_16); 
            UM_RUN_END_2(12, ig_md.d_12_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(12) 
        //

        T1_RUN_1_KEY_2(13, SRCIP, SRCPORT) if (ig_md.d_13_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2(14, SRCIP, SRCPORT) if (ig_md.d_14_est1_1 == 0) { /* process_new_flow() */ }
        // PCSA for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_32, ig_md.d_15_level);
            d_15_get_bitmask.apply(ig_md.d_15_level, ig_md.d_15_bitmask);
            update_15.apply(SRCIP, SRCPORT, ig_md.d_15_bitmask);
        //

        T1_RUN_2_KEY_2(16, DSTIP, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2(17, DSTIP, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 18
            d_18_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_18_index2_16); 
            UM_RUN_END_2(18, ig_md.d_18_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(18) 
        //

        T1_RUN_5_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_19_est1_1 == 0 || ig_md.d_19_est1_2 == 0 || ig_md.d_19_est1_3 == 0 || ig_md.d_19_est1_4 == 0 || ig_md.d_19_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_20_level);
            update_20.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_level);
        //

        T2_RUN_AFTER_3_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_4_KEY_4(22, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_AFTER_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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