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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    T1_INIT_1( 3, 110, 524288)
    T1_INIT_3( 2, 110, 131072)
    T1_INIT_5( 1, 110, 524288)
    T4_INIT_1( 4, 110, 16384)
    MRB_INIT_1( 5, 110, 131072, 14,  8)
    T2_INIT_HH_2(13, 110, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_3;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_res_hash_call;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_10_1;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_10_2;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_10_3;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_10_4;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_3;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_4;
    //


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_sampling_hash_call;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_14_index_hash_call_1;
        LPM_OPT_MRAC_2() d_14_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_14;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(16, 110)
        ABOVE_THRESHOLD_1() d_16_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_16_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_4_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 3, DSTIP, DSTPORT) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_2( 2, DSTIP, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(DSTIP, DSTPORT, ig_md.d_4_level);
        //

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        T2_RUN_AFTER_2_KEY_2(13, DSTIP, DSTPORT, SIZE)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_6_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_6_est_3);
            d_11_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_11_above_threshold);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_res_hash);
            update_10_1.apply(DSTIP, DSTPORT, 1, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
            update_10_2.apply(DSTIP, DSTPORT, 1, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
            update_10_3.apply(DSTIP, DSTPORT, 1, ig_md.d_10_res_hash[3:3], 1, ig_md.d_10_est_3);
            update_10_4.apply(DSTIP, DSTPORT, 1, ig_md.d_10_res_hash[4:4], ig_md.d_10_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(10)
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_8_1.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_8_est_1);
            update_8_2.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_8_est_2);
            update_8_3.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_8_est_4);
            d_9_above_threshold.apply(ig_md.d_8_est_1, ig_md.d_8_est_2, ig_md.d_8_est_3, ig_md.d_8_est_4, ig_md.d_9_above_threshold);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_14_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048);
        d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16);
        update_14.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index1_16);
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash);
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048, ig_md.d_16_threshold);
        d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
        update_16_1.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16, ig_md.d_16_res_hash[1:1], SIZE, ig_md.d_16_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(16)
        // 

        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip, ig_md.hf_dstport); 
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