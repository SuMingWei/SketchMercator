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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 200, 131072)
    T1_INIT_3( 3, 200, 131072)
    T1_INIT_5( 2, 200, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_12_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_res_hash_call;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_12_1;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_12_2;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_12_3;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_11_above_threshold;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_13_above_threshold;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_2;
    //


    // apply O2
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_7_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_7_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_9_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_10_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_10_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(23, 200)
        ABOVE_THRESHOLD_4() d_23_above_threshold;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_23_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_23_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_23_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_23_index_hash_call_3;
        T3_T2_INDEX_UPDATE_32768() update_23_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_23_index_hash_call_4;
        T3_T2_INDEX_UPDATE_16384() update_23_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_2_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 2, SRCIP, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash);
            update_12_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_12_res_hash[1:1], 1, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_12_res_hash[2:2], ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_12_res_hash[3:3], ig_md.d_12_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(12)
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
            d_11_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_11_above_threshold);
            update_5_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
            d_13_above_threshold.apply(ig_md.d_5_est_2, ig_md.d_13_above_threshold);
        //


        // apply O2
        T2_RUN_AFTER_4_KEY_2(7, SRCIP, DSTIP, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_2(8, SRCIP, DSTIP, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_2(9, SRCIP, DSTIP, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(4, SRCIP, DSTIP, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_23_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], 1, ig_md.d_23_est_1);
        d_23_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_23_index2_16);
        update_23_2.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index2_16, ig_md.d_23_res_hash[2:2], 1, ig_md.d_23_est_2);
        d_23_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_23_index3_16);
        update_23_3.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index3_16, ig_md.d_23_res_hash[3:3], 1, ig_md.d_23_est_3);
        d_23_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_23_index4_16);
        update_23_4.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index4_16, ig_md.d_23_res_hash[4:4], 1, ig_md.d_23_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(23)
        // 

        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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