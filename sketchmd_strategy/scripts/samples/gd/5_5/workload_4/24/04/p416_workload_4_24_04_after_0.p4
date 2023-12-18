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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_2_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_hash_call;
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        GET_BITMASK() d_2_get_bitmask;
        T2_T5_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_4;
    //

    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T1_INIT_1( 4, 100, 524288)
    T2_INIT_HH_2( 5, 100, 4096)
    T2_INIT_HH_5( 6, 100, 4096)
    MRAC_INIT_1( 7, 100, 16384, 11,  8)
    T2_INIT_HH_2( 8, 200, 4096)
    UM_INIT_2( 9, 200, 10, 16384)

    // apply O2
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_1;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_2;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_3;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_4;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_10_5;
    // 

    T2_INIT_HH_3(12, 110, 8192)
    MRAC_INIT_1(13, 110, 16384, 10, 16)
    T4_INIT_1(14, 110, 32768)

    // apply O2
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_15_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_15_above_threshold;
    // 

    MRAC_INIT_1(17, 110, 16384, 10, 16)
    T2_INIT_HH_3(18, 220, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(19, 220)
        ABOVE_THRESHOLD_1() d_19_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_19_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_19_1;
    // 

    T1_INIT_3(21, 221, 524288)
    MRB_INIT_1(22, 221, 262144, 15,  8)
    T3_INIT_HH_5(23, 221, 16384)
    MRAC_INIT_1(24, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_32);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_16);

        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_2_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_2_level);
            d_2_get_bitmask.apply(ig_md.d_2_level, ig_md.d_2_bitmask);
            update_2_1.apply(SRCIP, 1, ig_md.d_2_bitmask, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, ig_md.d_2_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(2)
        //

        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        T1_RUN_1_KEY_1( 4, DSTIP)
        T2_RUN_AFTER_2_KEY_1( 5, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_1( 6, DSTIP, SIZE)
        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        T2_RUN_AFTER_2_KEY_2( 8, SRCIP, DSTIP, SIZE)
        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16); 
            UM_RUN_END_2(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(9) 
        //


        // apply O2
        T1_RUN_5_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0 || ig_md.d_10_est1_5 == 0) { /* process_new_flow() */ }
        // 

        T2_RUN_AFTER_3_KEY_2(12, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        // HLL for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_32, ig_md.d_14_level);
            update_14.apply(DSTIP, DSTPORT, ig_md.d_14_level);
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(15, DSTIP, DSTPORT, 1)
        // 

        // MRAC for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16);
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_16, ig_md.d_17_index1_16);
        //

        T2_RUN_AFTER_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_res_hash);
        d_19_tcam_lpm_2.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16_1024, ig_md.d_19_base_16_2048, ig_md.d_19_threshold);
        d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16);
        update_19_1.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index1_16, ig_md.d_19_res_hash[1:1], 1, ig_md.d_19_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(19)
        // 

        T1_RUN_3_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_32);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_32, ig_md.d_22_index1_16);
        //

        T3_RUN_AFTER_5_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // MRAC for inst 24
            d_24_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_24_base_16);
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16);
            update_24.apply(ig_md.d_24_base_16, ig_md.d_24_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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