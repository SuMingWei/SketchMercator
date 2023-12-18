// [0] (src ip)
// [0, 1] (src ip, dst ip)
// [1, 3] (dst ip, dst port)
// [3] (dst port)

#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<32> d_##D##_est_1; \
    bit<16> d_##D##_index; \
    bit<1> d_##D##_is_above_threshold; \

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<1> rand;

    bit<32> hf_srcip;
    bit<32> hf_dstip;
    bit<32> hf_both_port;
    bit<8> hf_proto;

    METADATA_DIM(1) // [3] (dst port)
    METADATA_DIM(2) // [3] (dst port)
    METADATA_DIM(3) // [1, 3] (dst ip, dst port)
    METADATA_DIM(4) // [1, 3] (dst ip, dst port)
    METADATA_DIM(5) // [0] (src ip)
    // METADATA_DIM(6) // [0] + [0, 1]
    METADATA_DIM(7) // [0, 1] (src ip, dst ip)
}

#include "parser.p4"

#include "hash_computation/API_hash.p4"
#include "counter_update/sketches/API_cm.p4"
#include "counter_update/optimizations/sketches/API_cm.p4"


#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define BOTHPORT ig_md.both_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len

// 16bit
#define CONTROL_DIM_16(D) \

// // 32bit
// #define CONTROL_DIM_32(D) \
//     TC_CM_UPDATE_TYPE1_32(32w0x3##D##243f0b) d_##D##_update_1; \

// // (32bit, 16bit)
// #define CONTROL_DIM_32_16(D) \
//     TC_CM_UPDATE_TYPE1_32_16(32w0x3##D##243f0b) d_##D##_update_1; \

// // (32bit, 32bit)
// #define CONTROL_DIM_32_32(D) \
//     TC_CM_UPDATE_TYPE1_32_32(32w0x3##D##243f0b) d_##D##_update_1; \


