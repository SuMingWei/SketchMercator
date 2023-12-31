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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 24576)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    UM_INIT_1( 2, 100, 10, 16384)
    UM_INIT_4( 1, 100, 11, 32768)
    T1_INIT_5( 3, 100, 524288)
    T2_INIT_HH_3( 4, 100, 4096)
    T2_INIT_HH_3( 5, 100, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 100)
        ABOVE_THRESHOLD_4() d_8_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_8_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_8_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_8_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_8_4;
    // 

    UM_INIT_1( 7, 100, 10, 16384)
    T2_INIT_HH_1( 9, 200, 4096)
    MRAC_INIT_1(10, 200, 32768, 11, 16)
    T2_INIT_HH_4(12, 110, 8192)
    T2_INIT_HH_5(11, 110, 16384)
    T1_INIT_3(13, 110, 524288)
    UM_INIT_3(14, 110, 11, 32768)
    MRAC_INIT_1(15, 220, 16384, 10, 16)

    // apply O2
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_16_1;
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_16_2;
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_16_3;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_19_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_18_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_18_2;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(21, 221)
        ABOVE_THRESHOLD_4() d_21_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_21_1;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_21_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_21_2;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_21_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_21_3;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_21_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_21_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            UM_RUN_END_1(2, ig_md.d_2_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(2) 
        //

        // UnivMon for inst 1
            d_1_res_hash_call.apply(SRCIP, ig_md.d_1_res_hash); 
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16, ig_md.d_1_threshold); 
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16); 
            d_1_index_hash_call_2.apply(SRCIP, ig_md.d_1_index2_16); 
            d_1_index_hash_call_3.apply(SRCIP, ig_md.d_1_index3_16); 
            d_1_index_hash_call_4.apply(SRCIP, ig_md.d_1_index4_16); 
            UM_RUN_END_4(1, ig_md.d_1_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(1) 
        //

        T1_RUN_5_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_1( 4, DSTIP, 1)
        T2_RUN_AFTER_3_KEY_1( 5, DSTIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(DSTIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(DSTIP, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        d_8_index_hash_call_4.apply(DSTIP, ig_md.d_8_index4_16);
        update_8_4.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index4_16, ig_md.d_8_res_hash[4:4], 1, ig_md.d_8_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(8)
        // 

        // UnivMon for inst 7
            d_7_res_hash_call.apply(DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16); 
            UM_RUN_END_1(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(7) 
        //

        T2_RUN_AFTER_1_KEY_2( 9, SRCIP, DSTIP, 1)
        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T2_RUN_AFTER_4_KEY_2(12, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_5_KEY_2(11, SRCIP, SRCPORT, 1)
        T1_RUN_3_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 14
            d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_14_index2_16); 
            d_14_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_14_index3_16); 
            UM_RUN_END_3(14, ig_md.d_14_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(14) 
        //

        // MRAC for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16);
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_16, ig_md.d_15_index1_16);
        //


        // apply O2
        T1_RUN_3_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0) { /* process_new_flow() */ }
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_18_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_18_est_1);
            update_18_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_18_est_2);
            d_19_above_threshold.apply(ig_md.d_18_est_1, ig_md.d_18_est_2, ig_md.d_19_above_threshold);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], 1, ig_md.d_21_est_1);
        d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index2_16);
        update_21_2.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index2_16, ig_md.d_21_res_hash[2:2], 1, ig_md.d_21_est_2);
        d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index3_16);
        update_21_3.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index3_16, ig_md.d_21_res_hash[3:3], 1, ig_md.d_21_est_3);
        d_21_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index4_16);
        update_21_4.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index4_16, ig_md.d_21_res_hash[4:4], 1, ig_md.d_21_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(21)
        // 

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_1_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_1_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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