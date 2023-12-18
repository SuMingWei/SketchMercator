#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<1>  d_##D##_above_threshold; \
    bit<16> d_##D##_index_1_1; \
    bit<16> d_##D##_index_2_1; \
    bit<16> d_##D##_index_3_1; \
    bit<16> d_##D##_index_4_1; \
    bit<16> d_##D##_index_5_1; \
    bit<16> d_##D##_index_1_2; \
    bit<16> d_##D##_index_2_2; \
    bit<16> d_##D##_index_3_2; \
    bit<16> d_##D##_index_4_2; \
    bit<16> d_##D##_index_5_2; \
    bit<16> d_##D##_index_1; \
    bit<16> d_##D##_index_2; \
    bit<16> d_##D##_index_3; \
    bit<16> d_##D##_index_4; \
    bit<16> d_##D##_index_5; \
    bit<16> d_##D##_psize_1; \
    bit<16> d_##D##_psize_2; \
    bit<16> d_##D##_psize_3; \
    bit<16> d_##D##_psize_4; \
    bit<16> d_##D##_psize_5; \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<32> d_##D##_est_4; \
    bit<32> d_##D##_est_5; \
    bit<1> d_##D##_1_above_threshold; \
    bit<1> d_##D##_2_above_threshold; \
    bit<1> d_##D##_3_above_threshold; \


struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<1> rand;

    bit<32> hf_srcip;
    bit<32> hf_dstip;
    bit<16> hf_src_port;
    bit<16> hf_dst_port;
    bit<8> hf_proto;

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

#include "counter_update/API_cm_O4.p4"
#include "counter_update/API_cm.p4"
#include "counter_update/MACRO_cm.p4"
#include "heavy_flowkey_storage/API_above_threshold.p4"
#include "heavy_flowkey_storage/API_flowkey_storage.p4"
#include "hash_computation/API_hash.p4"

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


