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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 65536)
    T2_INIT_4( 2, 100, 4096)
    T1_INIT_1( 3, 100, 524288)
    T2_INIT_HH_1( 4, 100, 16384)
    UM_INIT_2( 5, 100, 10, 16384)
    MRB_INIT_1( 6, 200, 262144, 15,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_hash_call;
        TCAM_LPM_HLLPCSA() d_8_tcam_lpm;
        GET_BITMASK() d_8_get_bitmask;
        T2_T5_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_3;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_res_hash_call;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_2;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_10_3;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_10_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(12, 110)
        ABOVE_THRESHOLD_2() d_12_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_12_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_12_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_12_2;
    // 

    T1_INIT_2(13, 220, 131072)
    T2_INIT_HH_2(15, 220, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_16_above_threshold;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_1;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_3;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_18_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_17_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_17_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_17_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_17_4;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_17_5;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //

        T2_RUN_4_KEY_1( 2, SRCIP, 1)
        T1_RUN_1_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_1( 4, DSTIP, 1)
        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, ig_md.d_5_index2_16); 
            UM_RUN_END_2(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(5) 
        //

        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_8_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            update_8_1.apply(SRCIP, DSTIP, 1, ig_md.d_8_bitmask, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(8)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_res_hash);
            update_10_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_res_hash[3:3], ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_res_hash[4:4], ig_md.d_10_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(10)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], SIZE, ig_md.d_12_est_1);
        d_12_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_12_index2_16);
        update_12_2.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index2_16, ig_md.d_12_res_hash[2:2], SIZE, ig_md.d_12_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(12)
        // 

        T1_RUN_2_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_14_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_14_est_2);
            d_16_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_14_est_2, ig_md.d_16_above_threshold);
            update_14_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_est_3);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_17_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, SIZE, ig_md.d_17_est_1);
            d_18_above_threshold.apply(ig_md.d_17_est_1, ig_md.d_18_above_threshold);
            update_17_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_17_est_2);
            update_17_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_17_est_3);
            update_17_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_17_est_4);
            update_17_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_17_est_5);
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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