#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif
#include "headers.p4"
#include "util.p4"
#include "metadata.p4"
struct metadata_t {
    bit<16> epoch_index;
    bit<32> epoch_count;
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
}

#include "parser.p4"
#include "all_include.p4"
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

// SAMPLING: 32w0x790900f3
// RES: 32w0x5b445b31
// set1 = [
// "32w0x30243f0b",
// "32w0x0f79f523",
// "32w0x6b8cb0c5",
// "32w0x00390fc3",
// "32w0x298ac673",
// "32w0x60180d91"]


    T1_INIT_5_WITH_POLY( 1, 100, 262144, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673)
    // T4_INIT_1_WITH_POLY( 2, 100, 65536, 32w0x790900f3, 32w0x30243f0b)
    T4_INIT_1_WITH_POLY( 2, 100, 16384, 32w0x790900f3, 32w0x30243f0b)
    // UM_INIT_5_WITH_POLY( 3, 100, 11, 32768, 32w0x790900f3, 32w0x5b445b31, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673, 32w0x60180d91)
    UM_INIT_3_WITH_POLY( 3, 100, 11, 32768, 32w0x790900f3, 32w0x5b445b31, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3)
    T1_INIT_4_WITH_POLY( 4, 200, 524288, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3)
    T2_INIT_2_WITH_POLY( 5, 200, 8192, 32w0x30243f0b, 32w0x0f79f523)
    MRAC_INIT_1_WITH_POLY( 6, 200, 16384, 11,  16, 32w0x790900f3, 32w0x30243f0b)
    // UM_INIT_5_WITH_POLY( 7, 200, 11, 32768, 32w0x790900f3, 32w0x5b445b31, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673, 32w0x60180d91)
    UM_INIT_4_WITH_POLY( 7, 200, 11, 32768, 32w0x790900f3, 32w0x5b445b31, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673)
    // T4_INIT_1_WITH_POLY( 8, 110, 65536, 32w0x790900f3, 32w0x30243f0b)
    T4_INIT_1_WITH_POLY( 8, 110, 16384, 32w0x790900f3, 32w0x30243f0b)
    T5_INIT_1_WITH_POLY( 9, 110, 8192, 32w0x790900f3, 32w0x30243f0b)
    T2_INIT_2_WITH_POLY(10, 110, 16384, 32w0x30243f0b, 32w0x0f79f523)

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;
    action init() {
        ig_md.d_3_above_threshold = 0;
        ig_md.d_7_above_threshold = 0;
    }


    apply {
        if (hdr.tcp.isValid() || hdr.udp.isValid()) {
            init();
            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.epoch_count);
            if(ig_md.epoch_count == 1) {
                ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
            }
            // UM_RUN_5_KEY_2( 7, SRCIP, DSTIP, 1)
            UM_RUN_4_KEY_2( 7, SRCIP, DSTIP, 1)
            T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
            T4_RUN_1_KEY_1( 2, DSTIP)
            // UM_RUN_5_KEY_1( 3, DSTIP, 1)
            UM_RUN_3_KEY_1( 3, DSTIP, 1)
            T1_RUN_4_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
            T2_RUN_2_KEY_2( 5, SRCIP, DSTIP, 1)
            MRAC_RUN_1_KEY_2( 6, SRCIP, DSTIP)
            T4_RUN_1_KEY_2( 8, DSTIP, DSTPORT)
            T5_RUN_1_KEY_2( 9, DSTIP, DSTPORT)
            T2_RUN_2_KEY_2(10, DSTIP, DSTPORT, 1)
        }
    }
}

struct heavy_flowkey_digest_t {
    bit<16> epoch_index;
    bit<32> epoch_count;
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<1> i03;
    bit<1> i07;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.epoch_index, ig_md.epoch_count, SRCIP, DSTIP, ig_md.d_3_above_threshold, ig_md.d_7_above_threshold});
        }
        pkt.emit(hdr);
    }
}


struct my_egress_headers_t {}
struct my_egress_metadata_t {}
parser EgressParser(packet_in        pkt,
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    out egress_intrinsic_metadata_t  eg_intr_md)
{
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
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
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