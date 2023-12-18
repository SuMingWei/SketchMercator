#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define UM_TOTAL_SIZE 16384
#define UM_ROW_SIZE 1024
#define UM_BITLEN 10
#define UM_BITLEN_MINUS 9
#define BASE_BITLEN 16

#define METADATA_DIM(D) \
    bit<16> d_##D##_hash_cs; \
    bit<16> d_##D##_hash_s; \
    bit<16> d_##D##_hash_1; \
    bit<16> d_##D##_hash_2; \
    bit<16> d_##D##_hash_3; \
    bit<32> d_##D##_level; \
    bit<32> d_##D##_um_threshold; \
    bit<16> d_##D##_base; \
    bit<32> d_##D##_est_1; \
    bit<32> d_##D##_est_2; \
    bit<32> d_##D##_est_3; \
    bit<1> d_##D##_is_above_threshold; \

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;

    bit<16> d_3_hash_s_2;
    bit<16> d_5_hash_s;
    bit<16> d_6_hash_s;

    bit<16> cd_1_ss_base;
    bit<16> cd_2_ss_base;
    bit<16> cd_4_ss_base;

    bit<32> d_6_level;
    bit<1> send_to_cpu;

    METADATA_DIM(1)
    METADATA_DIM(2)
    METADATA_DIM(3)
    METADATA_DIM(4)

    bit<16> ABCDE_1;
    bit<16> ABCDE_2;
    bit<16> ABCDE_3;

    bit<16> ABC_1;
    bit<16> ABC_2;
    bit<16> ABC_3;

    bit<16> BC_1;
    bit<16> BC_2;
    bit<16> BC_3;

    bit<16> CD_1;
    bit<16> CD_2;
    bit<16> CD_3;

    bit<16> BE_1;
    bit<16> BE_2;
    bit<16> BE_3;

    bit<16> DE_1;
}

#define STAGE00 6
#define STAGE01 5
#define STAGE02 4
#define STAGE03 3
#define STAGE04 2
#define STAGE05 1

#define STAGE06 0
#define STAGE07 -1
#define STAGE08 -2
#define STAGE09 -3
#define STAGE10 -4
#define STAGE11 -5

#include "parser.p4"
#include "API_S1_hash.p4"
#include "API_S2_tcam.p4"
#include "API_S3_salu.p4"
#include "API_S4_heavy.p4"

#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port


// #include "pragma.p4"

// d_1 : srcIP
// d_2 : dstIP
// d_3 : srcIP, dstIP
// d_4 : srcIP, dstIP, srcPort, dstPort
// d_5 : srcIP, dstIP, srtPort
// d_6 : srcIP, dstIP, dstPort

