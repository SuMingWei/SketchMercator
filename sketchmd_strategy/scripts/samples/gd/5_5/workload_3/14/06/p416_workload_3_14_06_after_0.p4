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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_sampling_hash_call;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_1_index_hash_call_1;
        LPM_OPT_MRAC_2() d_1_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_1;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_3;
    //

    MRAC_INIT_1( 5, 200, 8192, 10,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_3;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_4;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_5;
    //

    UM_INIT_2( 8, 110, 11, 32768)
    T1_INIT_1( 9, 110, 524288)
    UM_INIT_1(11, 110, 10, 16384)
    UM_INIT_3(10, 110, 10, 16384)
    T1_INIT_2(12, 220, 131072)
    T2_INIT_2(13, 220, 16384)
    T2_INIT_HH_4(14, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_sampling_hash_16);

        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_1_tcam_lpm_2.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16_1024, ig_md.d_1_base_16_2048);
        d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
        update_1.apply(ig_md.d_1_base_16_2048, ig_md.d_1_index1_16);
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, DSTIP, 1, 1, ig_md.d_3_est_3);
            d_4_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_4_above_threshold);
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_6_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_6_est_4);
            update_6_5.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_6_est_5);
            d_7_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_6_est_4, ig_md.d_6_est_5, ig_md.d_7_above_threshold);
        //

        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_8_index2_16); 
            UM_RUN_END_2(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(8) 
        //

        T1_RUN_1_KEY_2( 9, DSTIP, DSTPORT)
        // UnivMon for inst 11
            d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_11_index1_16); 
            UM_RUN_END_1(11, ig_md.d_11_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(11) 
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_10_index2_16); 
            d_10_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_10_index3_16); 
            UM_RUN_END_3(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(10) 
        //

        T1_RUN_2_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_2_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_4_KEY_5(14, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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