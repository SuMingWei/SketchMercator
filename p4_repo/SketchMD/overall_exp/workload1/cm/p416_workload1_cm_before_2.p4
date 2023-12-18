#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<32> d_##D##_src_addr; \
    bit<32> d_##D##_dst_addr; \
    bit<16> d_##D##_src_port; \
    bit<16> d_##D##_dst_port; \
    bit<8>  d_##D##_proto; \
    bit<16> d_##D##_size; \
    bit<1>  d_##D##_above_threshold; \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<32> d_##D##_est_4; \
    bit<32> d_##D##_est_5; \


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
    // METADATA_DIM(9)
    // METADATA_DIM(10)
    // METADATA_DIM(11)
    // METADATA_DIM(12)
    // METADATA_DIM(13)
    // METADATA_DIM(14)
}

#include "parser.p4"

#include "counter_update/API_cm.p4"
#include "counter_update/MACRO_cm.p4"
#include "heavy_flowkey_storage/API_above_threshold.p4"
#include "heavy_flowkey_storage/API_flowkey_storage.p4"

// SRCIP = 0
// DSTIP = 1

// SRCPORT = 2
// DSTPORT = 3

// PROTO = 4


#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len


#define SRCIP_D(D)   ig_md.d_##D##_src_addr
#define DSTIP_D(D)   ig_md.d_##D##_dst_addr
#define SRCPORT_D(D) ig_md.d_##D##_src_port
#define DSTPORT_D(D) ig_md.d_##D##_dst_port
#define PROTO_D(D)   ig_md.d_##D##_proto
#define SIZE_D(D)    ig_md.d_##D##_size


#define COPY_FLOWKEY(D) \
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) COPY_SRCIP_##D##; \
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) COPY_DSTIP_##D##; \
    Hash<bit<16>>(HashAlgorithm_t.IDENTITY) COPY_SRCPORT_##D##; \
    Hash<bit<16>>(HashAlgorithm_t.IDENTITY) COPY_DSTPORT_##D##; \
    Hash<bit<8>>(HashAlgorithm_t.IDENTITY) COPY_PROTO_##D##; \
    Hash<bit<16>>(HashAlgorithm_t.IDENTITY) COPY_SIZE_##D##; \
    action copy_srcip_##D##() { SRCIP_D(D) = COPY_SRCIP_##D##.get(SRCIP); } \
    action copy_dstip_##D##() { DSTIP_D(D) = COPY_DSTIP_##D##.get(DSTIP); } \
    action copy_srcport_##D##() { SRCPORT_D(D) = COPY_SRCPORT_##D##.get(SRCPORT); } \
    action copy_dstport_##D##() { DSTPORT_D(D) = COPY_DSTPORT_##D##.get(DSTPORT); } \
    action copy_proto_##D##() { PROTO_D(D) = COPY_PROTO_##D##.get(PROTO); } \
    action copy_size_##D##() { SIZE_D(D) = COPY_SIZE_##D##.get(SIZE); } \


control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    
    COPY_FLOWKEY(1)
    COPY_FLOWKEY(2)
    COPY_FLOWKEY(3)
    COPY_FLOWKEY(4)
    COPY_FLOWKEY(5)
    COPY_FLOWKEY(6)
    COPY_FLOWKEY(7)
    COPY_FLOWKEY(8)
    // COPY_FLOWKEY(9)
    // COPY_FLOWKEY(10)


    CM_INIT_4(1, 010, 16384)
    CM_INIT_2(2, 100, 8192)
    CM_INIT_3(3, 100, 4096)
    CM_INIT_3(4, 100, 4096)
    CM_INIT_1(5, 110, 8192)
    CM_INIT_2(6, 110, 8192)
    CM_INIT_4(7, 110, 4096)
    CM_INIT_4(8, 200, 16384)
    // CM_INIT_4(9, 220, 4096)
    // CM_INIT_2(10, 220, 16384)
    // CM_INIT_1(11, 220, 8192)
    // CM_INIT_5(12, 220, 16384)
    // CM_INIT_2(13, 221, 16384)
    // CM_INIT_5(14, 221, 4096)
    
    apply {
        copy_dstport_1();

        copy_dstip_2();

        copy_dstip_3();
        copy_size_3();

        copy_dstip_4();
        copy_size_4();

        copy_dstip_5();
        copy_dstport_5();

        copy_dstip_6();
        copy_dstport_6();
        copy_size_6();

        copy_srcip_7();
        copy_srcport_7();

        copy_srcip_8();
        copy_dstip_8();
        copy_size_8();

        CM_RUN_4_KEY_1(1, DSTPORT_D(1), 1)
        CM_RUN_2_KEY_1(2, DSTIP_D(2), 1)
        CM_RUN_3_KEY_1(3, DSTIP_D(3), SIZE_D(3))
        CM_RUN_3_KEY_1(4, DSTIP_D(4), SIZE_D(4))
        CM_RUN_1_KEY_2(5, DSTIP_D(5), DSTPORT_D(5), 1)
        CM_RUN_2_KEY_2(6, DSTIP_D(6), DSTPORT_D(6), SIZE_D(6))
        CM_RUN_4_KEY_2(7, SRCIP_D(7), SRCPORT_D(7), 1)
        CM_RUN_4_KEY_2(8, SRCIP_D(8), DSTIP_D(8), SIZE_D(8))
        // CM_RUN_4_KEY_4(9, SRCIP_D(9), DSTIP_D(9), SRCPORT_D(9), DSTPORT_D(9), 1)
        // CM_RUN_2_KEY_4(10, SRCIP_D(10), DSTIP_D(10), SRCPORT_D(10), DSTPORT_D(10), 1)
        // CM_RUN_1_KEY_4(11, SRCIP_D(11), DSTIP_D(11), SRCPORT_D(11), DSTPORT_D(11), SIZE_D(11))
        // CM_RUN_5_KEY_4(12, SRCIP_D(12), DSTIP_D(12), SRCPORT_D(12), DSTPORT_D(12), SIZE_D(12))
        // CM_RUN_2_KEY_5(13, SRCIP_D(13), DSTIP_D(13), SRCPORT_D(13), DSTPORT_D(13), PROTO_D(13), 1)
        // CM_RUN_5_KEY_5(14, SRCIP_D(14), DSTIP_D(14), SRCPORT_D(14), DSTPORT_D(14), PROTO_D(14), 1)
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

