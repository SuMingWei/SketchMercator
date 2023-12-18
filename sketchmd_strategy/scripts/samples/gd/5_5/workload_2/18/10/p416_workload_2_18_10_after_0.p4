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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 220, 131072)
    T1_INIT_4( 2, 220, 524288)
    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_3_tcam_lpm;
        T4_T4_KEY_UPDATE_220_65536(32w0x30243f0b) update_3_1;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_13_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_13_hash_call;
        TCAM_LPM_HLLPCSA() d_13_tcam_lpm;
        GET_BITMASK() d_13_get_bitmask;
        T2_T5_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_3;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_9_above_threshold;
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_9_res_hash_call;
        T3_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_1;
        T3_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_2;
        T3_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_3;
    //

    T2_INIT_HH_1(10, 220, 16384)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
    // 

    T2_INIT_HH_3(11, 220, 4096)
    T3_INIT_HH_4( 8, 220, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_8(32w0x30244f0b) d_14_sampling_hash_call;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        LPM_OPT_MRAC_2() d_14_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_14;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_8(32w0x30244f0b) d_16_sampling_hash_call;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        LPM_OPT_MRAC_2() d_16_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_16;
    // 

    UM_INIT_1(18, 220, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_3_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_3_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_5_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

        //

        T1_RUN_2_KEY_4( 1, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_4( 2, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_3_level);
            update_3_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_3_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_13_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_13_level);
            d_13_get_bitmask.apply(ig_md.d_13_level, ig_md.d_13_bitmask);
            update_13_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_13_bitmask, ig_md.d_13_est_1);
            update_13_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_13_est_2);
            update_13_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_13_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(13)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_res_hash);
            update_9_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_9_res_hash[2:2], ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_9_res_hash[3:3], ig_md.d_9_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(9)
        //

        T2_RUN_AFTER_1_KEY_4(10, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_3_KEY_4(7, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 

        T2_RUN_AFTER_3_KEY_4(11, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T3_RUN_AFTER_4_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
        update_14.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16);
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_16_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048);
        d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
        update_16.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16);
        // 

        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16); 
            UM_RUN_END_1(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(18) 
        //

        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport); 
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