// cd_1 : (srcIP), (dstIP)
// cd_2 : (dstIP), (srcIP)
// cd_3 : (dstIP), (srcIP, srcPort) -> give this up
// cd_4 : (srcIP, dstIP), (dstPort)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    heavy_flowkey_storage_stage8(32w0x30243f0b) flowkey_storage;

    // stage 0
    HASH_COMPUTE_KEY32_STAGE0_16_16(32w0x6b8cb0c6) d_1_hash_call_s;
    HASH_COMPUTE_KEY32_STAGE0_16_16(32w0x6b8cb0c6) d_2_hash_call_s;
    HASH_COMPUTE_KEY32_KEY32_STAGE0_16_16(32w0x6b8cb0c6) d_3_hash_call_s;
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE0_16_16(32w0x6b8cb0c6) d_4_hash_call_s;
    HASH_COMPUTE_KEY32_KEY32_KEY16_STAGE0_16_16(32w0x30243f0b) d_6_hash_call_s;
    HASH_COMPUTE_KEY32_STAGE0_16_16(32w0x6b8cb0c3) d_1_hash_call_cs;

    // stage 1
    HASH_COMPUTE_KEY32_STAGE1_16_16(32w0x30243f0b) d_1_hash_call_1;
    HASH_COMPUTE_KEY32_STAGE1_16_16(32w0x0f79f523) d_1_hash_call_2;
    HASH_COMPUTE_KEY32_STAGE1_16_16(32w0x6b8cb0c5) d_1_hash_call_3;
    HASH_COMPUTE_KEY32_STAGE1_16_16(32w0x30243f0b) d_2_hash_call_1;
    HASH_COMPUTE_KEY32_STAGE1_16_16(32w0x0f79f523) d_2_hash_call_2;
    HASH_COMPUTE_KEY32_STAGE1_16_16(32w0x6b8cb0c5) d_2_hash_call_3;

    // stage 2
    HASH_COMPUTE_KEY32_STAGE2_16_16(32w0x6b8cb0c3) d_2_hash_call_cs;
    HASH_COMPUTE_KEY32_KEY32_STAGE2_16_16(32w0x6b8cb0c6) d_3_hash_call_s_2;
    HASH_COMPUTE_KEY32_KEY32_STAGE2_16_16(32w0x6b8cb0c3) d_3_hash_call_cs;
    HASH_COMPUTE_KEY32_KEY32_STAGE2_16_16(32w0x30243f0b) d_3_hash_call_1;
    HASH_COMPUTE_KEY32_KEY32_STAGE2_16_16(32w0x0f79f523) d_3_hash_call_2;
    HASH_COMPUTE_KEY32_KEY32_STAGE2_16_16(32w0x6b8cb0c5) d_3_hash_call_3;

    // stage 3
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE3_16_16(32w0x6b8cb0c3) d_4_hash_call_cs;
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE3_16_16(32w0x30243f0b) d_4_hash_call_1;

    // stage 4
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE4_16_16(32w0x0f79f523) d_4_hash_call_2;
    HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE4_16_16(32w0x6b8cb0c5) d_4_hash_call_3;

    action step1() {
        ig_md.BC_1 = ig_md.d_2_hash_1 ^ ig_md.d_3_hash_1;
        ig_md.BC_2 = ig_md.d_2_hash_1 ^ ig_md.d_3_hash_2;
        ig_md.BC_3 = ig_md.d_2_hash_1 ^ ig_md.d_3_hash_3;
    }

    action step2() {
        ig_md.ABC_1 = ig_md.d_1_hash_1 ^ ig_md.BC_1;
        ig_md.ABC_2 = ig_md.d_1_hash_1 ^ ig_md.BC_2;
        ig_md.ABC_3 = ig_md.d_1_hash_1 ^ ig_md.BC_3;
        ig_md.DE_1 = ig_md.d_4_hash_1 ^ ig_md.d_6_hash_s;
    }

    action step3() {
        ig_md.ABCDE_1 = ig_md.ABC_1 ^ ig_md.DE_1;
    }

    action step4() {
        ig_md.ABCDE_2 = ig_md.ABC_2 ^ ig_md.DE_1;
    }

    // action step5() {
    //     ig_md.ABCDE_3 = ig_md.ABC_3 ^ ig_md.DE_1;
    // }

    apply {
        if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            // stage 8
            // 3 SALUs
            flowkey_storage.apply(hdr, SRCIP, DSTIP, SRCIP, ig_tm_md);
        }
        else {
            // stage 0
            d_1_hash_call_1.apply(SRCIP, ig_md.d_1_hash_1);
            d_1_hash_call_2.apply(SRCIP, ig_md.d_1_hash_2);
            d_1_hash_call_3.apply(SRCIP, ig_md.d_1_hash_3);

            d_2_hash_call_1.apply(DSTIP, ig_md.d_2_hash_1);
            d_2_hash_call_2.apply(DSTIP, ig_md.d_2_hash_2);
            d_2_hash_call_3.apply(DSTIP, ig_md.d_2_hash_3);

            d_3_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_3_hash_1);
            d_3_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_3_hash_2);
            d_3_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_3_hash_3);

            d_4_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_4_hash_1);
            d_6_hash_call_s.apply(SRCIP, DSTIP, DSTPORT, ig_md.d_6_hash_s);

            step1();
            step2();
            step3();
            step4();
            // step5();
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
