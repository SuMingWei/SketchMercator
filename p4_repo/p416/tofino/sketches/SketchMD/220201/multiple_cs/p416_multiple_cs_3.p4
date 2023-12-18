#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<16> d_##D##_hash_cs; \
    bit<16> d_##D##_hash_1; \
    bit<16> d_##D##_hash_2; \
    bit<16> d_##D##_hash_3; \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<1> d_##D##_is_above_threshold; \

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;

    METADATA_DIM(1)
    METADATA_DIM(2)
    METADATA_DIM(3)
    METADATA_DIM(4)
}

#include "parser.p4"

#include "API_S1_hash.p4"
#include "API_S3_salu.p4"
// #include "API_S2_tcam.p4"
// #include "API_S4_heavy.p4"

#define CONTROL_DIM(D) \
    CS_UPDATE(32w0x30243f0b) d_##D##_cs_update_1; \
    CS_UPDATE(32w0x30243f0b) d_##D##_cs_update_1; \
    CS_UPDATE(32w0x30243f0b) d_##D##_cs_update_1; \


#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    
    CONTROL_DIM(1)
    CONTROL_DIM(1)

    HASH_COMPUTE_KEY32_16_16(32w0x6b8cb0c3) d_1_hash_call_cs;
    HASH_COMPUTE_KEY32_16_16(32w0x6b8cb0c3) d_2_hash_call_cs;
    HASH_COMPUTE_KEY32_16_16(32w0x6b8cb0c3) d_3_hash_call_cs;

    apply {
        d_1_hash_call_cs.apply(SRCIP, ig_md.d_1_hash_cs);
        d_2_hash_call_cs.apply(SRCIP, ig_md.d_2_hash_cs);
        d_3_hash_call_cs.apply(SRCIP, ig_md.d_3_hash_cs);
        

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
