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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 200, 524288)
    MRB_INIT_1( 2, 200, 262144, 15,  8)
    T3_INIT_HH_2( 6, 200, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_2;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_5;
    //

    T2_INIT_HH_4( 4, 200, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 200)
        ABOVE_THRESHOLD_5() d_10_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_10_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_10_3;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_10_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_10_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_10_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_10_5;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(9, 200)
        ABOVE_THRESHOLD_1() d_9_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_9_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_9_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_2_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

        //

        T1_RUN_5_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //

        T3_RUN_AFTER_2_KEY_2( 6, SRCIP, DSTIP, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_5_1.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, DSTIP, 1, ig_md.d_5_est_4);
            update_5_5.apply(SRCIP, DSTIP, 1, ig_md.d_5_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(5)
        //

        T2_RUN_AFTER_4_KEY_2( 4, SRCIP, DSTIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_1024, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], 1, ig_md.d_10_est_3);
        d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16);
        update_10_4.apply(ig_md.d_10_base_16_1024, ig_md.d_10_index4_16, ig_md.d_10_res_hash[4:4], 1, ig_md.d_10_est_4);
        d_10_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_10_index5_16);
        update_10_5.apply(ig_md.d_10_base_16_1024, ig_md.d_10_index5_16, ig_md.d_10_res_hash[5:5], 1, ig_md.d_10_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(10)
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048, ig_md.d_9_threshold);
        d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
        update_9_1.apply(ig_md.d_9_base_16_2048, ig_md.d_9_index1_16, ig_md.d_9_res_hash[1:1], SIZE, ig_md.d_9_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(9)
        // 

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
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