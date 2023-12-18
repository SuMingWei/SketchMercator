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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 24576)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;
        action d_9_xor_construction() { ig_md.d_9_sampling_hash_32 = ig_md.d_2_sampling_hash_32 ^ ig_md.d_4_sampling_hash_32; }

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 524288)
    T5_INIT_1( 2, 100, 16384)
    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T4_INIT_1( 4, 100, 16384)
    T2_INIT_HH_4( 5, 100, 4096)
    UM_INIT_2( 6, 100, 11, 32768)
    UM_INIT_4( 7, 100, 10, 16384)
    T1_INIT_4( 8, 200, 262144)
    T4_INIT_1( 9, 200, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_10_tcam_lpm;
        GET_BITMASK() d_10_get_bitmask;
        T2_T5_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_13_tcam_lpm;
        GET_BITMASK() d_13_get_bitmask;
        T5_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_13_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_14_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_13_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_13_3;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_13_4;
    //

    T4_INIT_1(15, 110, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_19_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_19_res_hash_call;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_19_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_19_2;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_19_3;
    //

    T3_INIT_HH_3(17, 110, 4096)
    T3_INIT_HH_5(18, 110, 16384)
    UM_INIT_2(20, 110, 11, 32768)
    T2_INIT_5(21, 110, 8192)
    UM_INIT_2(24, 110, 10, 16384)
    UM_INIT_3(22, 110, 10, 16384)
    UM_INIT_4(23, 110, 11, 32768)
    T2_INIT_HH_3(25, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);
            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);
            d_9_xor_construction();
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_32);

            d_15_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_sampling_hash_32);

            d_20_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_20_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_24_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_22_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // PCSA for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            d_2_get_bitmask.apply(ig_md.d_2_level, ig_md.d_2_bitmask);
            update_2.apply(SRCIP, ig_md.d_2_bitmask);
        //

        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(DSTIP, ig_md.d_4_level);
        //

        T2_RUN_AFTER_4_KEY_1( 5, DSTIP, SIZE)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //

        // UnivMon for inst 7
            d_7_res_hash_call.apply(DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(DSTIP, ig_md.d_7_index4_16); 
            UM_RUN_END_4(7, ig_md.d_7_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(7) 
        //

        T1_RUN_4_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
            update_9.apply(SRCIP, DSTIP, ig_md.d_9_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
            d_10_get_bitmask.apply(ig_md.d_10_level, ig_md.d_10_bitmask);
            update_10_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_bitmask, ig_md.d_10_est_1);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_13_tcam_lpm.apply(ig_md.d_11_sampling_hash_32, ig_md.d_13_level);
            d_13_get_bitmask.apply(ig_md.d_13_level, ig_md.d_13_bitmask);
            update_13_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_13_bitmask, ig_md.d_13_est_1);
            update_13_2.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_13_est_2);
            update_13_3.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_13_est_3);
            update_13_4.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_13_est_4);
            d_14_above_threshold.apply(ig_md.d_13_est_2, ig_md.d_13_est_3, ig_md.d_13_est_4, ig_md.d_14_above_threshold);
        //

        // HLL for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_32, ig_md.d_15_level);
            update_15.apply(SRCIP, SRCPORT, ig_md.d_15_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_19_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_19_res_hash);
            update_19_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_19_res_hash[1:1], SIZE, ig_md.d_19_est_1);
            update_19_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_19_res_hash[2:2], SIZE, ig_md.d_19_est_2);
            update_19_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_19_res_hash[3:3], ig_md.d_19_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(19)
        //

        T3_RUN_AFTER_3_KEY_2(17, SRCIP, SRCPORT, 1)
        T3_RUN_AFTER_5_KEY_2(18, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 20
            d_20_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_20_res_hash); 
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16, ig_md.d_20_threshold); 
            d_20_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_20_index1_16); 
            d_20_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_20_index2_16); 
            UM_RUN_END_2(20, ig_md.d_20_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(20) 
        //

        T2_RUN_5_KEY_2(21, DSTIP, DSTPORT, 1)
        // UnivMon for inst 24
            d_24_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_24_res_hash); 
            d_24_tcam_lpm.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16, ig_md.d_24_threshold); 
            d_24_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_24_index1_16); 
            d_24_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_24_index2_16); 
            UM_RUN_END_2(24, ig_md.d_24_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(24) 
        //

        // UnivMon for inst 22
            d_22_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_22_index2_16); 
            d_22_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_22_index3_16); 
            UM_RUN_END_3(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(22) 
        //

        // UnivMon for inst 23
            d_23_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_23_res_hash); 
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16, ig_md.d_23_threshold); 
            d_23_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_23_index1_16); 
            d_23_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_23_index2_16); 
            d_23_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_23_index3_16); 
            d_23_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_23_index4_16); 
            UM_RUN_END_4(23, ig_md.d_23_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(23) 
        //

        T2_RUN_AFTER_3_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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