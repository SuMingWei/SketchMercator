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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 262144)
    T1_INIT_5( 2, 100, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_13_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_13_hash_call;
        TCAM_LPM_HLLPCSA() d_13_tcam_lpm;
        GET_BITMASK() d_13_get_bitmask;
        T2_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_13_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_13_3;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_res_hash_call;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_9_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_9_2;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_9_3;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_9_4;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_9_5;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_1;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_2;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_3;
    //


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_5_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 

    T3_INIT_HH_5(11, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(17, 100)
        ABOVE_THRESHOLD_3() d_17_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_17_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_17_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_17_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_17_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_17_3;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 100)
        ABOVE_THRESHOLD_3() d_18_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_18_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_18_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_18_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_18_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_18_3;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_32);

            d_17_auto_sampling_hash_call.apply(SRCIP, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, ig_md.d_18_sampling_hash_16);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_13_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_13_level);
            d_13_get_bitmask.apply(ig_md.d_13_level, ig_md.d_13_bitmask);
            update_13_1.apply(SRCIP, SIZE, ig_md.d_13_bitmask, ig_md.d_13_est_1);
            update_13_2.apply(SRCIP, SIZE, ig_md.d_13_est_2);
            update_13_3.apply(SRCIP, SIZE, ig_md.d_13_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(13)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_res_hash_call.apply(SRCIP, ig_md.d_9_res_hash);
            update_9_1.apply(SRCIP, 1, ig_md.d_9_res_hash[1:1], SIZE, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, 1, ig_md.d_9_res_hash[2:2], SIZE, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, 1, ig_md.d_9_res_hash[3:3], ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, 1, ig_md.d_9_res_hash[4:4], ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, 1, ig_md.d_9_res_hash[5:5], ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash);
            update_4_1.apply(SRCIP, SIZE, ig_md.d_4_res_hash[1:1], 1, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, SIZE, ig_md.d_4_res_hash[2:2], 1, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, SIZE, ig_md.d_4_res_hash[3:3], 1, ig_md.d_4_est_3);
            d_10_above_threshold.apply(ig_md.d_4_est_1, ig_md.d_4_est_2, ig_md.d_4_est_3, ig_md.d_10_above_threshold);
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_1(5, SRCIP, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_1(7, SRCIP, 1)
        // 

        T3_RUN_AFTER_5_KEY_1(11, SRCIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_17_res_hash_call.apply(SRCIP, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(SRCIP, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], SIZE, ig_md.d_17_est_1);
        d_17_index_hash_call_2.apply(SRCIP, ig_md.d_17_index2_16);
        update_17_2.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index2_16, ig_md.d_17_res_hash[2:2], SIZE, ig_md.d_17_est_2);
        d_17_index_hash_call_3.apply(SRCIP, ig_md.d_17_index3_16);
        update_17_3.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index3_16, ig_md.d_17_res_hash[3:3], SIZE, ig_md.d_17_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(17)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(SRCIP, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(SRCIP, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
        d_18_index_hash_call_3.apply(SRCIP, ig_md.d_18_index3_16);
        update_18_3.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index3_16, ig_md.d_18_res_hash[3:3], SIZE, ig_md.d_18_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(18)
        // 

        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip); 
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