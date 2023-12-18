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
    METADATA_DIM(25)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 30720)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 262144)
    UM_INIT_5( 2, 100, 10, 16384)
    T1_INIT_5( 3, 100, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_4;
    //

    MRAC_INIT_1( 6, 100, 16384, 11,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_4;
    //

    T2_INIT_HH_3( 9, 200, 4096)
    MRAC_INIT_1(10, 200, 16384, 10, 16)
    T2_INIT_HH_1(13, 110, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_12_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_res_hash_call;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_2;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_3;
    //

    UM_INIT_2(14, 110, 11, 32768)
    MRB_INIT_1(15, 110, 524288, 15, 16)
    T3_INIT_HH_5(16, 110, 8192)
    UM_INIT_5(17, 110, 10, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_20_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_hash_call;
        TCAM_LPM_HLLPCSA() d_20_tcam_lpm;
        GET_BITMASK() d_20_get_bitmask;
        T2_T5_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_20_2;
    //

    T2_INIT_HH_1(19, 220, 16384)
    T2_INIT_HH_2(21, 220, 16384)
    MRAC_INIT_1(22, 220, 16384, 11,  8)
    T3_INIT_HH_1(24, 221, 16384)
    T2_INIT_HH_2(23, 221, 8192)
    T2_INIT_HH_3(25, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            d_2_index_hash_call_2.apply(SRCIP, ig_md.d_2_index2_16); 
            d_2_index_hash_call_3.apply(SRCIP, ig_md.d_2_index3_16); 
            d_2_index_hash_call_4.apply(SRCIP, ig_md.d_2_index4_16); 
            d_2_index_hash_call_5.apply(SRCIP, ig_md.d_2_index5_16); 
            UM_RUN_END_5(2, ig_md.d_2_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(2) 
        //

        T1_RUN_5_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_5_1.apply(DSTIP, SIZE, SIZE, ig_md.d_5_est_1);
            update_5_2.apply(DSTIP, SIZE, SIZE, ig_md.d_5_est_2);
            update_5_3.apply(DSTIP, SIZE, SIZE, ig_md.d_5_est_3);
            update_5_4.apply(DSTIP, SIZE, ig_md.d_5_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(5)
        //

        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_8_1.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(8)
        //

        T2_RUN_AFTER_3_KEY_2( 9, SRCIP, DSTIP, SIZE)
        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T2_RUN_AFTER_1_KEY_2(13, SRCIP, SRCPORT, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash);
            update_12_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_12_res_hash[1:1], 1, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_12_res_hash[2:2], 1, ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_12_res_hash[3:3], ig_md.d_12_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(12)
        //

        // UnivMon for inst 14
            d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_14_index2_16); 
            UM_RUN_END_2(14, ig_md.d_14_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(14) 
        //

        // MRB for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_32);
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_32, ig_md.d_15_index1_16);
        //

        T3_RUN_AFTER_5_KEY_2(16, DSTIP, DSTPORT, SIZE)
        // UnivMon for inst 17
            d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_17_index3_16); 
            d_17_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_17_index4_16); 
            d_17_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_17_index5_16); 
            UM_RUN_END_5(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(17) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_20_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_bitmask, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(20)
        //

        T2_RUN_AFTER_1_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_2_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_16, ig_md.d_22_index1_16);
        //

        T3_RUN_AFTER_1_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        T2_RUN_AFTER_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        T2_RUN_AFTER_3_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
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