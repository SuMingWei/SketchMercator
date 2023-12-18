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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 524288)
    T2_INIT_HH_5( 2, 100, 8192)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
    //

    MRAC_INIT_1( 7, 100, 8192, 10,  8)
    T1_INIT_4( 8, 200, 131072)
    T3_INIT_HH_4(11, 200, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_3;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_4;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_5;
    //

    MRB_INIT_1(13, 110, 524288, 15, 16)
    T2_INIT_HH_3(14, 110, 16384)
    T2_INIT_HH_5(15, 110, 16384)
    MRAC_INIT_1(16, 110, 16384, 10, 16)
    UM_INIT_3(17, 110, 11, 32768)
    T2_INIT_HH_5(18, 220, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 220)
        ABOVE_THRESHOLD_3() d_20_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_20_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_20_2;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_20_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_20_3;
    // 

    T1_INIT_1(21, 221, 131072)
    MRB_INIT_1(22, 221, 262144, 15,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(DSTIP, 1, SIZE, ig_md.d_3_est_1);
            update_3_2.apply(DSTIP, 1, ig_md.d_3_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(3)
        //

        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        T1_RUN_4_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_2(11, SRCIP, DSTIP, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_9_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_9_est_5);
            d_10_above_threshold.apply(ig_md.d_9_est_1, ig_md.d_9_est_2, ig_md.d_9_est_3, ig_md.d_9_est_4, ig_md.d_9_est_5, ig_md.d_10_above_threshold);
        //

        // MRB for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_32);
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_32, ig_md.d_13_index1_16);
        //

        T2_RUN_AFTER_3_KEY_2(14, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_5_KEY_2(15, SRCIP, SRCPORT, 1)
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        // UnivMon for inst 17
            d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_17_index3_16); 
            UM_RUN_END_3(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(17) 
        //

        T2_RUN_AFTER_5_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], SIZE, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_1024, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], SIZE, ig_md.d_20_est_2);
        d_20_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index3_16);
        update_20_3.apply(ig_md.d_20_base_16_1024, ig_md.d_20_index3_16, ig_md.d_20_res_hash[3:3], SIZE, ig_md.d_20_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(20)
        // 

        T1_RUN_1_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0) { /* process_new_flow() */ }
        // MRB for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_32);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_32, ig_md.d_22_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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