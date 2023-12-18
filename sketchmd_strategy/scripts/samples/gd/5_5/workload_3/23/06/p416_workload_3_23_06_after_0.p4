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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 28672)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T3_INIT_HH_4( 1, 100, 4096)
    T2_INIT_HH_5( 2, 100, 16384)
    UM_INIT_2( 3, 100, 11, 32768)
    UM_INIT_5( 4, 100, 10, 16384)
    T4_INIT_1( 5, 100, 16384)
    UM_INIT_5( 6, 100, 11, 32768)
    T1_INIT_1( 7, 200, 524288)
    T4_INIT_1( 8, 200, 65536)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_1;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_2;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_5;
    //

    T2_INIT_HH_4(10, 200, 8192)
    UM_INIT_3(13, 200, 10, 16384)
    UM_INIT_5(12, 200, 10, 16384)
    T2_INIT_HH_5(14, 110, 4096)
    MRB_INIT_1(15, 110, 262144, 15,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_17_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_3;
    //

    T1_INIT_2(18, 220, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_21_above_threshold;
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_21_hash_call;
        TCAM_LPM_HLLPCSA() d_21_tcam_lpm;
        GET_BITMASK() d_21_get_bitmask;
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_res_hash_call;
        T3_T5_KEY_UPDATE_221_4096(32w0x30243f0b) update_21_1;
        T3_KEY_UPDATE_221_4096(32w0x30243f0b) update_21_2;
    //

    T2_INIT_HH_1(20, 221, 8192)
    T2_INIT_HH_1(22, 221, 16384)
    MRAC_INIT_1(23, 221, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_13_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_32);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T3_RUN_AFTER_4_KEY_1( 1, SRCIP, 1)
        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)
        // UnivMon for inst 3
            d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash); 
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16, ig_md.d_3_threshold); 
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16); 
            d_3_index_hash_call_2.apply(SRCIP, ig_md.d_3_index2_16); 
            UM_RUN_END_2(3, ig_md.d_3_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(3) 
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16); 
            d_4_index_hash_call_5.apply(SRCIP, ig_md.d_4_index5_16); 
            UM_RUN_END_5(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(4) 
        //

        // HLL for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            update_5.apply(DSTIP, ig_md.d_5_level);
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(DSTIP, ig_md.d_6_index3_16); 
            d_6_index_hash_call_4.apply(DSTIP, ig_md.d_6_index4_16); 
            d_6_index_hash_call_5.apply(DSTIP, ig_md.d_6_index5_16); 
            UM_RUN_END_5(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(6) 
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0) { /* process_new_flow() */ }
        // HLL for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            update_8.apply(SRCIP, DSTIP, ig_md.d_8_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_11_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, 1, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(11)
        //

        T2_RUN_AFTER_4_KEY_2(10, SRCIP, DSTIP, 1)
        // UnivMon for inst 13
            d_13_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_13_index3_16); 
            UM_RUN_END_3(13, ig_md.d_13_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(13) 
        //

        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_12_index3_16); 
            d_12_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_12_index4_16); 
            d_12_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_12_index5_16); 
            UM_RUN_END_5(12, ig_md.d_12_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(12) 
        //

        T2_RUN_AFTER_5_KEY_2(14, SRCIP, SRCPORT, 1)
        // MRB for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_32);
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_32, ig_md.d_15_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_17_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_1);
            update_17_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_2);
            update_17_3.apply(DSTIP, DSTPORT, 1, ig_md.d_17_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(17)
        //

        T1_RUN_2_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_21_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_21_level);
            d_21_get_bitmask.apply(ig_md.d_21_level, ig_md.d_21_bitmask);
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_res_hash);
            update_21_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_21_res_hash[1:1], ig_md.d_21_bitmask, ig_md.d_21_est_1);
            update_21_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_21_res_hash[2:2], ig_md.d_21_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(21)
        //

        T2_RUN_AFTER_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_AFTER_1_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_16, ig_md.d_23_index1_16);
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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