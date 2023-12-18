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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 262144, 15,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_res_hash_call;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_5;
    //

    UM_INIT_1( 4, 100, 11, 32768)
    T1_INIT_4( 5, 200, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_7_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_hash_call;
        TCAM_LPM_HLLPCSA() d_7_tcam_lpm;
        GET_BITMASK() d_7_get_bitmask;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_res_hash_call;
        T3_T5_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_1;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_2;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_10_hash_call;
        TCAM_LPM_HLLPCSA() d_10_tcam_lpm;
        GET_BITMASK() d_10_get_bitmask;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_4;
    //

    T2_INIT_HH_5( 9, 110, 16384)
    T1_INIT_5(11, 110, 262144)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_5() d_13_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_13_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_13_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_13_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_13_4;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_13_5;
    // 

    MRAC_INIT_1(14, 220, 32768, 11, 16)
    UM_INIT_5(15, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_3_res_hash_call.apply(DSTIP, ig_md.d_3_res_hash);
            update_3_1.apply(DSTIP, SIZE, ig_md.d_3_res_hash[1:1], SIZE, ig_md.d_3_est_1);
            update_3_2.apply(DSTIP, SIZE, ig_md.d_3_res_hash[2:2], SIZE, ig_md.d_3_est_2);
            update_3_3.apply(DSTIP, SIZE, ig_md.d_3_res_hash[3:3], SIZE, ig_md.d_3_est_3);
            update_3_4.apply(DSTIP, SIZE, ig_md.d_3_res_hash[4:4], ig_md.d_3_est_4);
            update_3_5.apply(DSTIP, SIZE, ig_md.d_3_res_hash[5:5], ig_md.d_3_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(3)
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            UM_RUN_END_1(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(4) 
        //

        T1_RUN_4_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_7_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_7_level);
            d_7_get_bitmask.apply(ig_md.d_7_level, ig_md.d_7_bitmask);
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash);
            update_7_1.apply(SRCIP, DSTIP, 1, ig_md.d_7_res_hash[1:1], ig_md.d_7_bitmask, ig_md.d_7_est_1);
            update_7_2.apply(SRCIP, DSTIP, 1, ig_md.d_7_res_hash[2:2], ig_md.d_7_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(7)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_10_level);
            d_10_get_bitmask.apply(ig_md.d_10_level, ig_md.d_10_bitmask);
            update_10_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_bitmask, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_10_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(10)
        //

        T2_RUN_AFTER_5_KEY_2( 9, SRCIP, SRCPORT, 1)
        T1_RUN_5_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0 || ig_md.d_11_est1_5 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], SIZE, ig_md.d_13_est_2);
        d_13_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_13_index3_16);
        update_13_3.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index3_16, ig_md.d_13_res_hash[3:3], SIZE, ig_md.d_13_est_3);
        d_13_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_13_index4_16);
        update_13_4.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index4_16, ig_md.d_13_res_hash[4:4], SIZE, ig_md.d_13_est_4);
        d_13_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_13_index5_16);
        update_13_5.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index5_16, ig_md.d_13_res_hash[5:5], SIZE, ig_md.d_13_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(13)
        // 

        // MRAC for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
            update_14.apply(ig_md.d_14_base_16, ig_md.d_14_index1_16);
        //

        // UnivMon for inst 15
            d_15_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_index4_16); 
            d_15_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_15_index5_16); 
            UM_RUN_END_5(15, ig_md.d_15_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(15) 
        //

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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