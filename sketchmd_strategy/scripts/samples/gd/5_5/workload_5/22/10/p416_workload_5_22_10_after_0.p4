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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_8(32w0x30244f0b) d_1_sampling_hash_call;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_1_index_hash_call_1;
        LPM_OPT_MRAC_2() d_1_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_1;
    // 

    T1_INIT_2( 3, 100, 131072)
    T4_INIT_1( 4, 100, 16384)
    MRB_INIT_1( 5, 100, 131072, 14,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_4;
    //

    UM_INIT_1( 9, 100, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_5;
    //


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_200_16_8(32w0x30244f0b) d_12_sampling_hash_call;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        LPM_OPT_MRAC_2() d_12_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_12;
    // 

    T2_INIT_2(14, 110, 8192)
    T1_INIT_1(15, 110, 524288)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_sampling_hash_call;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_16_index_hash_call_1;
        LPM_OPT_MRAC_2() d_16_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_16;
    // 

    T1_INIT_1(19, 220, 524288)
    T1_INIT_2(18, 220, 131072)
    UM_INIT_2(21, 220, 11, 32768)
    UM_INIT_3(20, 220, 10, 16384)
    T1_INIT_3(22, 221, 524288)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_16);

        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_1_tcam_lpm_2.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16_1024, ig_md.d_1_base_16_2048);
        d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
        update_1.apply(ig_md.d_1_base_16_2048, ig_md.d_1_index1_16);
        // 

        T1_RUN_2_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(DSTIP, ig_md.d_4_level);
        //

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_6_1.apply(DSTIP, SIZE, 1, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, SIZE, 1, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, SIZE, 1, ig_md.d_6_est_3);
            d_7_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_7_above_threshold);
            update_6_4.apply(DSTIP, SIZE, ig_md.d_6_est_4);
        //

        // UnivMon for inst 9
            d_9_res_hash_call.apply(DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16); 
            UM_RUN_END_1(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(9) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_11_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, 1, ig_md.d_11_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(11)
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048);
        d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
        update_12.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16);
        // 

        T2_RUN_2_KEY_2(14, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048);
        d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
        update_16.apply(ig_md.d_16_base_16_1024, ig_md.d_16_index1_16);
        // 

        T1_RUN_1_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_19_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16); 
            UM_RUN_END_2(21, ig_md.d_21_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(21) 
        //

        // UnivMon for inst 20
            d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_res_hash); 
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16, ig_md.d_20_threshold); 
            d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16); 
            d_20_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index2_16); 
            d_20_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index3_16); 
            UM_RUN_END_3(20, ig_md.d_20_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(20) 
        //

        T1_RUN_3_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_22_est1_1 == 0 || ig_md.d_22_est1_2 == 0 || ig_md.d_22_est1_3 == 0) { /* process_new_flow() */ }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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