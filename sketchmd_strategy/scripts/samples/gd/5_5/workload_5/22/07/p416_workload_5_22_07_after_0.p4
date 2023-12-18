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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 262144, 14, 16)
    T2_INIT_HH_5( 2, 100, 8192)
    UM_INIT_5( 3, 100, 10, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_5_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_hash_call;
        TCAM_LPM_HLLPCSA() d_5_tcam_lpm;
        GET_BITMASK() d_5_get_bitmask;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_res_hash_call;
        T3_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
        T3_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T3_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
        T3_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_4;
        T3_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_5;
    //

    UM_INIT_2( 6, 100, 10, 16384)
    MRB_INIT_1( 7, 200, 262144, 15,  8)
    T2_INIT_HH_2(10, 200, 16384)
    T2_INIT_HH_3( 8, 200, 8192)
    T2_INIT_HH_4( 9, 200, 4096)
    MRAC_INIT_1(11, 200, 16384, 10, 16)
    T2_INIT_2(12, 110, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_sampling_hash_call;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        LPM_OPT_MRAC_2() d_13_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_13;
    // 

    T1_INIT_5(15, 110, 131072)
    MRB_INIT_1(16, 110, 131072, 14,  8)
    T3_INIT_HH_2(17, 110, 16384)
    T2_INIT_HH_5(18, 110, 4096)
    UM_INIT_5(19, 110, 10, 16384)
    T5_INIT_1(20, 220, 16384)
    T1_INIT_4(21, 221, 524288)
    UM_INIT_4(22, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_19_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //

        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)
        // UnivMon for inst 3
            d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash); 
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16, ig_md.d_3_threshold); 
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16); 
            d_3_index_hash_call_2.apply(SRCIP, ig_md.d_3_index2_16); 
            d_3_index_hash_call_3.apply(SRCIP, ig_md.d_3_index3_16); 
            d_3_index_hash_call_4.apply(SRCIP, ig_md.d_3_index4_16); 
            d_3_index_hash_call_5.apply(SRCIP, ig_md.d_3_index5_16); 
            UM_RUN_END_5(3, ig_md.d_3_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(3) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_5_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_5_level);
            d_5_get_bitmask.apply(ig_md.d_5_level, ig_md.d_5_bitmask);
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash);
            update_5_1.apply(DSTIP, 1, ig_md.d_5_res_hash[1:1], ig_md.d_5_bitmask, ig_md.d_5_est_1);
            update_5_2.apply(DSTIP, 1, ig_md.d_5_res_hash[2:2], ig_md.d_5_est_2);
            update_5_3.apply(DSTIP, 1, ig_md.d_5_res_hash[3:3], ig_md.d_5_est_3);
            update_5_4.apply(DSTIP, 1, ig_md.d_5_res_hash[4:4], ig_md.d_5_est_4);
            update_5_5.apply(DSTIP, 1, ig_md.d_5_res_hash[5:5], ig_md.d_5_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(5)
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //

        // MRB for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_32);
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_32, ig_md.d_7_index1_16);
        //

        T2_RUN_AFTER_2_KEY_2(10, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_3_KEY_2( 8, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_4_KEY_2( 9, SRCIP, DSTIP, 1)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        T2_RUN_2_KEY_2(12, SRCIP, SRCPORT, SIZE)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048);
        d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
        update_13.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16);
        // 

        T1_RUN_5_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0 || ig_md.d_15_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_32);
            d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_32, ig_md.d_16_index1_16);
        //

        T3_RUN_AFTER_2_KEY_2(17, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_2(18, DSTIP, DSTPORT, SIZE)
        // UnivMon for inst 19
            d_19_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_19_index3_16); 
            d_19_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_19_index4_16); 
            d_19_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_19_index5_16); 
            UM_RUN_END_5(19, ig_md.d_19_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(19) 
        //

        // PCSA for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            update_20.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_bitmask);
        //

        T1_RUN_4_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0 || ig_md.d_21_est1_4 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 22
            d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index2_16); 
            d_22_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index3_16); 
            d_22_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index4_16); 
            UM_RUN_END_4(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(22) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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