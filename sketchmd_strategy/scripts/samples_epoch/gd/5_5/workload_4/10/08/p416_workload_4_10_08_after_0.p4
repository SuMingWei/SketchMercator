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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(2, 100)
        ABOVE_THRESHOLD_3() d_2_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_2_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_2_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_2_3;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_4_res_hash_call;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_2;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_3;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_4;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_5;
    //

    MRAC_INIT_1( 5, 200, 32768, 11, 16)
    T1_INIT_3( 6, 110, 524288)
    MRAC_INIT_1( 7, 110, 32768, 11, 16)
    MRAC_INIT_1( 8, 110, 32768, 11, 16)
    T2_INIT_HH_1( 9, 220, 4096)
    T1_INIT_1(10, 221, 131072)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_8_sampling_hash_16);

        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_2_res_hash_call.apply(DSTIP, ig_md.d_2_res_hash);
        d_2_tcam_lpm_2.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16_1024, ig_md.d_2_base_16_2048, ig_md.d_2_threshold);
        d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
        update_2_1.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index1_16, ig_md.d_2_res_hash[0:0], SIZE, ig_md.d_2_est_1);
        d_2_index_hash_call_2.apply(DSTIP, ig_md.d_2_index2_16);
        update_2_2.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index2_16, ig_md.d_2_res_hash[1:1], SIZE, ig_md.d_2_est_2);
        d_2_index_hash_call_3.apply(DSTIP, ig_md.d_2_index3_16);
        update_2_3.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index3_16, ig_md.d_2_res_hash[2:2], SIZE, ig_md.d_2_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(2)
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_4_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_res_hash);
            update_4_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_res_hash[0:0], SIZE, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_res_hash[1:1], SIZE, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_res_hash[2:2], SIZE, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_res_hash[3:3], ig_md.d_4_est_4);
            update_4_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_res_hash[4:4], ig_md.d_4_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(4)
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16);
            update_5_1.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        T1_RUN_3_KEY_2( 6, SRCIP, SRCPORT) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0) { /* process_new_flow() */ }
        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_7_index1_16);
            update_7_1.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_8_index1_16);
            update_8_1.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //

        T2_RUN_AFTER_1_KEY_4( 9, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_1_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
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