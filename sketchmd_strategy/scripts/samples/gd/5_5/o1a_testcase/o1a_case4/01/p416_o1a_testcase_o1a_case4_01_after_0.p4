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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(8192, 13, 4096)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_010_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 16384)
    UM_INIT_5( 2, 100, 10, 16384)
    T1_INIT_1( 3, 200, 131072)
    T5_INIT_1( 4, 110, 4096)
    MRAC_INIT_1( 5, 110, 16384, 11,  8)
    MRB_INIT_1( 6, 010, 131072, 14,  8)
    T1_INIT_1( 7, 220, 524288)
    T2_INIT_HH_1( 8, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_4_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTPORT, ig_md.d_6_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //

        // UnivMon for inst 2
            d_2_res_hash_call.apply(DSTIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16); 
            d_2_index_hash_call_2.apply(DSTIP, ig_md.d_2_index2_16); 
            d_2_index_hash_call_3.apply(DSTIP, ig_md.d_2_index3_16); 
            d_2_index_hash_call_4.apply(DSTIP, ig_md.d_2_index4_16); 
            d_2_index_hash_call_5.apply(DSTIP, ig_md.d_2_index5_16); 
            UM_RUN_END_5(2, ig_md.d_2_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(2) 
        //

        T1_RUN_1_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        // PCSA for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            d_4_get_bitmask.apply(ig_md.d_4_level, ig_md.d_4_bitmask);
            update_4.apply(SRCIP, SRCPORT, ig_md.d_4_bitmask);
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTPORT, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        T1_RUN_1_KEY_4( 7, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_AFTER_1_KEY_5( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
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
        ig_md.d_2_above_threshold == 1
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