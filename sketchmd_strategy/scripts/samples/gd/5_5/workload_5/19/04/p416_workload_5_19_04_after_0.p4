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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T3_INIT_HH_1( 1, 100, 4096)
    T2_INIT_HH_2( 2, 100, 16384)
    T1_INIT_2( 3, 100, 524288)
    UM_INIT_2( 4, 100, 10, 16384)
    UM_INIT_2( 5, 100, 10, 16384)
    T2_INIT_HH_2( 7, 200, 8192)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_9_5;
    //

    T2_INIT_HH_4( 8, 200, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_sampling_hash_call;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        LPM_OPT_MRAC_2() d_10_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_10;
    // 

    T2_INIT_HH_1(12, 110, 8192)
    T1_INIT_1(13, 110, 262144)
    T5_INIT_1(14, 110, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(16, 220)
        ABOVE_THRESHOLD_4() d_16_above_threshold;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_16_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_16_1;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_16_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_16_2;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_16_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_16_3;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_16_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_16_4;
    // 

    T2_INIT_HH_5(17, 221, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(18, 221)
        ABOVE_THRESHOLD_1() d_18_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

        //

        T3_RUN_AFTER_1_KEY_1( 1, SRCIP, SIZE)
        T2_RUN_AFTER_2_KEY_1( 2, SRCIP, 1)
        T1_RUN_2_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16); 
            UM_RUN_END_2(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(4) 
        //

        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, ig_md.d_5_index2_16); 
            UM_RUN_END_2(5, ig_md.d_5_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(5) 
        //

        T2_RUN_AFTER_2_KEY_2( 7, SRCIP, DSTIP, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_9_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //

        T2_RUN_AFTER_4_KEY_2( 8, SRCIP, DSTIP, SIZE)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048);
        d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
        update_10.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16);
        // 

        T2_RUN_AFTER_1_KEY_2(12, SRCIP, SRCPORT, SIZE)
        T1_RUN_1_KEY_2(13, DSTIP, DSTPORT)
        // PCSA for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_32, ig_md.d_14_level);
            d_14_get_bitmask.apply(ig_md.d_14_level, ig_md.d_14_bitmask);
            update_14.apply(DSTIP, DSTPORT, ig_md.d_14_bitmask);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_res_hash);
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048, ig_md.d_16_threshold);
        d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
        update_16_1.apply(ig_md.d_16_base_16_1024, ig_md.d_16_index1_16, ig_md.d_16_res_hash[1:1], 1, ig_md.d_16_est_1);
        d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index2_16);
        update_16_2.apply(ig_md.d_16_base_16_1024, ig_md.d_16_index2_16, ig_md.d_16_res_hash[2:2], 1, ig_md.d_16_est_2);
        d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index3_16);
        update_16_3.apply(ig_md.d_16_base_16_1024, ig_md.d_16_index3_16, ig_md.d_16_res_hash[3:3], 1, ig_md.d_16_est_3);
        d_16_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index4_16);
        update_16_4.apply(ig_md.d_16_base_16_1024, ig_md.d_16_index4_16, ig_md.d_16_res_hash[4:4], 1, ig_md.d_16_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(16)
        // 

        T2_RUN_AFTER_5_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(18)
        // 

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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