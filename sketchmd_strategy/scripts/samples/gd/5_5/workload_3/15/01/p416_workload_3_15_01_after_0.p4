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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 262144, 14, 16)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_2_above_threshold;
    // 

    T1_INIT_5( 4, 100, 524288)
    T1_INIT_5( 5, 100, 524288)
    MRAC_INIT_1( 6, 100, 32768, 11, 16)
    T1_INIT_1( 7, 200, 524288)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(9, 200)
        ABOVE_THRESHOLD_5() d_9_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_9_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_9_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_9_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_9_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_9_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_9_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_9_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_9_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_9_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_9_5;
    // 

    UM_INIT_5(10, 200, 10, 16384)
    T2_INIT_HH_5(11, 110, 16384)
    T1_INIT_1(12, 110, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_14_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_3;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_4;
    //

    UM_INIT_5(15, 110, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_1(2, SRCIP, 1)
        // 

        T1_RUN_5_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0 || ig_md.d_5_est1_5 == 0) { /* process_new_flow() */ }
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048, ig_md.d_9_threshold);
        d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
        update_9_1.apply(ig_md.d_9_base_16_2048, ig_md.d_9_index1_16, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
        d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16);
        update_9_2.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index2_16, ig_md.d_9_res_hash[2:2], 1, ig_md.d_9_est_2);
        d_9_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_9_index3_16);
        update_9_3.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index3_16, ig_md.d_9_res_hash[3:3], 1, ig_md.d_9_est_3);
        d_9_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_9_index4_16);
        update_9_4.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index4_16, ig_md.d_9_res_hash[4:4], 1, ig_md.d_9_est_4);
        d_9_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_9_index5_16);
        update_9_5.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index5_16, ig_md.d_9_res_hash[5:5], 1, ig_md.d_9_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(9)
        // 

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16); 
            d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16); 
            d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16); 
            d_10_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_10_index5_16); 
            UM_RUN_END_5(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(10) 
        //

        T2_RUN_AFTER_5_KEY_2(11, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(12, DSTIP, DSTPORT)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_13_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_13_est_1);
            update_13_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_13_est_2);
            update_13_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_13_est_3);
            update_13_4.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_13_est_4);
            d_14_above_threshold.apply(ig_md.d_13_est_1, ig_md.d_13_est_2, ig_md.d_13_est_3, ig_md.d_13_est_4, ig_md.d_14_above_threshold);
        //

        // UnivMon for inst 15
            d_15_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_15_index4_16); 
            d_15_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_15_index5_16); 
            UM_RUN_END_5(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(15) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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