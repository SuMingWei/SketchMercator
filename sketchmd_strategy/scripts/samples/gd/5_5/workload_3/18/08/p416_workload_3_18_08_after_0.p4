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
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_13_auto_sampling_hash_call;

    //

    T2_INIT_HH_2( 1, 100, 4096)
    MRAC_INIT_1( 2, 100, 16384, 10, 16)
    T1_INIT_2( 3, 200, 524288)
    T2_INIT_HH_4( 5, 200, 4096)

    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_4_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_2;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_5;
    //

    UM_INIT_3( 9, 110, 10, 16384)
    T1_INIT_5(10, 110, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_12_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_11_3;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_15_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_15_hash_call;
        TCAM_LPM_HLLPCSA() d_15_tcam_lpm;
        GET_BITMASK() d_15_get_bitmask;
        T2_T5_KEY_UPDATE_220_16384(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_15_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_15_3;
    //

    T2_INIT_HH_5(14, 220, 4096)
    T4_INIT_1(16, 221, 32768)
    T1_INIT_1(17, 221, 524288)
    T5_INIT_1(18, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_32);

            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_32);

        //

        T2_RUN_AFTER_2_KEY_1( 1, DSTIP, 1)
        // MRAC for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16);
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_16, ig_md.d_2_index1_16);
        //

        T1_RUN_2_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_2( 5, SRCIP, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(4, SRCIP, DSTIP, 1)
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_7_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_7_est_1);
            update_7_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_7_est_2);
            update_7_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_7_est_3);
            d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_7_est_3, ig_md.d_8_above_threshold);
            update_7_4.apply(SRCIP, SRCPORT, 1, ig_md.d_7_est_4);
            update_7_5.apply(SRCIP, SRCPORT, 1, ig_md.d_7_est_5);
        //

        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_9_index3_16); 
            UM_RUN_END_3(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(9) 
        //

        T1_RUN_5_KEY_2(10, DSTIP, DSTPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0 || ig_md.d_10_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_11_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_11_est_1);
            update_11_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_11_est_2);
            d_12_above_threshold.apply(ig_md.d_11_est_1, ig_md.d_11_est_2, ig_md.d_12_above_threshold);
            update_11_3.apply(DSTIP, DSTPORT, 1, ig_md.d_11_est_3);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_15_tcam_lpm.apply(ig_md.d_13_sampling_hash_32, ig_md.d_15_level);
            d_15_get_bitmask.apply(ig_md.d_15_level, ig_md.d_15_bitmask);
            update_15_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_15_bitmask, ig_md.d_15_est_1);
            update_15_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_15_est_2);
            update_15_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_15_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(15)
        //

        T2_RUN_AFTER_5_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // HLL for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_16_level);
            update_16.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_level);
        //

        T1_RUN_1_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        // PCSA for inst 18
            d_18_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_18_level);
            d_18_get_bitmask.apply(ig_md.d_18_level, ig_md.d_18_bitmask);
            update_18.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_bitmask);
        //

        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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