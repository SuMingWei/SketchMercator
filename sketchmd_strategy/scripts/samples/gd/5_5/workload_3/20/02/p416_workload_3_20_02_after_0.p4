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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_2_above_threshold;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_4;
    //

    T5_INIT_1( 4, 100, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_sampling_hash_call;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_1;
        LPM_OPT_MRAC_2() d_5_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_5;
    // 

    T1_INIT_5( 7, 200, 262144)
    T4_INIT_1( 8, 200, 16384)
    T1_INIT_4( 9, 110, 524288)
    MRAC_INIT_1(10, 110, 32768, 11, 16)
    T1_INIT_2(11, 110, 262144)
    T5_INIT_1(12, 110, 8192)
    MRAC_INIT_1(13, 110, 16384, 10, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_15_above_threshold;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_1;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_2;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_4;
    //

    UM_INIT_4(16, 220, 11, 32768)
    MRB_INIT_1(17, 221, 524288, 15, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_1;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_2;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_3;
    //

    MRAC_INIT_1(20, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_32);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_1_res_hash_call.apply(SRCIP, ig_md.d_1_res_hash);
            update_1_1.apply(SRCIP, 1, ig_md.d_1_res_hash[1:1], 1, ig_md.d_1_est_1);
            d_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_2_above_threshold);
            update_1_2.apply(SRCIP, 1, 1, ig_md.d_1_est_2);
            update_1_3.apply(SRCIP, 1, 1, ig_md.d_1_est_3);
            update_1_4.apply(SRCIP, 1, 1, ig_md.d_1_est_4);
            d_3_above_threshold.apply(ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_est_4, ig_md.d_3_above_threshold);
        //

        // PCSA for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            d_4_get_bitmask.apply(ig_md.d_4_level, ig_md.d_4_bitmask);
            update_4.apply(DSTIP, ig_md.d_4_bitmask);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048);
        d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
        update_5.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index1_16);
        // 

        T1_RUN_5_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0 || ig_md.d_7_est1_4 == 0 || ig_md.d_7_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            update_8.apply(SRCIP, DSTIP, ig_md.d_8_level);
        //

        T1_RUN_4_KEY_2( 9, SRCIP, SRCPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0 || ig_md.d_9_est1_4 == 0) { /* process_new_flow() */ }
        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T1_RUN_2_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0) { /* process_new_flow() */ }
        // PCSA for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            d_12_get_bitmask.apply(ig_md.d_12_level, ig_md.d_12_bitmask);
            update_12.apply(DSTIP, DSTPORT, ig_md.d_12_bitmask);
        //

        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_14_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_res_hash);
            update_14_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
            update_14_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_res_hash[3:3], 1, ig_md.d_14_est_3);
            d_15_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_14_est_2, ig_md.d_14_est_3, ig_md.d_15_above_threshold);
            update_14_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_est_4);
        //

        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index3_16); 
            d_16_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index4_16); 
            UM_RUN_END_4(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(16) 
        //

        // MRB for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_32);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_32, ig_md.d_17_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_19_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_19_est_1);
            update_19_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_19_est_2);
            update_19_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_19_est_3);
        //

        // MRAC for inst 20
            d_20_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_20_base_16);
            d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_index1_16);
            update_20.apply(ig_md.d_20_base_16, ig_md.d_20_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
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