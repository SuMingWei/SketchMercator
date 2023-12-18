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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 32768)
    T3_INIT_HH_1( 3, 100, 8192)
    T3_INIT_HH_4( 2, 100, 16384)
    MRAC_INIT_1( 4, 100, 32768, 11, 16)
    T2_INIT_3( 5, 100, 8192)
    UM_INIT_3( 6, 100, 10, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_hash_call;
        TCAM_LPM_HLLPCSA() d_8_tcam_lpm;
        GET_BITMASK() d_8_get_bitmask;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_res_hash_call;
        T3_T5_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_1;
        T3_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_2;
    //

    T2_INIT_HH_2( 9, 200, 4096)
    T1_INIT_1(10, 110, 524288)
    UM_INIT_3(11, 110, 10, 16384)
    UM_INIT_4(12, 110, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_14_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(16, 110)
        ABOVE_THRESHOLD_2() d_16_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_16_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_16_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_16_2;
    // 

    T1_INIT_1(17, 220, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_19_above_threshold;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_1;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_2;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_3;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_5;
    //

    T4_INIT_1(20, 221, 16384)
    T3_INIT_HH_4(23, 221, 16384)

    // apply O2
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_21_1;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_21_2;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_21_3;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_21_4;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_21_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_21_above_threshold;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_sampling_hash_32);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //

        T3_RUN_AFTER_1_KEY_1( 3, SRCIP, SIZE)
        T3_RUN_AFTER_4_KEY_1( 2, SRCIP, 1)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T2_RUN_3_KEY_1( 5, DSTIP, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(DSTIP, ig_md.d_6_index3_16); 
            UM_RUN_END_3(6, ig_md.d_6_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(6) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_8_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash);
            update_8_1.apply(SRCIP, DSTIP, 1, ig_md.d_8_res_hash[1:1], ig_md.d_8_bitmask, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, ig_md.d_8_res_hash[2:2], ig_md.d_8_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(8)
        //

        T2_RUN_AFTER_2_KEY_2( 9, SRCIP, DSTIP, 1)
        T1_RUN_1_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_11_index3_16); 
            UM_RUN_END_3(11, ig_md.d_11_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(11) 
        //

        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_12_index3_16); 
            d_12_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_12_index4_16); 
            UM_RUN_END_4(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(12) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_14_1.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_14_est_1);
            update_14_2.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_14_est_2);
            update_14_3.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_14_est_3);
            update_14_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_14_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(14)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash);
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048, ig_md.d_16_threshold);
        d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
        update_16_1.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16, ig_md.d_16_res_hash[1:1], SIZE, ig_md.d_16_est_1);
        d_16_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_16_index2_16);
        update_16_2.apply(ig_md.d_16_base_16_1024, ig_md.d_16_index2_16, ig_md.d_16_res_hash[2:2], SIZE, ig_md.d_16_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(16)
        // 

        T1_RUN_1_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_res_hash);
            update_18_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
            update_18_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
            update_18_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_res_hash[3:3], SIZE, ig_md.d_18_est_3);
            update_18_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_res_hash[4:4], SIZE, ig_md.d_18_est_4);
            d_19_above_threshold.apply(ig_md.d_18_est_1, ig_md.d_18_est_2, ig_md.d_18_est_3, ig_md.d_18_est_4, ig_md.d_19_above_threshold);
            update_18_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_5);
        //

        // HLL for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_20_level);
            update_20.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_level);
        //

        T3_RUN_AFTER_4_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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