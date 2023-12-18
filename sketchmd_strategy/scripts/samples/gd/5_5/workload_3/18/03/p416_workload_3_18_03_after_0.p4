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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 524288)
    T4_INIT_1( 2, 100, 32768)
    T2_INIT_4( 3, 100, 8192)
    UM_INIT_3( 4, 100, 11, 32768)
    T3_INIT_HH_3( 5, 200, 4096)
    UM_INIT_2( 6, 200, 10, 16384)
    T1_INIT_3( 7, 110, 524288)
    T4_INIT_1( 8, 110, 32768)
    T2_INIT_HH_4(10, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_3;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_4;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_5;
    //

    MRAC_INIT_1(12, 110, 32768, 11, 16)
    T2_INIT_HH_4(15, 110, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_14_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_3;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_4;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_5;
    //

    T4_INIT_1(16, 221, 32768)
    T2_INIT_3(17, 221, 16384)
    MRAC_INIT_1(18, 221, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2.apply(SRCIP, ig_md.d_2_level);
        //

        T2_RUN_4_KEY_1( 3, SRCIP, 1)
        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(DSTIP, ig_md.d_4_index3_16); 
            UM_RUN_END_3(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(4) 
        //

        T3_RUN_AFTER_3_KEY_2( 5, SRCIP, DSTIP, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //

        T1_RUN_3_KEY_2( 7, SRCIP, SRCPORT) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0) { /* process_new_flow() */ }
        // HLL for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            update_8.apply(SRCIP, SRCPORT, ig_md.d_8_level);
        //

        T2_RUN_AFTER_4_KEY_2(10, SRCIP, SRCPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_9_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_5);
            d_11_above_threshold.apply(ig_md.d_9_est_1, ig_md.d_9_est_2, ig_md.d_9_est_3, ig_md.d_9_est_4, ig_md.d_9_est_5, ig_md.d_11_above_threshold);
        //

        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //

        T2_RUN_AFTER_4_KEY_2(15, DSTIP, DSTPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
            update_13_1.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
            update_13_2.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
            update_13_3.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[3:3], 1, ig_md.d_13_est_3);
            update_13_4.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[4:4], 1, ig_md.d_13_est_4);
            update_13_5.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[5:5], 1, ig_md.d_13_est_5);
            d_14_above_threshold.apply(ig_md.d_13_est_1, ig_md.d_13_est_2, ig_md.d_13_est_3, ig_md.d_13_est_4, ig_md.d_13_est_5, ig_md.d_14_above_threshold);
        //

        // HLL for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_16_level);
            update_16.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_level);
        //

        T2_RUN_3_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16);
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index1_16);
            update_18.apply(ig_md.d_18_base_16, ig_md.d_18_index1_16);
        //

        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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