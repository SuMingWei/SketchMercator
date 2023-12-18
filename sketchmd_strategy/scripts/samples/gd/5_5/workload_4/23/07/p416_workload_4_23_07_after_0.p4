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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

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

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_4;
    //

    UM_INIT_4( 4, 100, 10, 16384)
    MRAC_INIT_1( 5, 100, 8192, 10,  8)
    T1_INIT_5( 6, 200, 262144)
    T2_INIT_HH_1( 8, 200, 8192)
    T3_INIT_HH_4( 7, 200, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 200)
        ABOVE_THRESHOLD_3() d_10_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_10_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_10_3;
    // 

    T4_INIT_1(11, 110, 32768)
    MRAC_INIT_1(12, 110, 16384, 10, 16)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_1() d_13_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_13_1;
    // 

    UM_INIT_4(14, 110, 11, 32768)
    T1_INIT_5(16, 220, 131072)
    MRB_INIT_1(17, 220, 131072, 14,  8)

    // apply O2
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_18_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_18_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_18_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_18_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_18_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_18_above_threshold;
    // 

    MRAC_INIT_1(20, 220, 16384, 10, 16)
    MRB_INIT_1(21, 221, 524288, 15, 16)

    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_22_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_22_above_threshold;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(SRCIP, 1, SIZE, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, 1, SIZE, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, 1, ig_md.d_3_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(3)
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16); 
            UM_RUN_END_4(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(4) 
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        T1_RUN_5_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0 || ig_md.d_6_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2( 8, SRCIP, DSTIP, SIZE)
        T3_RUN_AFTER_4_KEY_2( 7, SRCIP, DSTIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_1024, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_1024, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], SIZE, ig_md.d_10_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(10)
        // 

        // HLL for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_32, ig_md.d_11_level);
            update_11.apply(SRCIP, SRCPORT, ig_md.d_11_level);
        //

        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(13)
        // 

        // UnivMon for inst 14
            d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_14_index2_16); 
            d_14_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_14_index3_16); 
            d_14_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_14_index4_16); 
            UM_RUN_END_4(14, ig_md.d_14_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(14) 
        //

        T1_RUN_5_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0 || ig_md.d_16_est1_4 == 0 || ig_md.d_16_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_32);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_32, ig_md.d_17_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 

        // MRAC for inst 20
            d_20_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_20_base_16);
            d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
            update_20.apply(ig_md.d_20_base_16, ig_md.d_20_index1_16);
        //

        // MRB for inst 21
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_32);
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
            update_21.apply(ig_md.d_21_base_32, ig_md.d_21_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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