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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_4;
    //

    T2_INIT_5( 5, 100, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_2;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_3;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_4;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 200)
        ABOVE_THRESHOLD_4() d_10_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_10_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_10_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_10_4;
    // 

    UM_INIT_2( 9, 200, 11, 32768)
    T1_INIT_2(11, 110, 131072)
    T2_INIT_HH_1(14, 110, 8192)
    T2_INIT_HH_3(12, 110, 4096)
    T3_INIT_HH_4(13, 110, 4096)
    T1_INIT_4(15, 110, 524288)
    T5_INIT_1(16, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_18_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_3;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_4;
    //

    MRB_INIT_1(19, 220, 262144, 15,  8)
    MRAC_INIT_1(20, 220, 16384, 11,  8)
    T1_INIT_1(21, 221, 131072)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(22, 221)
        ABOVE_THRESHOLD_1() d_22_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_22_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_22_1;
    // 

    UM_INIT_4(23, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(SRCIP, SIZE, 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, SIZE, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, SIZE, ig_md.d_3_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(3)
        //

        T2_RUN_5_KEY_1( 5, DSTIP, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash);
            update_6_1.apply(DSTIP, 1, ig_md.d_6_res_hash[1:1], SIZE, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, 1, ig_md.d_6_res_hash[2:2], SIZE, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, 1, ig_md.d_6_res_hash[3:3], SIZE, ig_md.d_6_est_3);
            update_6_4.apply(DSTIP, 1, ig_md.d_6_res_hash[4:4], SIZE, ig_md.d_6_est_4);
            update_6_5.apply(DSTIP, 1, ig_md.d_6_res_hash[5:5], SIZE, ig_md.d_6_est_5);
            d_7_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_6_est_4, ig_md.d_6_est_5, ig_md.d_7_above_threshold);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], SIZE, ig_md.d_10_est_3);
        d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16);
        update_10_4.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index4_16, ig_md.d_10_res_hash[4:4], SIZE, ig_md.d_10_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(10)
        // 

        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16); 
            UM_RUN_END_2(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(9) 
        //

        T1_RUN_2_KEY_2(11, SRCIP, SRCPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2(14, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_3_KEY_2(12, SRCIP, SRCPORT, 1)
        T3_RUN_AFTER_4_KEY_2(13, SRCIP, SRCPORT, SIZE)
        T1_RUN_4_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0) { /* process_new_flow() */ }
        // PCSA for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_16_level);
            d_16_get_bitmask.apply(ig_md.d_16_level, ig_md.d_16_bitmask);
            update_16.apply(DSTIP, DSTPORT, ig_md.d_16_bitmask);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash);
            update_17_1.apply(DSTIP, DSTPORT, 1, ig_md.d_17_res_hash[1:1], SIZE, ig_md.d_17_est_1);
            update_17_2.apply(DSTIP, DSTPORT, 1, ig_md.d_17_res_hash[2:2], SIZE, ig_md.d_17_est_2);
            update_17_3.apply(DSTIP, DSTPORT, 1, ig_md.d_17_res_hash[3:3], SIZE, ig_md.d_17_est_3);
            update_17_4.apply(DSTIP, DSTPORT, 1, ig_md.d_17_res_hash[4:4], SIZE, ig_md.d_17_est_4);
            d_18_above_threshold.apply(ig_md.d_17_est_1, ig_md.d_17_est_2, ig_md.d_17_est_3, ig_md.d_17_est_4, ig_md.d_18_above_threshold);
        //

        // MRB for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_32);
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16);
            update_19.apply(ig_md.d_19_base_32, ig_md.d_19_index1_16);
        //

        // MRAC for inst 20
            d_20_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_20_base_16);
            d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
            update_20.apply(ig_md.d_20_base_16, ig_md.d_20_index1_16);
        //

        T1_RUN_1_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_res_hash);
        d_22_tcam_lpm_2.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16_1024, ig_md.d_22_base_16_2048, ig_md.d_22_threshold);
        d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16);
        update_22_1.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index1_16, ig_md.d_22_res_hash[1:1], SIZE, ig_md.d_22_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(22)
        // 

        // UnivMon for inst 23
            d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_res_hash); 
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16, ig_md.d_23_threshold); 
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16); 
            d_23_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index2_16); 
            d_23_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index3_16); 
            d_23_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index4_16); 
            UM_RUN_END_4(23, ig_md.d_23_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(23) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
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