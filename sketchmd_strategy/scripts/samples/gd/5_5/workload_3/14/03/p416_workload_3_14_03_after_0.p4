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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 524288)
    T4_INIT_1( 2, 100, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_sampling_hash_call;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_1;
        LPM_OPT_MRAC_2() d_3_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_3;
    // 

    MRB_INIT_1( 5, 200, 131072, 14,  8)
    T2_INIT_HH_2( 6, 110, 16384)
    UM_INIT_3( 8, 110, 10, 16384)
    UM_INIT_4( 7, 110, 10, 16384)
    T3_INIT_HH_2( 9, 110, 16384)
    T3_INIT_HH_5(10, 110, 4096)
    MRAC_INIT_1(11, 220, 32768, 11, 16)
    T1_INIT_1(13, 221, 524288)
    T1_INIT_3(12, 221, 262144)
    MRB_INIT_1(14, 221, 262144, 15,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_32);

            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_7_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_sampling_hash_16);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2.apply(DSTIP, ig_md.d_2_level);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_3_tcam_lpm_2.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16_1024, ig_md.d_3_base_16_2048);
        d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
        update_3.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index1_16);
        // 

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        T2_RUN_AFTER_2_KEY_2( 6, SRCIP, SRCPORT, 1)
        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_8_index3_16); 
            UM_RUN_END_3(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(8) 
        //

        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_7_index4_16); 
            UM_RUN_END_4(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(7) 
        //

        T3_RUN_AFTER_2_KEY_2( 9, DSTIP, DSTPORT, 1)
        T3_RUN_AFTER_5_KEY_2(10, DSTIP, DSTPORT, 1)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        T1_RUN_1_KEY_5(13, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T1_RUN_3_KEY_5(12, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0 || ig_md.d_12_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_32);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index1_16);
            update_14.apply(ig_md.d_14_base_32, ig_md.d_14_index1_16);
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
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