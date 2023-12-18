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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 131072)
    T2_INIT_HH_5( 2, 100, 4096)
    T3_INIT_HH_5( 3, 100, 4096)
    MRAC_INIT_1( 4, 100, 32768, 11, 16)
    T1_INIT_2( 5, 100, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_5;
    //

    MRAC_INIT_1( 9, 100, 8192, 10,  8)
    T1_INIT_3(10, 200, 262144)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(12, 200)
        ABOVE_THRESHOLD_5() d_12_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_12_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_12_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_12_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_12_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_12_5;
    // 

    MRB_INIT_1(13, 110, 262144, 15,  8)
    T3_INIT_HH_3(14, 110, 4096)
    T1_INIT_4(15, 110, 524288)
    T2_INIT_HH_4(16, 110, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 110)
        ABOVE_THRESHOLD_2() d_18_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_18_2;
    // 

    UM_INIT_5(19, 110, 10, 16384)
    T1_INIT_1(20, 220, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_22_above_threshold;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_21_1;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_21_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_21_3;
    //

    T1_INIT_3(23, 221, 262144)
    UM_INIT_4(24, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_19_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, SIZE)
        T3_RUN_AFTER_5_KEY_1( 3, SRCIP, 1)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T1_RUN_2_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_6_1.apply(DSTIP, 1, SIZE, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, 1, SIZE, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, 1, ig_md.d_6_est_3);
            update_6_4.apply(DSTIP, 1, ig_md.d_6_est_4);
            update_6_5.apply(DSTIP, 1, ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //

        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        T1_RUN_3_KEY_2(10, SRCIP, DSTIP) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], 1, ig_md.d_12_est_1);
        d_12_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_12_index2_16);
        update_12_2.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index2_16, ig_md.d_12_res_hash[2:2], 1, ig_md.d_12_est_2);
        d_12_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_12_index3_16);
        update_12_3.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index3_16, ig_md.d_12_res_hash[3:3], 1, ig_md.d_12_est_3);
        d_12_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_12_index4_16);
        update_12_4.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index4_16, ig_md.d_12_res_hash[4:4], 1, ig_md.d_12_est_4);
        d_12_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_12_index5_16);
        update_12_5.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index5_16, ig_md.d_12_res_hash[5:5], 1, ig_md.d_12_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(12)
        // 

        // MRB for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_32);
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_32, ig_md.d_13_index1_16);
        //

        T3_RUN_AFTER_3_KEY_2(14, SRCIP, SRCPORT, SIZE)
        T1_RUN_4_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_2(16, DSTIP, DSTPORT, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], 1, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], 1, ig_md.d_18_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(18)
        // 

        // UnivMon for inst 19
            d_19_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_19_index3_16); 
            d_19_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_19_index4_16); 
            d_19_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_19_index5_16); 
            UM_RUN_END_5(19, ig_md.d_19_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(19) 
        //

        T1_RUN_1_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_20_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash);
            update_21_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_21_res_hash[1:1], SIZE, ig_md.d_21_est_1);
            update_21_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_21_res_hash[2:2], SIZE, ig_md.d_21_est_2);
            d_22_above_threshold.apply(ig_md.d_21_est_1, ig_md.d_21_est_2, ig_md.d_22_above_threshold);
            update_21_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_21_est_3);
        //

        T1_RUN_3_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_23_est1_1 == 0 || ig_md.d_23_est1_2 == 0 || ig_md.d_23_est1_3 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 24
            d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_res_hash); 
            d_24_tcam_lpm.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16, ig_md.d_24_threshold); 
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16); 
            d_24_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index2_16); 
            d_24_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index3_16); 
            d_24_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index4_16); 
            UM_RUN_END_4(24, ig_md.d_24_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(24) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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