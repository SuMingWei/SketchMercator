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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(8192, 13, 2048)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 110, 524288)
    T1_INIT_1( 2, 110, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_5;
    //

    T2_INIT_3( 4, 110, 8192)
    MRAC_INIT_1( 6, 110, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_16);

        //

        T1_RUN_2_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_3_est_3);
            d_5_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_5_above_threshold);
            update_3_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_3_est_4);
            update_3_5.apply(SRCIP, SRCPORT, SIZE, ig_md.d_3_est_5);
        //

        T2_RUN_3_KEY_2( 4, SRCIP, SRCPORT, 1)
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_6_index1_16);
            update_6_1.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        if(ig_md.d_5_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, SRCIP, SRCPORT);
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