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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

    //


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_1_above_threshold;
    // 

    T1_INIT_1( 3, 100, 131072)
    MRB_INIT_1( 4, 100, 262144, 14, 16)
    T2_INIT_1( 5, 100, 8192)
    T2_INIT_5( 6, 200, 16384)
    T2_INIT_HH_2( 7, 200, 8192)
    T2_INIT_HH_2( 8, 110, 16384)
    MRAC_INIT_1( 9, 110, 16384, 11,  8)
    T4_INIT_1(10, 110, 8192)
    T2_INIT_HH_5(11, 110, 4096)
    T1_INIT_5(12, 221, 262144)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_sampling_hash_32);

        //


        // apply O2
        T2_RUN_AFTER_4_KEY_1(1, SRCIP, 1)
        // 

        T1_RUN_1_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        // MRB for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_32);
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16);
            update_4_1.apply(ig_md.d_4_base_32, ig_md.d_4_index1_16);
        //

        T2_RUN_1_KEY_1( 5, DSTIP, 1)
        T2_RUN_5_KEY_2( 6, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_2( 7, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_2( 8, SRCIP, SRCPORT, 1)
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16);
            update_9_1.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        // HLL for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
            update_10_1.apply(DSTIP, DSTPORT, ig_md.d_10_level);
        //

        T2_RUN_AFTER_5_KEY_2(11, DSTIP, DSTPORT, 1)
        T1_RUN_5_KEY_5(12, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0 || ig_md.d_12_est1_3 == 0 || ig_md.d_12_est1_4 == 0 || ig_md.d_12_est1_5 == 0) { /* process_new_flow() */ }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
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