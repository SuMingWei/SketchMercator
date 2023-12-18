#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<16> d_##D##_sampling_hash_16; \
    bit<32> d_##D##_sampling_hash_32; \
    bit<16> d_##D##_base_16; \
    bit<32> d_##D##_base_32; \
    bit<8> d_##D##_level; \
    bit<32> d_##D##_threshold; \
    bit<16> d_##D##_res_hash; \
    bit<16> d_##D##_index1_16; \
    bit<16> d_##D##_index2_16; \
    bit<16> d_##D##_index3_16; \
    bit<16> d_##D##_index4_16; \
    bit<16> d_##D##_index5_16; \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<32> d_##D##_est_4; \
    bit<32> d_##D##_est_5; \
    bit<1>  d_##D##_above_threshold; \


struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;

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

#include "tcam/API_tcam.p4"
#include "hash_computation/API_hash.p4"
#include "heavy_flowkey_storage/API_above_threshold.p4"
#include "heavy_flowkey_storage/API_flowkey_storage.p4"
#include "counter_update/API_T2_counter.p4"
#include "counter_update/MACRO_common.p4"
#include "counter_update/MACRO_T2_init.p4"
#include "counter_update/MACRO_T2_run.p4"


#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len


control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {


// SRCIP = 0
// DSTIP = 1
// SRCPORT = 2
// DSTPORT = 3
// PROTO = 4

    T2_INIT_HH_5(1,  010, 16384)
    T2_INIT_HH_5(2,  100, 4096)
    T2_INIT_HH_2(3,  100, 4096)
    T2_INIT_HH_1(4,  100, 16384)
    T2_INIT_HH_2(5,  100, 8192)
    T2_INIT_HH_1(6,  200, 8192)
    T2_INIT_HH_1(7,  200, 8192)
    T2_INIT_HH_1(8,  200, 16384)
    T2_INIT_HH_2(9,  220, 16384)
    T2_INIT_HH_5(10, 221, 16384)

    apply {
        T2_RUN_HH_5_KEY_1(1, DSTPORT, SIZE)
        T2_RUN_HH_5_KEY_1(2, DSTIP, 1)
        T2_RUN_HH_2_KEY_1(3, DSTIP, SIZE)
        T2_RUN_HH_1_KEY_1(4, SRCIP, 1)
        T2_RUN_HH_2_KEY_1(5, SRCIP, SIZE)
        T2_RUN_HH_1_KEY_2(6, SRCIP, DSTIP, SIZE)
        // T2_RUN_HH_1_KEY_2(7, SRCIP, DSTIP, SIZE)
        // T2_RUN_HH_1_KEY_2(8, SRCIP, DSTIP, SIZE)
        // T2_RUN_HH_2_KEY_4(9, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // T2_RUN_HH_5_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
    }
}

struct my_egress_headers_t {
}

    /********  G L O B A L   E G R E S S   M E T A D A T A  *********/

struct my_egress_metadata_t {
}

parser EgressParser(packet_in        pkt,
    /* User */
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */
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
    /* User */
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    /* Intrinsic */
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

