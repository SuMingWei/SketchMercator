#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define HASH_BITS_MO 12 // 2^(12+1) = 8192

#define METADATA_DIM(D) \
    bit<16> d_##D##_hash_sampling; \
    bit<16> d_##D##_hash_cs; \
    bit<16> d_##D##_hash_1; \
    bit<16> d_##D##_hash_2; \
    bit<16> d_##D##_hash_3; \
    bit<16> d_##D##_hash_4; \
    bit<16> d_##D##_index_1; \
    bit<16> d_##D##_index_2; \
    bit<16> d_##D##_index_3; \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<1> d_##D##_is_above_threshold; \
    bit<32> d_##D##_level; \
    bit<16> d_##D##_base; \
    bit<32> d_##D##_threshold; \
    bit<16> d_##D##_hash_cs_real; \

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

    METADATA_DIM(9)
    METADATA_DIM(10)
    METADATA_DIM(11)
    METADATA_DIM(12)

    // METADATA_DIM(13)
    // METADATA_DIM(14)
    // METADATA_DIM(15)
    // METADATA_DIM(16)
}

#include "parser.p4"

#include "hash_computation/API_hash.p4"
#include "counter_update/optimizations/cas_tc/countmin.p4"
#include "heavy_flowkey/API_above_threshold.p4"
#include "heavy_flowkey/API_heavy_storage.p4"
#include "tcam/API_tcam.p4"


#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define BOTHPORT ig_md.both_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len

