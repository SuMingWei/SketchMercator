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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    T2_INIT_HH_5( 2, 100, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(5, 100)
        ABOVE_THRESHOLD_5() d_5_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_5_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_5_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_5_3;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_5_4;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_5_5;
    // 

    MRB_INIT_1( 6, 100, 262144, 14, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_8_hash_call;
        TCAM_LPM_HLLPCSA() d_8_tcam_lpm;
        GET_BITMASK() d_8_get_bitmask;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_res_hash_call;
        T3_T5_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_1;
        T3_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_2;
        T3_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_3;
        T3_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_4;
    //

    T3_INIT_HH_2( 9, 100, 16384)
    T2_INIT_HH_4(10, 100, 16384)
    T2_INIT_HH_5(11, 100, 4096)
    T4_INIT_1(12, 200, 16384)
    T2_INIT_1(13, 200, 8192)
    T1_INIT_2(14, 110, 524288)
    MRAC_INIT_1(15, 110, 16384, 10, 16)
    T4_INIT_1(16, 110, 32768)
    T2_INIT_HH_1(17, 110, 4096)
    MRAC_INIT_1(18, 110, 32768, 11, 16)
    T5_INIT_1(19, 220, 16384)
    T4_INIT_1(20, 221, 16384)
    MRB_INIT_1(21, 221, 262144, 14, 16)
    T2_INIT_HH_1(23, 221, 16384)
    T3_INIT_HH_4(22, 221, 16384)
    MRAC_INIT_1(24, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_32);

            d_15_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_32);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_sampling_hash_32);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash);
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048, ig_md.d_5_threshold);
        d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
        update_5_1.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index1_16, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
        d_5_index_hash_call_2.apply(SRCIP, ig_md.d_5_index2_16);
        update_5_2.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index2_16, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
        d_5_index_hash_call_3.apply(SRCIP, ig_md.d_5_index3_16);
        update_5_3.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index3_16, ig_md.d_5_res_hash[3:3], 1, ig_md.d_5_est_3);
        d_5_index_hash_call_4.apply(SRCIP, ig_md.d_5_index4_16);
        update_5_4.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index4_16, ig_md.d_5_res_hash[4:4], 1, ig_md.d_5_est_4);
        d_5_index_hash_call_5.apply(SRCIP, ig_md.d_5_index5_16);
        update_5_5.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index5_16, ig_md.d_5_res_hash[5:5], 1, ig_md.d_5_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(5)
        // 

        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_8_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash);
            update_8_1.apply(DSTIP, 1, ig_md.d_8_res_hash[1:1], ig_md.d_8_bitmask, ig_md.d_8_est_1);
            update_8_2.apply(DSTIP, 1, ig_md.d_8_res_hash[2:2], ig_md.d_8_est_2);
            update_8_3.apply(DSTIP, 1, ig_md.d_8_res_hash[3:3], ig_md.d_8_est_3);
            update_8_4.apply(DSTIP, 1, ig_md.d_8_res_hash[4:4], ig_md.d_8_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(8)
        //

        T3_RUN_AFTER_2_KEY_1( 9, DSTIP, 1)
        T2_RUN_AFTER_4_KEY_1(10, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_1(11, DSTIP, 1)
        // HLL for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            update_12.apply(SRCIP, DSTIP, ig_md.d_12_level);
        //

        T2_RUN_1_KEY_2(13, SRCIP, DSTIP, 1)
        T1_RUN_2_KEY_2(14, SRCIP, SRCPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0) { /* process_new_flow() */ }
        // MRAC for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16);
            d_15_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_16, ig_md.d_15_index1_16);
        //

        // HLL for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_16_level);
            update_16.apply(DSTIP, DSTPORT, ig_md.d_16_level);
        //

        T2_RUN_AFTER_1_KEY_2(17, DSTIP, DSTPORT, 1)
        // MRAC for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16);
            d_18_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_18_index1_16);
            update_18.apply(ig_md.d_18_base_16, ig_md.d_18_index1_16);
        //

        // PCSA for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_19_level);
            d_19_get_bitmask.apply(ig_md.d_19_level, ig_md.d_19_bitmask);
            update_19.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_bitmask);
        //

        // HLL for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_20_level);
            update_20.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_level);
        //

        // MRB for inst 21
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_32);
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
            update_21.apply(ig_md.d_21_base_32, ig_md.d_21_index1_16);
        //

        T2_RUN_AFTER_1_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T3_RUN_AFTER_4_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 24
            d_24_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_24_base_16);
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16);
            update_24.apply(ig_md.d_24_base_16, ig_md.d_24_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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