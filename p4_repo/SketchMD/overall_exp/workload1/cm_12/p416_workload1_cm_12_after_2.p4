
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

    HEAVY_FLOWKEY_STORAGE_220(32w0x30243f0b) heavy_flowkey_storage;

    T2_INIT_HH_1(1,  100, 8192)
    T2_INIT_HH_1(2,  100, 16384)
    T2_INIT_HH_2(3,  100, 16384)
    T2_INIT_HH_2(4,  100, 16384)
    T2_INIT_HH_2(5,  100, 8192)
    T2_INIT_HH_1(6,  100, 16384)

    T2_INIT_HH_2(7,  100, 16384)
    T2_INIT_HH_1(8,  100, 8192)

    T2_INIT_HH_4(9,  200, 8192)
    T2_INIT_HH_2(10, 200, 8192)

    T2_INIT_HH_2(11, 110, 8192)
    T2_INIT_HH_3(12, 110, 8192)

    T2_INIT_HH_4(13, 220, 16384)
    T2_INIT_HH_5(14, 220, 16384)

    apply {
        T2_RUN_AFTER_1_KEY_1(1, SRCIP, 1)    // epoch 10s
        T2_RUN_AFTER_1_KEY_1(2, SRCIP, SIZE) // epoch 10s
        T2_RUN_AFTER_2_KEY_1(3, SRCIP, 1)    // epoch 20s
        T2_RUN_AFTER_2_KEY_1(4, SRCIP, SIZE) // epoch 20s
        T2_RUN_AFTER_2_KEY_1(5, SRCIP, 1)    // epoch 30s
        T2_RUN_AFTER_1_KEY_1(6, SRCIP, SIZE) // epoch 30s

        T2_RUN_AFTER_2_KEY_1(7, DSTIP, 1)    // epoch 40s
        T2_RUN_AFTER_1_KEY_1(8, DSTIP, SIZE) // epoch 40s

        T2_RUN_AFTER_4_KEY_2(9, SRCIP, DSTIP, 1)      // epoch 20s
        T2_RUN_AFTER_2_KEY_2(10, SRCIP, DSTIP, SIZE)   // epoch 20s

        T2_RUN_AFTER_2_KEY_2(11, SRCIP, SRCPORT, 1)    // epoch 10s
        T2_RUN_AFTER_3_KEY_2(12, SRCIP, SRCPORT, SIZE) // epoch 10s

        if(ig_md.d_1_above_threshold == 1 ||
           ig_md.d_2_above_threshold == 1 ||
           ig_md.d_3_above_threshold == 1 ||
           ig_md.d_4_above_threshold == 1 ||
           ig_md.d_5_above_threshold == 1 ||
           ig_md.d_6_above_threshold == 1 ||
           ig_md.d_9_above_threshold == 1 ||
           ig_md.d_10_above_threshold == 1 ||
           ig_md.d_11_above_threshold == 1 ||
           ig_md.d_12_above_threshold == 1 ||
           ig_md.d_13_above_threshold == 1 ||
           ig_md.d_14_above_threshold == 1) {
            ig_md.hf_srcip = SRCIP;
        }

        if(ig_md.d_7_above_threshold == 1 ||
           ig_md.d_8_above_threshold == 1 ||
           ig_md.d_9_above_threshold == 1 ||
           ig_md.d_10_above_threshold == 1 ||
           ig_md.d_13_above_threshold == 1 ||
           ig_md.d_14_above_threshold == 1) {
            ig_md.hf_dstip = DSTIP;
        }

        if(ig_md.d_11_above_threshold == 1 ||
           ig_md.d_12_above_threshold == 1 ||
           ig_md.d_13_above_threshold == 1 ||
           ig_md.d_14_above_threshold == 1) {
            ig_md.hf_srcport = SRCPORT;
        }

        if(ig_md.d_13_above_threshold == 1 ||
           ig_md.d_14_above_threshold == 1) {
            ig_md.hf_dstport = DSTPORT;
        }

        if(ig_md.d_1_above_threshold == 1 ||
           ig_md.d_2_above_threshold == 1 ||
           ig_md.d_3_above_threshold == 1 ||
           ig_md.d_4_above_threshold == 1 ||
           ig_md.d_5_above_threshold == 1 ||
           ig_md.d_6_above_threshold == 1 ||
           ig_md.d_7_above_threshold == 1 ||
           ig_md.d_8_above_threshold == 1 ||
           ig_md.d_9_above_threshold == 1 ||
           ig_md.d_10_above_threshold == 1 ||
           ig_md.d_11_above_threshold == 1 ||
           ig_md.d_12_above_threshold == 1 ||
           ig_md.d_13_above_threshold == 1 ||
           ig_md.d_14_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport);
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