control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // random
    Random<bit<1>>() rng;
    action get_random() {
        ig_md.rand = rng.get();
    }

    // [3] (dst port)
    CM_UPDATE_16_4096(32w0x31243f0b) d_1_update_1;

    // [3] (dst port)
    CM_UPDATE_16_4096(32w0x31243f0b) d_2_update_1;

    // [1, 3] (dst ip, dst port)
    CM_UPDATE_32_16_4096(32w0x31243f0b) d_3_update_1;

    // [1, 3] (dst ip, dst port)
    CM_UPDATE_32_16_4096(32w0x31243f0b) d_4_update_1;

    // [0] (src ip)
    CM_UPDATE_32_4096(32w0x31243f0b) d_5_update_1;

    // [0, 1] + [0]
    CM_INDEX_UPDATE_8192(32w0x31243f0b) d_6_update_1;

    // [0, 1] (src ip, dst ip)
    CM_UPDATE_32_32_4096(32w0x31243f0b) d_7_update_1;

    // // heavy_flowkey_storage_five_tuple(32w0x30243f0b) heavy_flowkey_storage;

    action compute_index1() {
        COMPUTE_INDEX1(1)
        COMPUTE_INDEX1(3)
        COMPUTE_INDEX1(5)
        COMPUTE_INDEX1(7)
    }

    action compute_index2() {
        COMPUTE_INDEX3(1)
        COMPUTE_INDEX3(3)
        COMPUTE_INDEX3(5)
        COMPUTE_INDEX3(7)
    }

    apply {
        get_random();

        d_1_update_1.apply(DSTPORT, 1, ig_md.d_1_est_1);
        d_2_update_1.apply(DSTPORT, 1, ig_md.d_2_est_1);
        d_3_update_1.apply(DSTIP, DSTPORT, 1, ig_md.d_3_est_1);
        d_4_update_1.apply(DSTIP, DSTPORT, 1, ig_md.d_4_est_1);
        d_5_update_1.apply(SRCIP, 1, ig_md.d_5_est_1);
        d_7_update_1.apply(SRCIP, DSTIP, 1, ig_md.d_7_est_1);

        if (ig_md.rand == 0) {
            compute_index1();
        }
        else {
            compute_index2();
        }


        // d_1_update_2.apply(SRCIP, SIZE, ig_md.d_1_est_2);
        // d_1_update_3.apply(SRCIP, SIZE, ig_md.d_1_level, ig_md.d_1_est_3);
        // d_1_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_is_above_threshold);

        // d_6_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash);
        // d_6_lpm.apply(ig_md.d_6_sampling_hash, ig_md.d_6_level);
        // d_6_update_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_est_1);
        // d_6_update_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_est_2);
        // d_6_update_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_level, ig_md.d_6_est_3);
        // d_6_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_6_is_above_threshold);

        // d_7_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_sampling_hash);
        // d_7_lpm.apply(ig_md.d_7_sampling_hash, ig_md.d_7_level);
        // d_7_update_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_7_est_1);
        // d_7_update_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_7_est_2);
        // d_7_update_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_7_level, ig_md.d_7_est_3);
        // d_7_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_7_est_3, ig_md.d_7_is_above_threshold);

        // d_8_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_sampling_hash);
        // d_8_lpm.apply(ig_md.d_8_sampling_hash, ig_md.d_8_level);
        // d_8_update_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_8_est_1);
        // d_8_update_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_8_est_2);
        // d_8_update_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_8_level, ig_md.d_8_est_3);
        // d_8_above_threshold.apply(ig_md.d_8_est_1, ig_md.d_8_est_2, ig_md.d_8_est_3, ig_md.d_8_is_above_threshold);


        // if(ig_md.d_1_is_above_threshold == 1 ||
        //    ig_md.d_6_is_above_threshold == 1 || 
        //    ig_md.d_7_is_above_threshold == 1 || 
        //    ig_md.d_8_is_above_threshold == 1) {
        //     ig_md.hf_srcip = SRCIP;
        // }

        // if(ig_md.d_6_is_above_threshold == 1 || 
        //    ig_md.d_7_is_above_threshold == 1 || 
        //    ig_md.d_8_is_above_threshold == 1) {
        //     ig_md.hf_dstip = DSTIP;
        // }

        // if(ig_md.d_7_is_above_threshold == 1 || 
        //    ig_md.d_8_is_above_threshold == 1) {
        //     ig_md.hf_both_port = BOTHPORT;
        // }

        // if(ig_md.d_8_is_above_threshold == 1) {
        //     ig_md.hf_proto = PROTO;
        // }

        // if (ig_md.d_1_is_above_threshold == 1 ||
        //     ig_md.d_6_is_above_threshold == 1 ||
        //     ig_md.d_7_is_above_threshold == 1 ||
        //     ig_md.d_8_is_above_threshold == 1) {
        //     heavy_flowkey_storage.apply(ig_dprsr_md, ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_both_port, ig_md.hf_proto);
        // }

        // // d_2_hash_call.apply(SRCIP, SRCPORT, ig_md.d_2_sampling_hash);
        // // d_2_lpm.apply(ig_md.d_2_sampling_hash, ig_md.d_2_level);
        // // d_2_update_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_2_est_1);
        // // d_2_update_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_2_est_2);
        // // d_2_update_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_2_level, ig_md.d_2_est_3);
        // // d_2_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_2_is_above_threshold);

        // // d_3_hash_call.apply(DSTIP, DSTPORT, ig_md.d_3_sampling_hash);
        // // d_3_lpm.apply(ig_md.d_3_sampling_hash, ig_md.d_3_level);
        // // d_3_update_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_3_est_1);
        // // d_3_update_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_3_est_2);
        // // d_3_update_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_3_level, ig_md.d_3_est_3);
        // // d_3_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_3_is_above_threshold);

        // // d_4_hash_call.apply(DSTPORT, ig_md.d_4_sampling_hash);
        // // d_4_lpm.apply(ig_md.d_4_sampling_hash, ig_md.d_4_level);
        // // d_4_update_1.apply(DSTPORT, SIZE, ig_md.d_4_est_1);
        // // d_4_update_2.apply(DSTPORT, SIZE, ig_md.d_4_est_2);
        // // d_4_update_3.apply(DSTPORT, SIZE, ig_md.d_4_level, ig_md.d_4_est_3);
        // // d_4_above_threshold.apply(ig_md.d_4_est_1, ig_md.d_4_est_2, ig_md.d_4_est_3, ig_md.d_4_is_above_threshold);

        // // d_5_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash);
        // // d_5_lpm.apply(ig_md.d_5_sampling_hash, ig_md.d_5_level);
        // // d_5_update_1.apply(DSTIP, SIZE, ig_md.d_5_est_1);
        // // d_5_update_2.apply(DSTIP, SIZE, ig_md.d_5_est_2);
        // // d_5_update_3.apply(DSTIP, SIZE, ig_md.d_5_level, ig_md.d_5_est_3);
        // // d_5_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_is_above_threshold);
    }
}

struct heavy_flowkey_digest_t {
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<32> both_port;
    bit<8> proto;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_both_port, ig_md.hf_proto});
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
