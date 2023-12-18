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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_1_1;
    // 

    T1_INIT_1( 3, 220, 262144)
    T1_INIT_4( 2, 220, 262144)
    MRB_INIT_1( 5, 220, 262144, 14, 16)
    MRB_INIT_1( 6, 220, 262144, 15,  8)
    T2_INIT_HH_1(14, 220, 16384)
    T2_INIT_HH_1(15, 220, 8192)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_10_4;
    //


    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_9_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_9_above_threshold;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_13_above_threshold;
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_res_hash_call;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_1;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_2;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_3;
        T3_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_4;
        T3_KEY_UPDATE_220_8192(32w0x30243f0b) update_13_5;
    //

    T3_INIT_HH_4(12, 220, 16384)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(23, 220)
        ABOVE_THRESHOLD_5() d_23_above_threshold;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_23_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_23_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_23_2;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_23_index_hash_call_3;
        T3_T2_INDEX_UPDATE_32768() update_23_3;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_23_index_hash_call_4;
        T3_T2_INDEX_UPDATE_16384() update_23_4;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_23_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_23_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_5_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_sampling_hash_16);

        //


        // apply O2
        T1_RUN_1_KEY_4(1, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_1_KEY_4( 3, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_4( 2, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        T2_RUN_AFTER_1_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_10_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_10_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(10)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_4(9, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_res_hash);
            update_13_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
            update_13_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_res_hash[2:2], SIZE, ig_md.d_13_est_2);
            update_13_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_res_hash[3:3], SIZE, ig_md.d_13_est_3);
            update_13_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_res_hash[4:4], ig_md.d_13_est_4);
            update_13_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_res_hash[5:5], ig_md.d_13_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(13)
        //

        T3_RUN_AFTER_4_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_4(11, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], SIZE, ig_md.d_23_est_1);
        d_23_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index2_16);
        update_23_2.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index2_16, ig_md.d_23_res_hash[2:2], SIZE, ig_md.d_23_est_2);
        d_23_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index3_16);
        update_23_3.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index3_16, ig_md.d_23_res_hash[3:3], SIZE, ig_md.d_23_est_3);
        d_23_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index4_16);
        update_23_4.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index4_16, ig_md.d_23_res_hash[4:4], SIZE, ig_md.d_23_est_4);
        d_23_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_23_index5_16);
        update_23_5.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index5_16, ig_md.d_23_res_hash[5:5], SIZE, ig_md.d_23_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(23)
        // 

        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
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