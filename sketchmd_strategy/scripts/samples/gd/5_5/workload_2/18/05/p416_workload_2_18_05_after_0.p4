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

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

    //

    T1_INIT_1( 3, 100, 131072)
    T1_INIT_2( 1, 100, 131072)
    T1_INIT_3( 4, 100, 524288)
    T1_INIT_5( 2, 100, 131072)
    MRB_INIT_1( 5, 100, 131072, 14,  8)
    T2_INIT_HH_3( 9, 100, 16384)
    T2_INIT_HH_3(11, 100, 16384)
    T2_INIT_HH_3(12, 100, 4096)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_6_above_threshold;
    // 

    T2_INIT_HH_4( 7, 100, 4096)
    T2_INIT_HH_4(10, 100, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(17, 100)
        ABOVE_THRESHOLD_3() d_17_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_17_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_17_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_17_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_17_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_17_3;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 100)
        ABOVE_THRESHOLD_2() d_18_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_18_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_18_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_18_2;
    // 

    UM_INIT_1(16, 100, 10, 16384)
    UM_INIT_4(15, 100, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(DSTIP, ig_md.d_18_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, ig_md.d_16_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, ig_md.d_15_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        T2_RUN_AFTER_3_KEY_1( 9, DSTIP, SIZE)
        T2_RUN_AFTER_3_KEY_1(11, DSTIP, SIZE)
        T2_RUN_AFTER_3_KEY_1(12, DSTIP, SIZE)

        // apply O2
        T2_RUN_AFTER_4_KEY_1(6, DSTIP, 1)
        // 

        T2_RUN_AFTER_4_KEY_1( 7, DSTIP, 1)
        T2_RUN_AFTER_4_KEY_1(10, DSTIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_17_res_hash_call.apply(DSTIP, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(DSTIP, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], SIZE, ig_md.d_17_est_1);
        d_17_index_hash_call_2.apply(DSTIP, ig_md.d_17_index2_16);
        update_17_2.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index2_16, ig_md.d_17_res_hash[2:2], SIZE, ig_md.d_17_est_2);
        d_17_index_hash_call_3.apply(DSTIP, ig_md.d_17_index3_16);
        update_17_3.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index3_16, ig_md.d_17_res_hash[3:3], SIZE, ig_md.d_17_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(17)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(DSTIP, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(DSTIP, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(DSTIP, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_1024, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(18)
        // 

        // UnivMon for inst 16
            d_16_res_hash_call.apply(DSTIP, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(DSTIP, ig_md.d_16_index1_16); 
            UM_RUN_END_1(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(16) 
        //

        // UnivMon for inst 15
            d_15_res_hash_call.apply(DSTIP, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(DSTIP, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(DSTIP, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(DSTIP, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(DSTIP, ig_md.d_15_index4_16); 
            UM_RUN_END_4(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(15) 
        //

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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