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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 524288)
    MRB_INIT_1( 2, 100, 524288, 15, 16)
    T2_INIT_HH_5( 3, 100, 4096)
    UM_INIT_3( 5, 100, 11, 32768)
    UM_INIT_4( 4, 100, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_4;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_10_hash_call;
        TCAM_LPM_HLLPCSA() d_10_tcam_lpm;
        GET_BITMASK() d_10_get_bitmask;
        T2_T5_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_2;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_3;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_10_5;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_12_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_12_5;
    //

    UM_INIT_4(14, 110, 10, 16384)
    T2_INIT_HH_3(16, 110, 8192)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_15_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_15_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_15_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_15_above_threshold;
    // 

    T1_INIT_3(18, 220, 131072)
    T3_INIT_HH_1(19, 220, 16384)
    T3_INIT_HH_1(20, 220, 16384)
    T1_INIT_3(21, 221, 131072)
    T4_INIT_1(22, 221, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(23, 221)
        ABOVE_THRESHOLD_1() d_23_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_23_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_32);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //

        T2_RUN_AFTER_5_KEY_1( 3, SRCIP, 1)
        // UnivMon for inst 5
            d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(SRCIP, ig_md.d_5_index2_16); 
            d_5_index_hash_call_3.apply(SRCIP, ig_md.d_5_index3_16); 
            UM_RUN_END_3(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(5) 
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16); 
            UM_RUN_END_4(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(4) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_7_1.apply(DSTIP, 1, 1, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, 1, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, 1, 1, ig_md.d_7_est_3);
            update_7_4.apply(DSTIP, 1, ig_md.d_7_est_4);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_10_level);
            d_10_get_bitmask.apply(ig_md.d_10_level, ig_md.d_10_bitmask);
            update_10_1.apply(SRCIP, DSTIP, 1, ig_md.d_10_bitmask, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_4);
            update_10_5.apply(SRCIP, DSTIP, 1, ig_md.d_10_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(10)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_12_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_12_est_3);
            update_12_4.apply(SRCIP, SRCPORT, 1, ig_md.d_12_est_4);
            update_12_5.apply(SRCIP, SRCPORT, 1, ig_md.d_12_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(12)
        //

        // UnivMon for inst 14
            d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_14_index2_16); 
            d_14_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_14_index3_16); 
            d_14_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_14_index4_16); 
            UM_RUN_END_4(14, ig_md.d_14_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(14) 
        //

        T2_RUN_AFTER_3_KEY_2(16, DSTIP, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_4_KEY_2(15, DSTIP, DSTPORT, 1)
        // 

        T1_RUN_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_1_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T3_RUN_AFTER_1_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_3_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0) { /* process_new_flow() */ }
        // HLL for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_32, ig_md.d_22_level);
            update_22.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_level);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], 1, ig_md.d_23_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(23)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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