#define CONTROL_DIM_8(D) \
    HASH_COMPUTE_KEY8_16_16(32w0x30201f0b) d_##D##_hash_call_sampling; \
    HASH_COMPUTE_KEY8_16_16(32w0x30211f0b) d_##D##_hash_call_cs; \
    HASH_COMPUTE_KEY8_16_16(32w0x30241f0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY8_16_16(32w0x30242f0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY8_16_16(32w0x30243f0b) d_##D##_hash_call_3; \
    TC_CAS_CS_CM() d_##D##_cm_update_1; \
    TC_CAS_CS_CM() d_##D##_cm_update_2; \
    TC_CAS_CS_CM() d_##D##_cm_update_3; \
    lpm_optimization_16() d_##D##_lpm; \
    ABOVE_THRESHOLD_RAND() d_##D##_above_threshold; \

#define CONTROL_DIM_16(D) \
    HASH_COMPUTE_KEY16_16_16(32w0x30214f0b) d_##D##_hash_call_sampling; \
    HASH_COMPUTE_KEY16_16_16(32w0x30224f0b) d_##D##_hash_call_cs; \
    HASH_COMPUTE_KEY16_16_16(32w0x30244f0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY16_16_16(32w0x30245f0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY16_16_16(32w0x30246f0b) d_##D##_hash_call_3; \
    TC_CAS_CS_CM() d_##D##_cm_update_1; \
    TC_CAS_CS_CM() d_##D##_cm_update_2; \
    TC_CAS_CS_CM() d_##D##_cm_update_3; \
    lpm_optimization_16() d_##D##_lpm; \
    ABOVE_THRESHOLD_RAND() d_##D##_above_threshold; \


#define CONTROL_DIM_32(D) \
    HASH_COMPUTE_KEY32_16_16(32w0x30217f0b) d_##D##_hash_call_sampling; \
    HASH_COMPUTE_KEY32_16_16(32w0x30237f0b) d_##D##_hash_call_cs; \
    HASH_COMPUTE_KEY32_16_16(32w0x30247f0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY32_16_16(32w0x30248f0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY32_16_16(32w0x30249f0b) d_##D##_hash_call_3; \
    TC_CAS_CS_CM() d_##D##_cm_update_1; \
    TC_CAS_CS_CM() d_##D##_cm_update_2; \
    TC_CAS_CS_CM() d_##D##_cm_update_3; \
    lpm_optimization_16() d_##D##_lpm; \
    ABOVE_THRESHOLD_RAND() d_##D##_above_threshold; \


#define CONTROL_DIM_32_16(D) \
    HASH_COMPUTE_KEY32_KEY16_16_16(32w0x30217f0b) d_##D##_hash_call_sampling; \
    HASH_COMPUTE_KEY32_KEY16_16_16(32w0x30277f0b) d_##D##_hash_call_cs; \
    HASH_COMPUTE_KEY32_KEY16_16_16(32w0x30267f0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY32_KEY16_16_16(32w0x30258f0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY32_KEY16_16_16(32w0x30349f0b) d_##D##_hash_call_3; \
    TC_CAS_CS_CM() d_##D##_cm_update_1; \
    TC_CAS_CS_CM() d_##D##_cm_update_2; \
    TC_CAS_CS_CM() d_##D##_cm_update_3; \
    lpm_optimization_16() d_##D##_lpm; \
    ABOVE_THRESHOLD_RAND() d_##D##_above_threshold; \


#define CONTROL_DIM_32_32_16_16(D) \
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_16_16(32w0x3031af0b) d_##D##_hash_call_sampling; \
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_16_16(32w0x3034af0b) d_##D##_hash_call_cs; \
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_16_16(32w0x3024af0b) d_##D##_hash_call_1; \
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_16_16(32w0x3024bf0b) d_##D##_hash_call_2; \
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_16_16(32w0x3024cf0b) d_##D##_hash_call_3; \
    TC_CAS_CS_CM() d_##D##_cm_update_1; \
    TC_CAS_CS_CM() d_##D##_cm_update_2; \
    TC_CAS_CS_CM() d_##D##_cm_update_3; \
    lpm_optimization_16() d_##D##_lpm; \
    ABOVE_THRESHOLD_RAND() d_##D##_above_threshold; \


#define COMPUTE_INDEX1(D) \
    ig_md.d_##D##_index_1 = (bit<16>)ig_md.d_##D##_hash_1[11:0]; \
    ig_md.d_##D##_index_2 = (bit<16>)ig_md.d_##D##_hash_2[11:0]; \
    ig_md.d_##D##_index_3 = (bit<16>)ig_md.d_##D##_hash_3[11:0]; \

#define COMPUTE_INDEX2(D) \
    ig_md.d_##D##_index_1 = ig_md.d_##D##_base + (bit<16>)ig_md.d_##D##_hash_1[9:0]; \
    ig_md.d_##D##_index_2 = ig_md.d_##D##_base + (bit<16>)ig_md.d_##D##_hash_2[9:0]; \
    ig_md.d_##D##_index_3 = ig_md.d_##D##_base + (bit<16>)ig_md.d_##D##_hash_3[9:0]; \

#define COMPUTE_INDEX3(D) \
    ig_md.d_##D##_index_1 = (bit<16>)ig_md.d_##D##_hash_1[11:0]; \
    ig_md.d_##D##_index_2 = (bit<16>)ig_md.d_##D##_hash_2[11:0]; \
    ig_md.d_##D##_index_3 = (bit<16>)ig_md.d_##D##_hash_3[11:0]; \
    ig_md.d_##D##_hash_cs_real = ig_md.d_##D##_hash_cs; \

#define COMPUTE_INDEX4(D, E) \
    ig_md.d_##D##_index_1 = ig_md.d_##E##_base + (bit<16>)ig_md.d_##E##_hash_1[9:0]; \
    ig_md.d_##D##_index_2 = ig_md.d_##E##_base + (bit<16>)ig_md.d_##E##_hash_1[9:0]; \
    ig_md.d_##D##_index_3 = ig_md.d_##E##_base + (bit<16>)ig_md.d_##E##_hash_1[9:0]; \
    ig_md.d_##D##_hash_cs_real = ig_md.d_##E##_hash_cs; \


#define XOR_ACTION(D, E) \
    action xor_hash_##D##_##E##() { \
        ig_md.d_##E##_hash_1  = ig_md.d_##D##_hash_1  ^ ig_md.d_##E##_hash_4; \
        ig_md.d_##E##_hash_2  = ig_md.d_##D##_hash_2  ^ ig_md.d_##E##_hash_4; \
        ig_md.d_##E##_hash_3  = ig_md.d_##D##_hash_3  ^ ig_md.d_##E##_hash_4; \
    } \

        // ig_md.d_##E##_hash_cs = ig_md.d_##D##_hash_cs ^ ig_md.d_##E##_hash_4; \

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    CONTROL_DIM_32(1)
    CONTROL_DIM_32_16(3)
    CONTROL_DIM_16(5)
    CONTROL_DIM_32_16(7)

    CONTROL_DIM_32(9)
    CONTROL_DIM_32(10)
    // CONTROL_DIM_32_32_16_16(11)
    // CONTROL_DIM_8(12)

    heavy_flowkey_storage_four_tuple_full(32w0x30243f0b) heavy_flowkey_storage;

    // random
    Random<bit<1>>() rng;
    action get_random() {
        ig_md.rand = rng.get();
    }

    XOR_ACTION(10, 9)

    // XOR_ACTION(9, 10)
    // XOR_ACTION(11, 12)

    action compute_index1() {
        COMPUTE_INDEX1(1)
        COMPUTE_INDEX1(3)
        COMPUTE_INDEX1(5)
        COMPUTE_INDEX1(7)
    }

    action compute_index2() {
        COMPUTE_INDEX2(1)
        COMPUTE_INDEX2(3)
        COMPUTE_INDEX2(5)
        COMPUTE_INDEX2(7)
    }

    action compute_index3() {
        COMPUTE_INDEX3(9)
        // COMPUTE_INDEX1(11)
    }

    action compute_index4() {
        COMPUTE_INDEX4(9, 10)
        // COMPUTE_INDEX2(11, 12)
    }

    apply {
        get_random();

        d_1_hash_call_sampling.apply(SRCIP, ig_md.d_1_hash_sampling);
        d_1_hash_call_cs.apply(SRCIP, ig_md.d_1_hash_cs);
        d_1_hash_call_1.apply(SRCIP, ig_md.d_1_hash_1);
        d_1_hash_call_2.apply(SRCIP, ig_md.d_1_hash_2);
        d_1_hash_call_3.apply(SRCIP, ig_md.d_1_hash_3);
        d_1_lpm.apply(ig_md.d_1_hash_sampling, ig_md.d_1_level, ig_md.d_1_base, ig_md.d_1_threshold);

        d_3_hash_call_sampling.apply(SRCIP, SRCPORT, ig_md.d_3_hash_sampling);
        d_3_hash_call_cs.apply(SRCIP, SRCPORT, ig_md.d_3_hash_cs);
        d_3_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_3_hash_1);
        d_3_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_3_hash_2);
        d_3_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_3_hash_3);
        d_3_lpm.apply(ig_md.d_3_hash_sampling, ig_md.d_3_level, ig_md.d_3_base, ig_md.d_3_threshold);

        d_5_hash_call_sampling.apply(DSTPORT, ig_md.d_5_hash_sampling);
        d_5_hash_call_cs.apply(DSTPORT, ig_md.d_5_hash_cs);
        d_5_hash_call_1.apply(DSTPORT, ig_md.d_5_hash_1);
        d_5_hash_call_2.apply(DSTPORT, ig_md.d_5_hash_2);
        d_5_hash_call_3.apply(DSTPORT, ig_md.d_5_hash_3);
        d_5_lpm.apply(ig_md.d_5_hash_sampling, ig_md.d_5_level, ig_md.d_5_base, ig_md.d_5_threshold);

        // d_7_hash_call_sampling.apply(DSTIP, DSTPORT, ig_md.d_7_hash_sampling);
        // d_7_hash_call_cs.apply(DSTIP, DSTPORT, ig_md.d_7_hash_cs);
        // d_7_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_7_hash_1);
        // d_7_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_7_hash_2);
        // d_7_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_7_hash_3);
        // d_7_lpm.apply(ig_md.d_7_hash_sampling, ig_md.d_7_level, ig_md.d_7_base, ig_md.d_7_threshold);

        if (ig_md.rand == 0) {
            compute_index1();
        }
        else {
            compute_index2();
        }

        d_1_cm_update_1.apply(ig_md.d_1_index_1, ig_md.d_1_hash_cs[0:0], ig_md.d_1_est_1);
        d_1_cm_update_2.apply(ig_md.d_1_index_2, ig_md.d_1_hash_cs[1:1], ig_md.d_1_est_2);
        d_1_cm_update_3.apply(ig_md.d_1_index_3, ig_md.d_1_hash_cs[2:2], ig_md.d_1_est_3);
        d_1_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_threshold, ig_md.rand, ig_md.d_1_is_above_threshold);

        d_3_cm_update_1.apply(ig_md.d_3_index_1, ig_md.d_3_hash_cs[0:0], ig_md.d_3_est_1);
        d_3_cm_update_2.apply(ig_md.d_3_index_2, ig_md.d_3_hash_cs[1:1], ig_md.d_3_est_2);
        d_3_cm_update_3.apply(ig_md.d_3_index_3, ig_md.d_3_hash_cs[2:2], ig_md.d_3_est_3);
        d_3_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_3_threshold, ig_md.rand, ig_md.d_3_is_above_threshold);

        d_5_cm_update_1.apply(ig_md.d_5_index_1, ig_md.d_5_hash_cs[0:0], ig_md.d_5_est_1);
        d_5_cm_update_2.apply(ig_md.d_5_index_2, ig_md.d_5_hash_cs[1:1], ig_md.d_5_est_2);
        d_5_cm_update_3.apply(ig_md.d_5_index_3, ig_md.d_5_hash_cs[2:2], ig_md.d_5_est_3);
        d_5_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_threshold, ig_md.rand, ig_md.d_5_is_above_threshold);

        // d_7_cm_update_1.apply(ig_md.d_7_index_1, ig_md.d_7_hash_cs[0:0], ig_md.d_7_est_1);
        // d_7_cm_update_2.apply(ig_md.d_7_index_2, ig_md.d_7_hash_cs[1:1], ig_md.d_7_est_2);
        // d_7_cm_update_3.apply(ig_md.d_7_index_3, ig_md.d_7_hash_cs[2:2], ig_md.d_7_est_3);
        // d_7_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_7_est_3, ig_md.d_7_threshold, ig_md.rand, ig_md.d_7_is_above_threshold);


        d_9_hash_call_1.apply(SRCIP, ig_md.d_9_hash_4);
        d_9_hash_call_cs.apply(SRCIP, ig_md.d_9_hash_cs);
        d_10_hash_call_cs.apply(DSTIP, ig_md.d_10_hash_cs);
        d_10_hash_call_1.apply(DSTIP, ig_md.d_10_hash_1);
        d_10_hash_call_2.apply(DSTIP, ig_md.d_10_hash_2);
        d_10_hash_call_3.apply(DSTIP, ig_md.d_10_hash_3);
        d_10_hash_call_sampling.apply(DSTIP, ig_md.d_10_hash_sampling);
        d_10_lpm.apply(ig_md.d_10_hash_sampling, ig_md.d_10_level, ig_md.d_10_base, ig_md.d_10_threshold);
        xor_hash_10_9();

        // d_11_hash_call_1.apply(SRCIP, ig_md.d_11_hash_4);
        // d_12_hash_call_cs.apply(DSTIP, ig_md.d_12_hash_cs);
        // d_12_hash_call_1.apply(DSTIP, ig_md.d_12_hash_1);
        // d_12_hash_call_2.apply(DSTIP, ig_md.d_12_hash_2);
        // d_12_hash_call_3.apply(DSTIP, ig_md.d_12_hash_3);
        // d_12_hash_call_sampling.apply(DSTIP, ig_md.d_12_hash_sampling);
        // d_12_lpm.apply(ig_md.d_12_hash_sampling, ig_md.d_12_level, ig_md.d_12_base, ig_md.d_12_threshold);
        // xor_hash_12_11();

        if (ig_md.rand == 0) {
            compute_index3();
        }
        else {
            compute_index4();
        }
 
        d_9_cm_update_1.apply(ig_md.d_9_index_1, ig_md.d_9_hash_cs_real[0:0], ig_md.d_9_est_1);
        d_9_cm_update_2.apply(ig_md.d_9_index_2, ig_md.d_9_hash_cs_real[1:1], ig_md.d_9_est_2);
        d_9_cm_update_3.apply(ig_md.d_9_index_3, ig_md.d_9_hash_cs_real[2:2], ig_md.d_9_est_3);
        d_9_above_threshold.apply(ig_md.d_9_est_1, ig_md.d_9_est_2, ig_md.d_9_est_3, ig_md.d_9_threshold, ig_md.rand, ig_md.d_9_is_above_threshold);

        // d_11_cm_update_1.apply(ig_md.d_11_index_1, ig_md.d_11_hash_cs_real[0:0], ig_md.d_11_est_1);
        // d_11_cm_update_2.apply(ig_md.d_11_index_2, ig_md.d_11_hash_cs_real[1:1], ig_md.d_11_est_2);
        // d_11_cm_update_3.apply(ig_md.d_11_index_3, ig_md.d_11_hash_cs_real[2:2], ig_md.d_11_est_3);

        if (ig_md.rand == 0) {
            if(ig_md.d_1_is_above_threshold == 1 ||
                ig_md.d_3_is_above_threshold == 1 || 
                ig_md.d_9_is_above_threshold == 1) {
                ig_md.hf_srcip = SRCIP;
            }

            if(ig_md.d_7_is_above_threshold == 1 || 
                ig_md.d_9_is_above_threshold == 1) {
                ig_md.hf_dstip = DSTIP;
            }
        }
        else {
            if(ig_md.d_1_is_above_threshold == 1 ||
                ig_md.d_3_is_above_threshold == 1) {
                ig_md.hf_srcip = SRCIP;
            }

            if(ig_md.d_7_is_above_threshold == 1 || 
                ig_md.d_9_is_above_threshold == 1) {
                ig_md.hf_dstip = DSTIP;
            }
        }

        if(ig_md.d_3_is_above_threshold == 1) {
            ig_md.hf_src_port = SRCPORT;
        }

        if(ig_md.d_5_is_above_threshold == 1 || 
           ig_md.d_7_is_above_threshold == 1) {
            ig_md.hf_dst_port = DSTPORT;
        }

        if (ig_md.d_1_is_above_threshold == 1 ||
            ig_md.d_3_is_above_threshold == 1 ||
            ig_md.d_5_is_above_threshold == 1 ||
            ig_md.d_7_is_above_threshold == 1 || 
            ig_md.d_9_is_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_src_port, ig_md.hf_dst_port);
        }
    }
}

struct heavy_flowkey_digest_t {
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<16> src_port;
    bit<16> dst_port;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_src_port, ig_md.hf_dst_port});
        }
        pkt.emit(hdr);
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
    SwitchIngressDeparserDigest(),
    EgressParser(),
    EmptyEgress(),
    EgressDeparser()
) pipe;

Switch(pipe) main;
