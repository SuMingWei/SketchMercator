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

control WORKLOAD2_THRESHOLD(
    inout header_t hdr,
    inout metadata_t ig_md)
{
    action tbl_get_threshold_act (bit<32> threshold_6, bit<32> threshold_7, bit<32> threshold_8) {
        ig_md.d_6_threshold = threshold_6;
        ig_md.d_7_threshold = threshold_7;
        ig_md.d_8_threshold = threshold_8;
    }
    table tbl_get_threshold {
        key = {
            hdr.ethernet.ether_type : exact;
        }
        actions = {
            tbl_get_threshold_act;
        }
    }
    apply {
        tbl_get_threshold.apply();
    }
}



control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    T1_INIT_3_WITH_POLY( 1, 110, 131072, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5)
    MRB_INIT_1_WITH_POLY( 2, 110, 131072, 14, 16, 32w0x790900f3, 32w0x30243f0b)
    MRB_INIT_1_WITH_POLY( 3, 110, 262144, 14, 16, 32w0x790900f3, 32w0x30243f0b)
    T2_INIT_4_WITH_POLY( 4, 110, 4096, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3)
    T2_INIT_3_WITH_POLY( 5, 110, 16384, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5)
    T2_INIT_HH_3_THRESHOLD( 6, 110, 4096, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3)
    T3_INIT_HH_3_WITH_POLY( 7, 110, 16384, 32w0x5b445b31, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3)
    T2_INIT_HH_1_THRESHOLD( 8, 110, 4096, 32w0x30243f0b, 32w0x0f79f523)
    MRAC_INIT_1_WITH_POLY( 9, 110, 16384, 11, 16, 32w0x790900f3, 32w0x30243f0b)
    MRAC_INIT_1_WITH_POLY(10, 110, 16384, 11, 16, 32w0x790900f3, 32w0x30243f0b)



    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;
    WORKLOAD2_THRESHOLD() threshold;
    action init() {
        ig_md.d_6_above_threshold = 0;
        ig_md.d_7_above_threshold = 0;
        ig_md.d_8_above_threshold = 0;
    }

    apply {
        if (hdr.tcp.isValid() || hdr.udp.isValid()) {
            init();
            threshold.apply(hdr, ig_md);
            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.epoch_count);
            if(ig_md.epoch_count == 1) {
                ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
            }

            T1_RUN_3_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
            MRB_RUN_1_KEY_2( 2, DSTIP, DSTPORT)
            MRB_RUN_1_KEY_2( 3, DSTIP, DSTPORT)
            T2_RUN_4_KEY_2( 4, DSTIP, DSTPORT, 1)
            T2_RUN_3_KEY_2( 5, DSTIP, DSTPORT, 1)
            T2_RUN_HH_3_KEY_2( 6, DSTIP, DSTPORT, SIZE)
            T3_RUN_HH_3_KEY_2( 7, DSTIP, DSTPORT, 1)
            T2_RUN_HH_1_KEY_2( 8, DSTIP, DSTPORT, SIZE)

            d_9_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_9_sampling_hash_16);
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_9_index1_16);
            update_9_1.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);

            d_10_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_sampling_hash_16);
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_10_index1_16);
            update_10_1.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        }
    }
}

struct heavy_flowkey_digest_t {
    bit<16> epoch_index;
    bit<32> epoch_count;
    bit<32> dst_addr;
    bit<16> dst_port;
    bit<1> i06;
    bit<1> i07;
    bit<1> i08;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.epoch_index, ig_md.epoch_count, DSTIP, DSTPORT, ig_md.d_6_above_threshold, ig_md.d_7_above_threshold, ig_md.d_8_above_threshold});
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