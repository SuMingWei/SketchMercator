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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;
        action d_9_xor_construction() { ig_md.d_9_sampling_hash_16 = ig_md.d_1_sampling_hash_16 ^ ig_md.d_2_sampling_hash_16; }

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 131072, 14,  8)
    MRB_INIT_1( 2, 100, 262144, 15,  8)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_5_2;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_5_3;
    //

    T2_INIT_HH_3( 8, 200, 8192)
    T2_INIT_HH_5( 7, 200, 8192)
    MRAC_INIT_1( 9, 200, 16384, 11,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_5;
    //

    UM_INIT_5(12, 110, 10, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_15_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_3;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_4;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_5;
    //


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_sampling_hash_call;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        LPM_OPT_MRAC_2() d_16_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_16;
    // 

    T5_INIT_1(18, 220, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(21, 220)
        ABOVE_THRESHOLD_4() d_21_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_21_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_21_2;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_21_3;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_21_4;
    // 

    T1_INIT_2(22, 221, 524288)
    MRB_INIT_1(23, 221, 262144, 14, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_25_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_25_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_25_2;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_25_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_25_4;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);
            d_9_xor_construction();
            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_32);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //

        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_1(3, DSTIP, 1)
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_5_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, DSTIP, 1, 1, ig_md.d_5_est_3);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_6_above_threshold);
        //

        T2_RUN_AFTER_3_KEY_2( 8, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2( 7, SRCIP, DSTIP, SIZE)
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_10_1.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_10_est_3);
            d_11_above_threshold.apply(ig_md.d_10_est_1, ig_md.d_10_est_2, ig_md.d_10_est_3, ig_md.d_11_above_threshold);
            update_10_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_est_4);
            update_10_5.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_est_5);
        //

        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_12_index3_16); 
            d_12_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_12_index4_16); 
            d_12_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_12_index5_16); 
            UM_RUN_END_5(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(12) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
            update_13_1.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
            update_13_2.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
            d_15_above_threshold.apply(ig_md.d_13_est_1, ig_md.d_13_est_2, ig_md.d_15_above_threshold);
            update_13_3.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_13_est_3);
            update_13_4.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_13_est_4);
            update_13_5.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_13_est_5);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048);
        d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
        update_16.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16);
        // 

        // PCSA for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_18_level);
            d_18_get_bitmask.apply(ig_md.d_18_level, ig_md.d_18_bitmask);
            update_18.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_bitmask);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], SIZE, ig_md.d_21_est_1);
        d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16);
        update_21_2.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index2_16, ig_md.d_21_res_hash[2:2], SIZE, ig_md.d_21_est_2);
        d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16);
        update_21_3.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index3_16, ig_md.d_21_res_hash[3:3], SIZE, ig_md.d_21_est_3);
        d_21_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index4_16);
        update_21_4.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index4_16, ig_md.d_21_res_hash[4:4], SIZE, ig_md.d_21_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(21)
        // 

        T1_RUN_2_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_22_est1_1 == 0 || ig_md.d_22_est1_2 == 0) { /* process_new_flow() */ }
        // MRB for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_32);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_32, ig_md.d_23_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_25_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_25_est_1);
            update_25_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_25_est_2);
            update_25_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_25_est_3);
            update_25_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_25_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(25)
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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