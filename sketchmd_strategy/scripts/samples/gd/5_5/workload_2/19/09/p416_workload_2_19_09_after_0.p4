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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    T1_INIT_3( 2, 110, 131072)
    T1_INIT_4( 1, 110, 524288)
    MRB_INIT_1( 3, 110, 262144, 14, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_9_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_9_hash_call;
        TCAM_LPM_HLLPCSA() d_9_tcam_lpm;
        GET_BITMASK() d_9_get_bitmask;
        T2_T5_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_4;
    //

    T2_INIT_HH_3(13, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_1;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_2;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_3;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_4;
    //

    T2_INIT_HH_4(11, 110, 16384)
    T2_INIT_HH_4(12, 110, 16384)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_6_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 110)
        ABOVE_THRESHOLD_5() d_18_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_18_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_18_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_18_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_18_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_18_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_18_4;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_18_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_18_5;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(19, 110)
        ABOVE_THRESHOLD_3() d_19_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_19_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_19_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_19_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_19_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_19_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_19_3;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_3_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_4_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_19_sampling_hash_16);

        //

        T1_RUN_3_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_9_level);
            d_9_get_bitmask.apply(ig_md.d_9_level, ig_md.d_9_bitmask);
            update_9_1.apply(SRCIP, SRCPORT, 1, ig_md.d_9_bitmask, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, SRCPORT, 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, SRCPORT, 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, SRCPORT, 1, ig_md.d_9_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(9)
        //

        T2_RUN_AFTER_3_KEY_2(13, SRCIP, SRCPORT, SIZE)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, SRCPORT, 1, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, SRCPORT, 1, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, SRCPORT, 1, ig_md.d_5_res_hash[3:3], 1, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, SRCPORT, 1, ig_md.d_5_res_hash[4:4], 1, ig_md.d_5_est_4);
            d_8_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_est_4, ig_md.d_8_above_threshold);
        //

        T2_RUN_AFTER_4_KEY_2(11, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_4_KEY_2(12, SRCIP, SRCPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(6, SRCIP, SRCPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(7, SRCIP, SRCPORT, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
        d_18_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_18_index3_16);
        update_18_3.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index3_16, ig_md.d_18_res_hash[3:3], SIZE, ig_md.d_18_est_3);
        d_18_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_18_index4_16);
        update_18_4.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index4_16, ig_md.d_18_res_hash[4:4], SIZE, ig_md.d_18_est_4);
        d_18_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_18_index5_16);
        update_18_5.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index5_16, ig_md.d_18_res_hash[5:5], SIZE, ig_md.d_18_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(18)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_19_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_19_res_hash);
        d_19_tcam_lpm_2.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16_1024, ig_md.d_19_base_16_2048, ig_md.d_19_threshold);
        d_19_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_19_index1_16);
        update_19_1.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index1_16, ig_md.d_19_res_hash[1:1], SIZE, ig_md.d_19_est_1);
        d_19_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_19_index2_16);
        update_19_2.apply(ig_md.d_19_base_16_1024, ig_md.d_19_index2_16, ig_md.d_19_res_hash[2:2], SIZE, ig_md.d_19_est_2);
        d_19_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_19_index3_16);
        update_19_3.apply(ig_md.d_19_base_16_1024, ig_md.d_19_index3_16, ig_md.d_19_res_hash[3:3], SIZE, ig_md.d_19_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(19)
        // 

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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