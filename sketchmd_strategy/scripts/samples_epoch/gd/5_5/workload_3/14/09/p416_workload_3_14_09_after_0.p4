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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 12288)

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

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 262144)
    T4_INIT_1( 2, 100, 16384)
    UM_INIT_4( 3, 100, 11, 32768)
    T2_INIT_3( 4, 100, 8192)
    T2_INIT_HH_4( 5, 100, 16384)
    T1_INIT_2( 6, 200, 524288)
    T5_INIT_1( 7, 200, 4096)
    T3_INIT_HH_4( 8, 200, 8192)
    MRAC_INIT_1( 9, 200, 16384, 11,  8)
    T2_INIT_1(10, 110, 8192)
    T2_INIT_4(11, 110, 16384)
    T3_INIT_HH_1(12, 110, 4096)
    UM_INIT_5(13, 110, 11, 32768)
    UM_INIT_3(14, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);

            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2_1.apply(SRCIP, ig_md.d_2_level);
        //

        // UnivMon for inst 3
            d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash); 
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16, ig_md.d_3_threshold); 
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16); 
            d_3_index_hash_call_2.apply(SRCIP, ig_md.d_3_index2_16); 
            d_3_index_hash_call_3.apply(SRCIP, ig_md.d_3_index3_16); 
            d_3_index_hash_call_4.apply(SRCIP, ig_md.d_3_index4_16); 
            UM_RUN_END_4(3, ig_md.d_3_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(3) 
        //

        T2_RUN_3_KEY_1( 4, DSTIP, 1)
        T2_RUN_AFTER_4_KEY_1( 5, DSTIP, 1)
        T1_RUN_2_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0) { /* process_new_flow() */ }
        // PCSA for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            d_7_get_bitmask.apply(ig_md.d_7_level, ig_md.d_7_bitmask);
            update_7_1.apply(SRCIP, DSTIP, ig_md.d_7_bitmask);
        //

        T3_RUN_AFTER_4_KEY_2( 8, SRCIP, DSTIP, 1)
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
            update_9_1.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        T2_RUN_1_KEY_2(10, SRCIP, SRCPORT, 1)
        T2_RUN_4_KEY_2(11, SRCIP, SRCPORT, 1)
        T3_RUN_AFTER_1_KEY_2(12, SRCIP, SRCPORT, 1)
        // UnivMon for inst 13
            d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_13_index3_16); 
            d_13_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_13_index4_16); 
            d_13_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_13_index5_16); 
            UM_RUN_END_5(13, ig_md.d_13_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(13) 
        //

        // UnivMon for inst 14
            d_14_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index2_16); 
            d_14_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index3_16); 
            UM_RUN_END_3(14, ig_md.d_14_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(14) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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