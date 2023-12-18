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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 262144)
    T1_INIT_4( 3, 100, 131072)
    T1_INIT_4( 4, 100, 524288)
    T1_INIT_5( 2, 100, 524288)
    MRB_INIT_1( 5, 100, 524288, 15, 16)
    MRB_INIT_1( 6, 100, 524288, 15, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_5;
    //

    T3_INIT_HH_2(15, 100, 16384)
    T3_INIT_HH_2(16, 100, 8192)
    T2_INIT_HH_2(18, 100, 8192)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_10_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_11_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(23, 100)
        ABOVE_THRESHOLD_2() d_23_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_23_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_23_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_23_2;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(24, 100)
        ABOVE_THRESHOLD_4() d_24_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_24_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_24_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_24_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_24_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_24_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_24_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_24_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_24_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(DSTIP, ig_md.d_23_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(DSTIP, ig_md.d_24_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_7_1.apply(DSTIP, 1, SIZE, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, SIZE, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, 1, ig_md.d_7_est_3);
            update_7_4.apply(DSTIP, 1, ig_md.d_7_est_4);
            update_7_5.apply(DSTIP, 1, ig_md.d_7_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(7)
        //

        T3_RUN_AFTER_2_KEY_1(15, DSTIP, SIZE)
        T3_RUN_AFTER_2_KEY_1(16, DSTIP, SIZE)
        T2_RUN_AFTER_2_KEY_1(18, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_3_KEY_1(8, DSTIP, 1)
        // 


        // apply O2
        T2_RUN_AFTER_3_KEY_1(10, DSTIP, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_1(11, DSTIP, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_23_res_hash_call.apply(DSTIP, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(DSTIP, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], 1, ig_md.d_23_est_1);
        d_23_index_hash_call_2.apply(DSTIP, ig_md.d_23_index2_16);
        update_23_2.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index2_16, ig_md.d_23_res_hash[2:2], 1, ig_md.d_23_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(23)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_24_res_hash_call.apply(DSTIP, ig_md.d_24_res_hash);
        d_24_tcam_lpm_2.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16_1024, ig_md.d_24_base_16_2048, ig_md.d_24_threshold);
        d_24_index_hash_call_1.apply(DSTIP, ig_md.d_24_index1_16);
        update_24_1.apply(ig_md.d_24_base_16_1024, ig_md.d_24_index1_16, ig_md.d_24_res_hash[1:1], 1, ig_md.d_24_est_1);
        d_24_index_hash_call_2.apply(DSTIP, ig_md.d_24_index2_16);
        update_24_2.apply(ig_md.d_24_base_16_2048, ig_md.d_24_index2_16, ig_md.d_24_res_hash[2:2], 1, ig_md.d_24_est_2);
        d_24_index_hash_call_3.apply(DSTIP, ig_md.d_24_index3_16);
        update_24_3.apply(ig_md.d_24_base_16_1024, ig_md.d_24_index3_16, ig_md.d_24_res_hash[3:3], 1, ig_md.d_24_est_3);
        d_24_index_hash_call_4.apply(DSTIP, ig_md.d_24_index4_16);
        update_24_4.apply(ig_md.d_24_base_16_1024, ig_md.d_24_index4_16, ig_md.d_24_res_hash[4:4], 1, ig_md.d_24_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(24)
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip); 
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