#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

    // bit<32> d1_hash_1;
    // bit<32> d1_hash_2;
    // bit<32> d1_level;
    // bit<32> d1_est_1;
    // bit<32> d1_est_2;
    // bit<32> d1_est_3;
    // bit<32> d1_est_4;
    // bit<32> d1_est_5;
#define METADATA_DIM(D) \
    bit<32> d##D##_hash_1; \
    bit<32> d##D##_hash_2; \
    bit<32> d##D##_level; \
    bit<32> d##D##_est_1; \
    bit<32> d##D##_est_2; \
    bit<32> d##D##_est_3; \
    bit<32> d##D##_est_4; \
    bit<32> d##D##_est_5; 

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;

    METADATA_DIM(1)
    METADATA_DIM(2)
    METADATA_DIM(3)
    METADATA_DIM(4)
    METADATA_DIM(5)
    METADATA_DIM(6)
}

// update_cm_and_cm() d1_cm_and_cm_1;
// update_cm_and_cm() d1_cm_and_cm_2;
// update_cm_and_cm() d1_cm_and_cm_3;
// update_cm_and_cm() d1_cm_and_cm_4;
// update_cm_and_cm() d1_cm_and_cm_5;
#define CM_SETUP(D) \
    update_cm_and_cm() d##D##_cm_and_cm_1; \
    update_cm_and_cm() d##D##_cm_and_cm_2; \
    update_cm_and_cm() d##D##_cm_and_cm_3; \
    update_cm_and_cm() d##D##_cm_and_cm_4; \
    update_cm_and_cm() d##D##_cm_and_cm_5;


// d1_cm_and_cm_1.apply((bit<32>)ig_md.d1_hash_1[9:0], ig_md.d1_est_1);
// d1_cm_and_cm_2.apply((bit<32>)ig_md.d1_hash_1[19:10], ig_md.d1_est_2);
// d1_cm_and_cm_3.apply((bit<32>)ig_md.d1_hash_1[29:20], ig_md.d1_est_3);
// d1_cm_and_cm_4.apply((bit<32>)ig_md.d1_hash_2[9:0], ig_md.d1_est_4);
// d1_cm_and_cm_5.apply((bit<32>)ig_md.d1_hash_2[19:10], ig_md.d1_est_5);
#define CM_APPLY(D) \
    d##D##_cm_and_cm_1.apply((bit<32>)ig_md.d##D##_hash_1[9:0], ig_md.d##D##_est_1); \
    d##D##_cm_and_cm_2.apply((bit<32>)ig_md.d##D##_hash_1[19:10], ig_md.d##D##_est_2); \
    d##D##_cm_and_cm_3.apply((bit<32>)ig_md.d##D##_hash_1[29:20], ig_md.d##D##_est_3); \
    d##D##_cm_and_cm_4.apply((bit<32>)ig_md.d##D##_hash_2[9:0], ig_md.d##D##_est_4); \
    d##D##_cm_and_cm_5.apply((bit<32>)ig_md.d##D##_hash_2[19:10], ig_md.d##D##_est_5);


#include "parser.p4"