control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {


    COMPUTE_HASH_010_16_15(32w0x30244f0b) d_1_hash_call_1_1;
    COMPUTE_HASH_010_16_15(32w0x30244f0b) d_1_hash_call_2_1;
    COMPUTE_HASH_010_16_15(32w0x30244f0b) d_1_hash_call_3_1;
    COMPUTE_HASH_010_16_15(32w0x30244f0b) d_1_hash_call_4_1;
    COMPUTE_HASH_010_16_15(32w0x30244f0b) d_1_hash_call_5_1;

    COMPUTE_HASH_100_16_13(32w0x30244f0b) d_1_hash_call_1_2;
    COMPUTE_HASH_100_16_13(32w0x30244f0b) d_1_hash_call_2_2;
    COMPUTE_HASH_100_16_13(32w0x30244f0b) d_1_hash_call_3_2;
    COMPUTE_HASH_100_16_13(32w0x30244f0b) d_1_hash_call_4_2;
    COMPUTE_HASH_110_16_14(32w0x30244f0b) d_1_hash_call_5_2;

    CM_INDEX_UPDATE_40960() update_1_1;
    CM_INDEX_UPDATE_40960() update_1_2;
    CM_INDEX_UPDATE_40960() update_1_3;
    CM_INDEX_UPDATE_40960() update_1_4;
    CM_INDEX_UPDATE_49152() update_1_5;

    ABOVE_THRESHOLD_CONSTANT_5(100) d_1_1_above_threshold;
    ABOVE_THRESHOLD_CONSTANT_4(100) d_1_2_above_threshold;
    ABOVE_THRESHOLD_CONSTANT_1(100) d_1_3_above_threshold;




    COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_hash_call_1_1;
    COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_hash_call_2_1;
    COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_hash_call_3_1;
    COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_hash_call_4_1;

    COMPUTE_HASH_120_16_16(32w0x30244f0b) d_2_hash_call_1_2;
    // COMPUTE_HASH_100_16_14(32w0x30244f0b) d_2_hash_call_2_2;
    // COMPUTE_HASH_220_16_15(32w0x30244f0b) d_2_hash_call_3_2;
    // COMPUTE_HASH_220_16_15(32w0x30244f0b) d_2_hash_call_4_2;

    CM_INDEX_UPDATE_24576() update_2_1;
    CM_INDEX_UPDATE_24576() update_2_2;
    CM_INDEX_UPDATE_40960() update_2_3;
    CM_INDEX_UPDATE_40960() update_2_4;

    ABOVE_THRESHOLD_CONSTANT_4(100) d_2_1_above_threshold;
    ABOVE_THRESHOLD_CONSTANT_2(100) d_2_2_above_threshold;
    ABOVE_THRESHOLD_CONSTANT_2(100) d_2_3_above_threshold;






    HEAVY_FLOWKEY_STORAGE_221(32w0x30243f0b) heavy_flowkey_storage;

    Random<bit<1>>() rng;
    action get_random() {
        ig_md.rand = rng.get();
    }

    action d_1_xor_construction() {
        ig_md.d_1_index_5_2 = ig_md.d_1_index_1_1 ^ ig_md.d_1_index_1_2;
    }

    action rand_0_index_action_1() {
        ig_md.d_1_index_1 = ig_md.d_1_index_1_1;
        ig_md.d_1_index_2 = ig_md.d_1_index_2_1;
        ig_md.d_1_index_3 = ig_md.d_1_index_3_1;
        ig_md.d_1_index_4 = ig_md.d_1_index_4_1;
        ig_md.d_1_index_5 = ig_md.d_1_index_5_1;
        ig_md.d_1_psize_1 = 1;
        ig_md.d_1_psize_2 = 1;
        ig_md.d_1_psize_3 = 1;
        ig_md.d_1_psize_4 = 1;
        ig_md.d_1_psize_5 = 1;
    }

    action rand_1_index_action_1() {
        ig_md.d_1_index_1 = 32768 + ig_md.d_1_index_1_2;
        ig_md.d_1_index_2 = 32768 + ig_md.d_1_index_2_2;
        ig_md.d_1_index_3 = 32768 + ig_md.d_1_index_3_2;
        ig_md.d_1_index_4 = 32768 + ig_md.d_1_index_4_2;
        ig_md.d_1_index_5 = 32768 + ig_md.d_1_index_5_2;
        ig_md.d_1_psize_1 = SIZE;
        ig_md.d_1_psize_2 = SIZE;
        ig_md.d_1_psize_3 = SIZE;
        ig_md.d_1_psize_4 = SIZE;
        ig_md.d_1_psize_5 = 1;
    }


    action d_2_xor_construction() {
        ig_md.d_2_index_3_2 = ig_md.d_2_index_1_1 ^ ig_md.d_2_index_1_2;
        ig_md.d_2_index_4_2 = ig_md.d_2_index_2_1 ^ ig_md.d_2_index_1_2;
    }


    action rand_0_index_action_2() {
        ig_md.d_2_index_1 = (bit<16>)ig_md.d_2_index_1_1[12:0];
        ig_md.d_2_index_2 = (bit<16>)ig_md.d_2_index_2_1[12:0];
        ig_md.d_2_index_3 = (bit<16>)ig_md.d_2_index_3_1[12:0];
        ig_md.d_2_index_4 = (bit<16>)ig_md.d_2_index_4_1[12:0];
        ig_md.d_2_psize_1 = SIZE;
        ig_md.d_2_psize_2 = SIZE;
        ig_md.d_2_psize_3 = SIZE;
        ig_md.d_2_psize_4 = SIZE;
    }


    action rand_1_index_action_2() {
        ig_md.d_2_index_1 = (bit<16>)ig_md.d_2_index_1_1[13:0];
        ig_md.d_2_index_2 = (bit<16>)ig_md.d_2_index_2_1[13:0];
        ig_md.d_2_index_3 = (bit<16>)ig_md.d_2_index_3_2[14:0];
        ig_md.d_2_index_4 = (bit<16>)ig_md.d_2_index_4_2[14:0];
        ig_md.d_2_psize_1 = 1;
        ig_md.d_2_psize_2 = 1;
        ig_md.d_2_psize_3 = 1;
        ig_md.d_2_psize_4 = 1;
    }
    action rand_1_index_action_2_again() {
        ig_md.d_2_index_1 = ig_md.d_2_index_1 + 8192;
        ig_md.d_2_index_2 = ig_md.d_2_index_2 + 8192;
        ig_md.d_2_index_3 = ig_md.d_2_index_3 + 8192;
        ig_md.d_2_index_4 = ig_md.d_2_index_4 + 8192;
    }

    apply {
        get_random();

        d_1_hash_call_1_1.apply(DSTPORT, ig_md.d_1_index_1_1);
        d_1_hash_call_2_1.apply(DSTPORT, ig_md.d_1_index_2_1);
        d_1_hash_call_3_1.apply(DSTPORT, ig_md.d_1_index_3_1);
        d_1_hash_call_4_1.apply(DSTPORT, ig_md.d_1_index_4_1);
        d_1_hash_call_5_1.apply(DSTPORT, ig_md.d_1_index_5_1);
        d_1_xor_construction();
        d_1_hash_call_1_2.apply(DSTIP, ig_md.d_1_index_1_2);
        d_1_hash_call_2_2.apply(DSTIP, ig_md.d_1_index_2_2);
        d_1_hash_call_3_2.apply(DSTIP, ig_md.d_1_index_3_2);
        d_1_hash_call_4_2.apply(DSTIP, ig_md.d_1_index_4_2);
        // d_1_hash_call_5_2.apply(DSTIP, DSTPORT, ig_md.d_1_index_5_2);

        if (ig_md.rand == 0) {
            rand_0_index_action_1();
        } else {
            rand_1_index_action_1();
        }

        update_1_1.apply(ig_md.d_1_index_1, ig_md.d_1_psize_1, ig_md.d_1_est_1);
        update_1_2.apply(ig_md.d_1_index_2, ig_md.d_1_psize_2, ig_md.d_1_est_2);
        update_1_3.apply(ig_md.d_1_index_3, ig_md.d_1_psize_3, ig_md.d_1_est_3);
        update_1_4.apply(ig_md.d_1_index_4, ig_md.d_1_psize_4, ig_md.d_1_est_4);
        update_1_5.apply(ig_md.d_1_index_5, ig_md.d_1_psize_5, ig_md.d_1_est_5);

        if (ig_md.rand == 0) {
            d_1_1_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_est_4, ig_md.d_1_est_5, ig_md.d_1_1_above_threshold);
        } else {
            d_1_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_est_4, ig_md.d_1_2_above_threshold);
            d_1_3_above_threshold.apply(ig_md.d_1_est_5, ig_md.d_1_3_above_threshold);
        }


        d_2_hash_call_1_1.apply(DSTIP, ig_md.d_2_index_1_1);
        d_2_hash_call_2_1.apply(DSTIP, ig_md.d_2_index_2_1);
        d_2_hash_call_3_1.apply(DSTIP, ig_md.d_2_index_3_1);
        d_2_hash_call_4_1.apply(DSTIP, ig_md.d_2_index_4_1);

        d_2_hash_call_1_2.apply(SRCIP, SRCPORT, DSTPORT, ig_md.d_2_index_1_2);
        // d_2_hash_call_2_2.apply(DSTIP, ig_md.d_2_index_2_2);
        // d_2_hash_call_3_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_2_index_3_2);
        // d_2_hash_call_4_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_2_index_4_2);
        d_2_xor_construction();

        if (ig_md.rand == 0) {
            rand_0_index_action_2();
        } else {
            rand_1_index_action_2();
            rand_1_index_action_2_again();
        }

        update_2_1.apply(ig_md.d_2_index_1, ig_md.d_2_psize_1, ig_md.d_2_est_1);
        update_2_2.apply(ig_md.d_2_index_2, ig_md.d_2_psize_2, ig_md.d_2_est_2);
        update_2_3.apply(ig_md.d_2_index_3, ig_md.d_2_psize_3, ig_md.d_2_est_3);
        update_2_4.apply(ig_md.d_2_index_4, ig_md.d_2_psize_4, ig_md.d_2_est_4);

        if (ig_md.rand == 0) {
            d_2_1_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_2_est_4, ig_md.d_2_1_above_threshold);
        } else {
            d_2_2_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_2_2_above_threshold);
            d_2_3_above_threshold.apply(ig_md.d_2_est_3, ig_md.d_2_est_4, ig_md.d_2_3_above_threshold);
        }


        if(
            ig_md.d_2_3_above_threshold == 1
            ) {
            ig_md.hf_srcip = SRCIP;
        }

        if(
            ig_md.d_1_2_above_threshold == 1 ||
            ig_md.d_1_3_above_threshold == 1 || 
            ig_md.d_2_1_above_threshold == 1 ||
            ig_md.d_2_2_above_threshold == 1 || 
            ig_md.d_2_3_above_threshold == 1
            ) {
            ig_md.hf_dstip = DSTIP;
        }

        if(
            ig_md.d_2_3_above_threshold == 1
            ) {
            ig_md.hf_src_port = SRCPORT;
        }

        if(
            ig_md.d_1_1_above_threshold == 1 ||
            ig_md.d_1_3_above_threshold == 1 ||
            ig_md.d_2_3_above_threshold == 1
            ) {
            ig_md.hf_dst_port = DSTPORT;
        }

        if (
            ig_md.d_1_1_above_threshold == 1 ||
            ig_md.d_1_2_above_threshold == 1 ||
            ig_md.d_1_3_above_threshold == 1 || 
            ig_md.d_2_1_above_threshold == 1 ||
            ig_md.d_2_2_above_threshold == 1 ||
            ig_md.d_2_3_above_threshold == 1
            ) {
            heavy_flowkey_storage.apply(ig_dprsr_md, ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_src_port, ig_md.hf_dst_port, ig_md.hf_proto);
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

