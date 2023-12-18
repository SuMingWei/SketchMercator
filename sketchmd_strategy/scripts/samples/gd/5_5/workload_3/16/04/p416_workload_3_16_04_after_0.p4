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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_2_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_5;
    //

    MRB_INIT_1( 3, 200, 131072, 14,  8)
    MRAC_INIT_1( 4, 200, 8192, 10,  8)
    T1_INIT_1( 5, 110, 262144)
    T2_INIT_HH_5( 6, 110, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 110)
        ABOVE_THRESHOLD_4() d_8_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_8_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_8_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_8_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_8_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_8_4;
    // 

    T2_INIT_HH_3(10, 110, 16384)
    T3_INIT_HH_5( 9, 110, 16384)
    T2_INIT_HH_5(11, 110, 16384)
    UM_INIT_3(12, 110, 11, 32768)
    T4_INIT_1(13, 220, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_8(32w0x30244f0b) d_14_sampling_hash_call;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        LPM_OPT_MRAC_2() d_14_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_14;
    // 

    T3_INIT_HH_5(16, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_3_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_1_1.apply(DSTIP, 1, 1, ig_md.d_1_est_1);
            update_1_2.apply(DSTIP, 1, 1, ig_md.d_1_est_2);
            update_1_3.apply(DSTIP, 1, 1, ig_md.d_1_est_3);
            d_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_2_above_threshold);
            update_1_4.apply(DSTIP, 1, ig_md.d_1_est_4);
            update_1_5.apply(DSTIP, 1, ig_md.d_1_est_5);
        //

        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T1_RUN_1_KEY_2( 5, SRCIP, SRCPORT) if (ig_md.d_5_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2( 6, SRCIP, SRCPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        d_8_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_8_index4_16);
        update_8_4.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index4_16, ig_md.d_8_res_hash[4:4], 1, ig_md.d_8_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(8)
        // 

        T2_RUN_AFTER_3_KEY_2(10, DSTIP, DSTPORT, 1)
        T3_RUN_AFTER_5_KEY_2( 9, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_2(11, DSTIP, DSTPORT, 1)
        // UnivMon for inst 12
            d_12_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_12_index3_16); 
            UM_RUN_END_3(12, ig_md.d_12_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(12) 
        //

        // HLL for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_32, ig_md.d_13_level);
            update_13.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_level);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
        update_14.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16);
        // 

        T3_RUN_AFTER_5_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
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