#include "API_common.p4"
#include "API_O1_hash.p4"
#include "API_O2_hash.p4"
#include "API_O3_tcam.p4"
#include "API_O5_salu.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // six dimensions:
    // d1: (srcIP)
    // d2: (dstIP)
    // d3: (srcIP, srcPort)
    // d4: (dstIP, dstPort)
    // d5: (srcIP, dstIP)
    // d6: (srcIP, dstIP, srcPort, dstPort, proto)

    // 5 sketches

    // HLL 16K
    // entropy
    // count sketch

    // MRAC
    // SpreadSketch

    // UnivMon

    HASH_COMPUTE(32w0x30243f0b) hash_1;
    HASH_COMPUTE(32w0x0f79f523) hash_2;

    lpm_optimization() d1_lpm;
    lpm_optimization() d2_lpm;
    lpm_optimization() d3_lpm;
    lpm_optimization() d4_lpm;
    lpm_optimization() d5_lpm;
    lpm_optimization() d6_lpm;

    CM_SETUP(1)
    CM_SETUP(2)
    CM_SETUP(3)
    CM_SETUP(4)
    CM_SETUP(5)
    CM_SETUP(6)

    // update_cs_and_hll() d1_cs_and_hll_1;
    // update_cs_and_cm() d1_cs_and_cm_2;
    // update_cs_and_cm() d1_cs_and_cm_3;
    // update_cs_and_cm() d1_cs_and_cm_4;
    // update_cs_and_cm() d1_cs_and_cm_5;

    // action middle_1() {
    //     ig_md.d1_middle = (bit<32>)(ig_md.d1_hash_1[31:24] << 4);
    // }
    // action middle_2() {
    //     ig_md.d1_middle = ig_md.d1_middle + (bit<32>)ig_md.d1_hash_2[27:24];
    // }

    apply {
        hash_1.apply(hdr, ig_md, ig_md.d1_hash_1, ig_md.d2_hash_1, ig_md.d3_hash_1, ig_md.d4_hash_1, ig_md.d5_hash_1, ig_md.d6_hash_1);
        hash_2.apply(hdr, ig_md, ig_md.d1_hash_2, ig_md.d2_hash_2, ig_md.d3_hash_2, ig_md.d4_hash_2, ig_md.d5_hash_2, ig_md.d6_hash_2);

        // middle_1();
        // middle_2();

        d1_lpm.apply(ig_md.d1_hash_1, ig_md.d1_level);
        d2_lpm.apply(ig_md.d2_hash_1, ig_md.d2_level);
        d3_lpm.apply(ig_md.d3_hash_1, ig_md.d3_level);
        d4_lpm.apply(ig_md.d4_hash_1, ig_md.d4_level);
        d5_lpm.apply(ig_md.d5_hash_1, ig_md.d5_level);
        d6_lpm.apply(ig_md.d6_hash_1, ig_md.d6_level);

        CM_APPLY(1)
        CM_APPLY(2)
        CM_APPLY(3)
        CM_APPLY(4)
        CM_APPLY(5)
        CM_APPLY(6)

        // lets first combine count-sketch and entropy
        // d1_cs_and_hll_1.apply((bit<32>)ig_md.d1_hash_1[10:0], ig_md.d1_hash_1[11:11], ig_md.d1_level, ig_md.d1_est_1);
        // d1_cs_and_cm_2.apply((bit<32>)ig_md.d1_hash_1[22:12], ig_md.d1_hash_1[23:23], ig_md.d1_est_2);
        // d1_cs_and_cm_3.apply((bit<32>)ig_md.d1_hash_2[10:0], ig_md.d1_hash_2[11:11], ig_md.d1_est_3);
        // d1_cs_and_cm_4.apply((bit<32>)ig_md.d1_hash_2[22:12], ig_md.d1_hash_2[23:23], ig_md.d1_est_4);
        // d1_cs_and_cm_5.apply(ig_md.d1_middle, ig_md.d1_hash_2[28:28], ig_md.d1_est_4);
        // d1_cs_and_cm_3.apply((bit<32>)(ig_md.d1_middle), ig_md.d1_hash_2[4:4], ig_md.d1_est_3);
        // d1_cs_and_cm_4.apply((bit<32>)ig_md.d1_hash_1[10:0], ig_md.d1_hash_1[11:11], ig_md.d1_est_4);
        // d1_cs_and_cm_5.apply((bit<32>)ig_md.d1_hash_1[10:0], ig_md.d1_hash_1[11:11], ig_md.d1_est_5);
        // cs_and_hll();
        // update_1.apply(ig_md.index_1, ig_md.res_1, ig_md.level, ig_md.base_1, ig_md.mem_index_1, ig_md.est_1);
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
