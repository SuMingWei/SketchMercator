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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(65536, 16, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 8192)
    T2_INIT_HH_5( 2, 100, 16384)
    T2_INIT_HH_2( 3, 100, 4096)
    MRAC_INIT_1( 4, 100, 32768, 11, 16)
    T3_INIT_HH_2( 5, 100, 8192)
    T2_INIT_HH_2( 7, 100, 8192)
    T3_INIT_HH_3( 6, 100, 8192)
    T1_INIT_3( 8, 200, 262144)
    MRAC_INIT_1( 9, 200, 16384, 11,  8)
    UM_INIT_4(10, 200, 11, 32768)
    T1_INIT_1(11, 110, 262144)
    UM_INIT_4(12, 110, 11, 32768)
    T1_INIT_2(13, 110, 524288)
    T1_INIT_4(14, 110, 262144)
    MRAC_INIT_1(15, 110, 16384, 11,  8)
    MRAC_INIT_1(16, 220, 16384, 11,  8)
    MRAC_INIT_1(17, 220, 32768, 11, 16)
    UM_INIT_5(18, 220, 11, 32768)
    T1_INIT_5(19, 221, 524288)
    T2_INIT_HH_1(20, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1_1.apply(SRCIP, ig_md.d_1_level);
        //

        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_2_KEY_1( 3, SRCIP, 1)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4_1.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T3_RUN_AFTER_2_KEY_1( 5, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_1( 7, DSTIP, 1)
        T3_RUN_AFTER_3_KEY_1( 6, DSTIP, 1)
        T1_RUN_3_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0) { /* process_new_flow() */ }
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
            update_9_1.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16); 
            d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16); 
            d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16); 
            UM_RUN_END_4(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(10) 
        //

        T1_RUN_1_KEY_2(11, SRCIP, SRCPORT)
        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_12_index3_16); 
            d_12_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_12_index4_16); 
            UM_RUN_END_4(12, ig_md.d_12_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(12) 
        //

        T1_RUN_2_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0) { /* process_new_flow() */ }
        // MRAC for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16);
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16);
            update_15_1.apply(ig_md.d_15_base_16, ig_md.d_15_index1_16);
        //

        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16_1.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        // MRAC for inst 17
            d_17_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_17_base_16);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index1_16);
            update_17_1.apply(ig_md.d_17_base_16, ig_md.d_17_index1_16);
        //

        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index3_16); 
            d_18_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index4_16); 
            d_18_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index5_16); 
            UM_RUN_END_5(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(18) 
        //

        T1_RUN_5_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_19_est1_1 == 0 || ig_md.d_19_est1_2 == 0 || ig_md.d_19_est1_3 == 0 || ig_md.d_19_est1_4 == 0 || ig_md.d_19_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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