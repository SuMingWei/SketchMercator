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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 24576)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_2_above_threshold;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_res_hash_call;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T3_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_4;
    //

    MRB_INIT_1( 3, 100, 131072, 14,  8)
    T3_INIT_HH_2( 4, 100, 16384)
    T2_INIT_HH_2( 6, 100, 16384)
    T3_INIT_HH_3( 5, 100, 4096)
    MRAC_INIT_1( 7, 100, 32768, 11, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_res_hash_call;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_2;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_3;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_4;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_5;
    //

    UM_INIT_2(10, 200, 11, 32768)
    T1_INIT_4(11, 110, 524288)
    UM_INIT_4(12, 110, 10, 16384)
    T4_INIT_1(13, 110, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_16_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_res_hash_call;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_2;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_3;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_4;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_5;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_18_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_2;
    //

    T3_INIT_HH_4(17, 110, 8192)
    UM_INIT_5(19, 110, 10, 16384)
    T1_INIT_1(20, 220, 262144)
    UM_INIT_3(21, 220, 10, 16384)
    T2_INIT_4(22, 221, 8192)
    MRAC_INIT_1(23, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_32);

            d_19_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_19_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
            update_2_1.apply(SRCIP, 1, ig_md.d_2_res_hash[1:1], 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_res_hash[2:2], 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, ig_md.d_2_res_hash[3:3], 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, ig_md.d_2_res_hash[4:4], ig_md.d_2_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(2)
        //

        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        T3_RUN_AFTER_2_KEY_1( 4, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_1( 6, DSTIP, SIZE)
        T3_RUN_AFTER_3_KEY_1( 5, DSTIP, SIZE)
        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash);
            update_9_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[1:1], SIZE, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[2:2], SIZE, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[3:3], ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[4:4], ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_9_res_hash[5:5], ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16); 
            UM_RUN_END_2(10, ig_md.d_10_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(10) 
        //

        T1_RUN_4_KEY_2(11, SRCIP, SRCPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0) { /* process_new_flow() */ }
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

        // HLL for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_32, ig_md.d_13_level);
            update_13.apply(DSTIP, DSTPORT, ig_md.d_13_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash);
            update_16_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[1:1], SIZE, ig_md.d_16_est_1);
            update_16_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[2:2], SIZE, ig_md.d_16_est_2);
            update_16_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[3:3], ig_md.d_16_est_3);
            update_16_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[4:4], ig_md.d_16_est_4);
            update_16_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[5:5], ig_md.d_16_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(16)
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_15_1.apply(DSTIP, DSTPORT, 1, SIZE, ig_md.d_15_est_1);
            update_15_2.apply(DSTIP, DSTPORT, 1, SIZE, ig_md.d_15_est_2);
            d_18_above_threshold.apply(ig_md.d_15_est_1, ig_md.d_15_est_2, ig_md.d_18_above_threshold);
        //

        T3_RUN_AFTER_4_KEY_2(17, DSTIP, DSTPORT, SIZE)
        // UnivMon for inst 19
            d_19_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_19_index3_16); 
            d_19_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_19_index4_16); 
            d_19_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_19_index5_16); 
            UM_RUN_END_5(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(19) 
        //

        T1_RUN_1_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT)
        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index3_16); 
            UM_RUN_END_3(21, ig_md.d_21_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(21) 
        //

        T2_RUN_4_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_16, ig_md.d_23_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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