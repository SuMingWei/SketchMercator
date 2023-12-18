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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_4;
    //

    T1_INIT_2( 4, 100, 262144)
    T1_INIT_3( 3, 100, 524288)
    T1_INIT_4( 5, 200, 524288)
    T1_INIT_1( 7, 110, 262144)
    T1_INIT_4( 6, 110, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_3;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_2() d_13_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_13_2;
    // 

    T1_INIT_5(14, 110, 262144)
    T2_INIT_HH_1(15, 110, 16384)
    T1_INIT_1(16, 220, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_18_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_17_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_17_2;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_17_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_17_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_17_5;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_20_tcam_lpm;
        GET_BITMASK() d_20_get_bitmask;
        T5_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_20_3;
    //

    MRAC_INIT_1(21, 221, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_32);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, 1, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, ig_md.d_2_est_4);
        //

        T1_RUN_2_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 7, SRCIP, SRCPORT) if (ig_md.d_7_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 6, SRCIP, SRCPORT) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_9_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, SRCPORT, 1, ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(13)
        // 

        T1_RUN_5_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0 || ig_md.d_14_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2(15, DSTIP, DSTPORT, 1)
        T1_RUN_1_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_17_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_17_est_1);
            update_17_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_17_est_2);
            update_17_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_17_est_3);
            d_18_above_threshold.apply(ig_md.d_17_est_1, ig_md.d_17_est_2, ig_md.d_17_est_3, ig_md.d_18_above_threshold);
            update_17_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_17_est_4);
            update_17_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_17_est_5);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_20_tcam_lpm.apply(ig_md.d_19_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_bitmask, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_est_2);
            update_20_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_20_est_3);
        //

        // MRAC for inst 21
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16);
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
            update_21.apply(ig_md.d_21_base_16, ig_md.d_21_index1_16);
        //

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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