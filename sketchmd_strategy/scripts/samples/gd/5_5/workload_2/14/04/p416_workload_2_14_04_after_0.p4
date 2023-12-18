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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(16384, 14, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T1_INIT_2( 2, 200, 262144)
    T1_INIT_2( 4, 200, 524288)
    T1_INIT_4( 1, 200, 262144)
    T1_INIT_4( 3, 200, 131072)
    T4_INIT_1( 5, 200, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_6_tcam_lpm;
        GET_BITMASK() d_6_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_11_above_threshold;
        T2_T5_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_1;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_res_hash_call;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_1;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_2;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_3;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_4;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_5;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_3;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(14, 200)
        ABOVE_THRESHOLD_4() d_14_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_14_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_14_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_14_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_14_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_14_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_14_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_14_sampling_hash_16);

        //

        T1_RUN_2_KEY_2( 2, SRCIP, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            update_5.apply(SRCIP, DSTIP, ig_md.d_5_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_6_level);
            d_6_get_bitmask.apply(ig_md.d_6_level, ig_md.d_6_bitmask);
            update_6_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_bitmask, ig_md.d_6_est_1);
            d_11_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_11_above_threshold);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash);
            update_9_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[2:2], 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[3:3], 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[4:4], ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[5:5], ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_8_1.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_8_est_3);
            d_10_above_threshold.apply(ig_md.d_8_est_1, ig_md.d_8_est_2, ig_md.d_8_est_3, ig_md.d_10_above_threshold);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_14_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
        d_14_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_14_index2_16);
        update_14_2.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index2_16, ig_md.d_14_res_hash[2:2], SIZE, ig_md.d_14_est_2);
        d_14_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_14_index3_16);
        update_14_3.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index3_16, ig_md.d_14_res_hash[3:3], SIZE, ig_md.d_14_est_3);
        d_14_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_14_index4_16);
        update_14_4.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index4_16, ig_md.d_14_res_hash[4:4], SIZE, ig_md.d_14_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(14)
        // 

        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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