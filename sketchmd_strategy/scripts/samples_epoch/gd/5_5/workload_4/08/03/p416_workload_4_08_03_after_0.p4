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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //

    T2_INIT_5( 1, 100, 16384)
    T1_INIT_1( 2, 100, 524288)
    UM_INIT_5( 3, 100, 11, 32768)
    T2_INIT_HH_2( 4, 200, 8192)
    T2_INIT_HH_5( 5, 110, 4096)
    UM_INIT_5( 6, 110, 11, 32768)
    T2_INIT_3( 7, 220, 4096)
    UM_INIT_5( 8, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_sampling_hash_16);

        //

        T2_RUN_5_KEY_1( 1, SRCIP, 1)
        T1_RUN_1_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 3
            d_3_res_hash_call.apply(DSTIP, ig_md.d_3_res_hash); 
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16, ig_md.d_3_threshold); 
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16); 
            d_3_index_hash_call_2.apply(DSTIP, ig_md.d_3_index2_16); 
            d_3_index_hash_call_3.apply(DSTIP, ig_md.d_3_index3_16); 
            d_3_index_hash_call_4.apply(DSTIP, ig_md.d_3_index4_16); 
            d_3_index_hash_call_5.apply(DSTIP, ig_md.d_3_index5_16); 
            UM_RUN_END_5(3, ig_md.d_3_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(3) 
        //

        T2_RUN_AFTER_2_KEY_2( 4, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2( 5, SRCIP, SRCPORT, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_6_index3_16); 
            d_6_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_6_index4_16); 
            d_6_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_6_index5_16); 
            UM_RUN_END_5(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(6) 
        //

        T2_RUN_3_KEY_4( 7, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index3_16); 
            d_8_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index4_16); 
            d_8_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index5_16); 
            UM_RUN_END_5(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(8) 
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
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