#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<10> d_##D##_hash_1; \
    bit<10> d_##D##_hash_2; \
    bit<10> d_##D##_hash_3; \

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> both_port;

    bit<32> est_1;
    bit<32> est_2;
    bit<32> est_3;
    bit<1> is_above_threshold;

    METADATA_DIM(1)
    METADATA_DIM(2)
}

#include "parser.p4"

#include "hash_computation/API_hash.p4"
#include "counter_update/API_counter_array_sampling.p4"
#include "heavy_flowkey/API_above_threshold.p4"
#include "heavy_flowkey/API_heavy_storage.p4"


#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define BOTHPORT ig_md.both_port
#define PROTO hdr.ipv4.protocol

#define CONTROL_DIM_1(D) \
    HASH_COMPUTE_KEY32_KEY32_KEY32_KEY8_10_10(32w0x30243f0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY32_KEY32_KEY32_KEY8_10_10(32w0x30243f0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY32_KEY32_KEY32_KEY8_10_10(32w0x30243f0b) d_##D##_hash_call_3; \
    heavy_flowkey_storage_five_tuple(32w0x30243f0b) d_##D##_heavy_flowkey; \

#define CONTROL_DIM_2(D) \
    HASH_COMPUTE_KEY32_KEY32_KEY32_10_10(32w0x30243f0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY32_KEY32_KEY32_10_10(32w0x30243f0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY32_KEY32_KEY32_10_10(32w0x30243f0b) d_##D##_hash_call_3; \
    heavy_flowkey_storage_four_tuple(32w0x30243f0b) d_##D##_heavy_flowkey; \

    // CM_UPDATE_32_32_32(32w0x30243f0b) d_##D##_cm_update_1; \
    // CM_UPDATE_32_32_32(32w0x30243f0b) d_##D##_cm_update_1; \
//     CM_UPDATE_32_32_32(32w0x30243f0b) d_##D##_cm_update_2; \
//     CM_UPDATE_32_32_32(32w0x30243f0b) d_##D##_cm_update_3; \

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    CONTROL_DIM_1(1)
    CONTROL_DIM_2(2)
    ABOVE_THRESHOLD_RAND() above_threshold; \

    CA_SAMPLING() ca_sampling_1;
    CA_SAMPLING() ca_sampling_2;
    CA_SAMPLING() ca_sampling_3;

    // merge ports
    action get_both_port() {
        ig_md.both_port = ig_md.src_port ++ ig_md.dst_port;
    }

    // random
    bit<1> rand;
    Random<bit<1>>() rng;
    action get_random() {
        rand = rng.get();
    }

    apply {
        get_both_port();
        get_random();

        d_1_hash_call_1.apply(SRCIP, DSTIP, BOTHPORT, PROTO, ig_md.d_1_hash_1);
        d_1_hash_call_2.apply(SRCIP, DSTIP, BOTHPORT, PROTO, ig_md.d_1_hash_2);
        d_1_hash_call_3.apply(SRCIP, DSTIP, BOTHPORT, PROTO, ig_md.d_1_hash_3);

        d_2_hash_call_1.apply(SRCIP, DSTIP, BOTHPORT, ig_md.d_2_hash_1);
        d_2_hash_call_2.apply(SRCIP, DSTIP, BOTHPORT, ig_md.d_2_hash_2);
        d_2_hash_call_3.apply(SRCIP, DSTIP, BOTHPORT, ig_md.d_2_hash_3);

        ca_sampling_1.apply(ig_md.d_1_hash_1, ig_md.d_2_hash_1, rand, ig_md.est_1);
        ca_sampling_2.apply(ig_md.d_1_hash_2, ig_md.d_2_hash_2, rand, ig_md.est_2);
        ca_sampling_3.apply(ig_md.d_1_hash_3, ig_md.d_2_hash_3, rand, ig_md.est_3);

        above_threshold.apply(ig_md.est_1, ig_md.est_2, ig_md.est_3, rand, ig_md.is_above_threshold);
        if(ig_md.is_above_threshold == 1) {
            if(rand == 0) {
                d_1_heavy_flowkey.apply(hdr, SRCIP, DSTIP, BOTHPORT, PROTO, ig_tm_md);
            }
            else {
                d_2_heavy_flowkey.apply(hdr, SRCIP, DSTIP, BOTHPORT, ig_tm_md);
            }
        }
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
