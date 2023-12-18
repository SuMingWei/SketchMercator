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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    T2_INIT_HH_5( 1, 100, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(4, 100)
        ABOVE_THRESHOLD_2() d_4_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_4_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_4_2;
    // 

    T1_INIT_5( 5, 200, 131072)
    MRB_INIT_1( 6, 200, 262144, 15,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_9_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_9_hash_call;
        TCAM_LPM_HLLPCSA() d_9_tcam_lpm;
        GET_BITMASK() d_9_get_bitmask;
        T2_T5_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_3;
    //

    T1_INIT_1(10, 110, 131072)
    T2_INIT_HH_3(11, 110, 16384)
    MRB_INIT_1(12, 110, 262144, 15,  8)
    T2_INIT_3(13, 110, 16384)
    T1_INIT_1(15, 220, 262144)

    // apply O2
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_14_1;
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_14_2;
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_14_3;
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_14_4;
    // 

    MRB_INIT_1(17, 220, 131072, 14,  8)
    T3_INIT_HH_4(18, 220, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_sampling_hash_call;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_19_index_hash_call_1;
        LPM_OPT_MRAC_2() d_19_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_19;
    // 

    T1_INIT_5(21, 221, 524288)
    T2_INIT_HH_3(23, 221, 4096)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_24_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_2;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_3;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_4;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_5;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_sampling_hash_16);

        //

        T2_RUN_AFTER_5_KEY_1( 1, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash);
        d_4_tcam_lpm_2.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16_1024, ig_md.d_4_base_16_2048, ig_md.d_4_threshold);
        d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
        update_4_1.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index1_16, ig_md.d_4_res_hash[1:1], 1, ig_md.d_4_est_1);
        d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16);
        update_4_2.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index2_16, ig_md.d_4_res_hash[2:2], 1, ig_md.d_4_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(4)
        // 

        T1_RUN_5_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0 || ig_md.d_5_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_9_level);
            d_9_get_bitmask.apply(ig_md.d_9_level, ig_md.d_9_bitmask);
            update_9_1.apply(SRCIP, DSTIP, 1, ig_md.d_9_bitmask, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, 1, 1, ig_md.d_9_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(9)
        //

        T1_RUN_1_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_2(11, SRCIP, SRCPORT, 1)
        // MRB for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_32);
            d_12_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_32, ig_md.d_12_index1_16);
        //

        T2_RUN_3_KEY_2(13, DSTIP, DSTPORT, 1)
        T1_RUN_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O2
        T1_RUN_4_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0) { /* process_new_flow() */ }
        // 

        // MRB for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_32);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_32, ig_md.d_17_index1_16);
        //

        T3_RUN_AFTER_4_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_19_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_19_base_16_1024, ig_md.d_19_base_16_2048);
        d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16);
        update_19.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index1_16);
        // 

        T1_RUN_5_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0 || ig_md.d_21_est1_4 == 0 || ig_md.d_21_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_22_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_22_est_1);
            update_22_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_22_est_2);
            update_22_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_22_est_3);
            update_22_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_22_est_4);
            d_24_above_threshold.apply(ig_md.d_22_est_1, ig_md.d_22_est_2, ig_md.d_22_est_3, ig_md.d_22_est_4, ig_md.d_24_above_threshold);
            update_22_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_22_est_5);
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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