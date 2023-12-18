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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(8192, 13, 4096)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(5, 100)
        ABOVE_THRESHOLD_5() d_5_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_5_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_5_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_3;
        T3_T2_INDEX_UPDATE_32768() update_5_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_4;
        T3_T2_INDEX_UPDATE_16384() update_5_4;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_5_5;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_8(32w0x30244f0b) d_6_sampling_hash_call;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_6_index_hash_call_1;
        LPM_OPT_MRAC_2() d_6_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_6;
    // 

    MRAC_INIT_1( 8, 110, 32768, 11, 16)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(9, 110)
        ABOVE_THRESHOLD_1() d_9_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_9_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_9_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);

        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash);
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048, ig_md.d_5_threshold);
        d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
        update_5_1.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index1_16, ig_md.d_5_res_hash[1:1], SIZE, ig_md.d_5_est_1);
        d_5_index_hash_call_2.apply(SRCIP, ig_md.d_5_index2_16);
        update_5_2.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index2_16, ig_md.d_5_res_hash[2:2], SIZE, ig_md.d_5_est_2);
        d_5_index_hash_call_3.apply(SRCIP, ig_md.d_5_index3_16);
        update_5_3.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index3_16, ig_md.d_5_res_hash[3:3], SIZE, ig_md.d_5_est_3);
        d_5_index_hash_call_4.apply(SRCIP, ig_md.d_5_index4_16);
        update_5_4.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index4_16, ig_md.d_5_res_hash[4:4], SIZE, ig_md.d_5_est_4);
        d_5_index_hash_call_5.apply(SRCIP, ig_md.d_5_index5_16);
        update_5_5.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index5_16, ig_md.d_5_res_hash[5:5], SIZE, ig_md.d_5_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(5)
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048);
        d_6_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_6_index1_16);
        update_6.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index1_16);
        // 

        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_9_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_res_hash);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048, ig_md.d_9_threshold);
        d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16);
        update_9_1.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index1_16, ig_md.d_9_res_hash[1:1], SIZE, ig_md.d_9_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(9)
        // 

        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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