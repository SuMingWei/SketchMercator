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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 8192)

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

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

    //

    T3_INIT_HH_2( 1, 100, 16384)
    MRAC_INIT_1( 2, 100, 16384, 11,  8)
    T3_INIT_HH_1( 3, 100, 8192)
    T1_INIT_5( 4, 200, 524288)
    UM_INIT_5( 5, 200, 11, 32768)
    T1_INIT_1( 6, 110, 524288)
    T1_INIT_1( 7, 110, 524288)
    T1_INIT_4( 8, 220, 262144)
    MRAC_INIT_1( 9, 220, 32768, 11, 16)
    T3_INIT_HH_4(10, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_sampling_hash_16);

        //

        T3_RUN_AFTER_2_KEY_1( 1, SRCIP, 1)
        // MRAC for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16);
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
            update_2_1.apply(ig_md.d_2_base_16, ig_md.d_2_index1_16);
        //

        T3_RUN_AFTER_1_KEY_1( 3, DSTIP, 1)
        T1_RUN_5_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 5
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_5_index2_16); 
            d_5_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_5_index3_16); 
            d_5_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_5_index4_16); 
            d_5_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_5_index5_16); 
            UM_RUN_END_5(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(5) 
        //

        T1_RUN_1_KEY_2( 6, SRCIP, SRCPORT) if (ig_md.d_6_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 7, DSTIP, DSTPORT) if (ig_md.d_7_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_index1_16);
            update_9_1.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        T3_RUN_AFTER_4_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
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