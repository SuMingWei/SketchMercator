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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {


    #if HASH_SET == 1
        T2_INIT_HH_1_THRESHOLD( 1, 100, 4096, 28914, 32w0x30243f0b, 32w0x0f79f523)
        T2_INIT_HH_5_THRESHOLD( 2, 100, 16384, 8428272, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673, 32w0x60180d91)
        T2_INIT_HH_2_THRESHOLD( 3, 200, 16384, 13662376, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5)
        T2_INIT_HH_5_THRESHOLD( 4, 110, 8192, 22335457, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673, 32w0x60180d91)
        T2_INIT_HH_2_THRESHOLD( 5, 110, 4096, 9578549, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5)
        T2_INIT_HH_5_THRESHOLD( 6, 221, 8192, 14192, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673, 32w0x60180d91)
        HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x60180d91) heavy_flowkey_storage;
    #elif HASH_SET == 2
        T2_INIT_HH_1_THRESHOLD( 1, 100, 4096, 28914, 32w0x0a9d4719, 32w0x527f2ab1)
        T2_INIT_HH_5_THRESHOLD( 2, 100, 16384, 8428272, 32w0x0a9d4719, 32w0x527f2ab1, 32w0x503e1855, 32w0x36a7edfd, 32w0x009cbd15, 32w0x57857ba5)
        T2_INIT_HH_2_THRESHOLD( 3, 200, 16384, 13662376, 32w0x0a9d4719, 32w0x527f2ab1, 32w0x503e1855)
        T2_INIT_HH_5_THRESHOLD( 4, 110, 8192, 22335457, 32w0x0a9d4719, 32w0x527f2ab1, 32w0x503e1855, 32w0x36a7edfd, 32w0x009cbd15, 32w0x57857ba5)
        T2_INIT_HH_2_THRESHOLD( 5, 110, 4096, 9578549, 32w0x0a9d4719, 32w0x527f2ab1, 32w0x503e1855)
        T2_INIT_HH_5_THRESHOLD( 6, 221, 8192, 14192, 32w0x0a9d4719, 32w0x527f2ab1, 32w0x503e1855, 32w0x36a7edfd, 32w0x009cbd15, 32w0x57857ba5)
        HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x57857ba5) heavy_flowkey_storage;
    #elif HASH_SET == 3
        T2_INIT_HH_1_THRESHOLD( 1, 100, 4096, 28914, 32w0x6fbf2213, 32w0x7a9d09a3)
        T2_INIT_HH_5_THRESHOLD( 2, 100, 16384, 8428272, 32w0x6fbf2213, 32w0x7a9d09a3, 32w0x4e303003, 32w0x09b68d7b, 32w0x439e0185, 32w0x27d744bd)
        T2_INIT_HH_2_THRESHOLD( 3, 200, 16384, 13662376, 32w0x6fbf2213, 32w0x7a9d09a3, 32w0x4e303003)
        T2_INIT_HH_5_THRESHOLD( 4, 110, 8192, 22335457, 32w0x6fbf2213, 32w0x7a9d09a3, 32w0x4e303003, 32w0x09b68d7b, 32w0x439e0185, 32w0x27d744bd)
        T2_INIT_HH_2_THRESHOLD( 5, 110, 4096, 9578549, 32w0x6fbf2213, 32w0x7a9d09a3, 32w0x4e303003)
        T2_INIT_HH_5_THRESHOLD( 6, 221, 8192, 14192, 32w0x6fbf2213, 32w0x7a9d09a3, 32w0x4e303003, 32w0x09b68d7b, 32w0x439e0185, 32w0x27d744bd)
        HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x27d744bd) heavy_flowkey_storage;
    #elif HASH_SET == 4
        T2_INIT_HH_1_THRESHOLD( 1, 100, 4096, 28914, 32w0x63986f65, 32w0x16261f2d)
        T2_INIT_HH_5_THRESHOLD( 2, 100, 16384, 8428272, 32w0x63986f65, 32w0x16261f2d, 32w0x67c781ad, 32w0x409900cd, 32w0x08123a4d, 32w0x7a2db5bd)
        T2_INIT_HH_2_THRESHOLD( 3, 200, 16384, 13662376, 32w0x63986f65, 32w0x16261f2d, 32w0x67c781ad)
        T2_INIT_HH_5_THRESHOLD( 4, 110, 8192, 22335457, 32w0x63986f65, 32w0x16261f2d, 32w0x67c781ad, 32w0x409900cd, 32w0x08123a4d, 32w0x7a2db5bd)
        T2_INIT_HH_2_THRESHOLD( 5, 110, 4096, 9578549, 32w0x63986f65, 32w0x16261f2d, 32w0x67c781ad)
        T2_INIT_HH_5_THRESHOLD( 6, 221, 8192, 14192, 32w0x63986f65, 32w0x16261f2d, 32w0x67c781ad, 32w0x409900cd, 32w0x08123a4d, 32w0x7a2db5bd)
        HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x7a2db5bd) heavy_flowkey_storage;
    #elif HASH_SET == 5
        T2_INIT_HH_1_THRESHOLD( 1, 100, 4096, 28914, 32w0x67bb5cbf, 32w0x01891da9)
        T2_INIT_HH_5_THRESHOLD( 2, 100, 16384, 8428272, 32w0x67bb5cbf, 32w0x01891da9, 32w0x234e0cc5, 32w0x24db30cb, 32w0x148238a5, 32w0x783aab09)
        T2_INIT_HH_2_THRESHOLD( 3, 200, 16384, 13662376, 32w0x67bb5cbf, 32w0x01891da9, 32w0x234e0cc5)
        T2_INIT_HH_5_THRESHOLD( 4, 110, 8192, 22335457, 32w0x67bb5cbf, 32w0x01891da9, 32w0x234e0cc5, 32w0x24db30cb, 32w0x148238a5, 32w0x783aab09)
        T2_INIT_HH_2_THRESHOLD( 5, 110, 4096, 9578549, 32w0x67bb5cbf, 32w0x01891da9, 32w0x234e0cc5)
        T2_INIT_HH_5_THRESHOLD( 6, 221, 8192, 14192, 32w0x67bb5cbf, 32w0x01891da9, 32w0x234e0cc5, 32w0x24db30cb, 32w0x148238a5, 32w0x783aab09)
        HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x783aab09) heavy_flowkey_storage;
    #endif

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;
    action init() {
        ig_md.hf_srcip = -1;
        ig_md.hf_dstip = -1;
        ig_md.hf_srcport = -1;
        ig_md.hf_dstport = -1;
        ig_md.hf_proto = -1;

        ig_md.d_1_above_threshold = 0;
        ig_md.d_2_above_threshold = 0;
        ig_md.d_3_above_threshold = 0;
        ig_md.d_4_above_threshold = 0;
        ig_md.d_5_above_threshold = 0;
        ig_md.d_6_above_threshold = 0;
    }
    apply {
        if (hdr.tcp.isValid() || hdr.udp.isValid()) {
            init();
            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.epoch_count);
            if(ig_md.epoch_count == 1) {
                ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
            }

            T2_RUN_AFTER_1_KEY_1( 1, SRCIP, 1)
            T2_RUN_AFTER_5_KEY_1( 2, SRCIP, SIZE)
            T2_RUN_AFTER_2_KEY_2( 3, SRCIP, DSTIP, SIZE)
            T2_RUN_AFTER_5_KEY_2( 4, SRCIP, SRCPORT, SIZE)
            T2_RUN_AFTER_2_KEY_2( 5, DSTIP, DSTPORT, SIZE)
            T2_RUN_AFTER_5_KEY_5( 6, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

            if(
            ig_md.d_1_above_threshold == 1
            || ig_md.d_2_above_threshold == 1
            || ig_md.d_3_above_threshold == 1
            || ig_md.d_4_above_threshold == 1
            || ig_md.d_6_above_threshold == 1
            ) {
                ig_md.hf_srcip = SRCIP; 
            }
            if(
            ig_md.d_3_above_threshold == 1
            || ig_md.d_5_above_threshold == 1
            || ig_md.d_6_above_threshold == 1
            ) {
                ig_md.hf_dstip = DSTIP; 
            }
            if(
            ig_md.d_4_above_threshold == 1
            || ig_md.d_6_above_threshold == 1
            ) {
                ig_md.hf_srcport = SRCPORT; 
            }
            if(
            ig_md.d_5_above_threshold == 1
            || ig_md.d_6_above_threshold == 1
            ) {
                ig_md.hf_dstport = DSTPORT; 
            }
            if(
            ig_md.d_6_above_threshold == 1
            ) {
                ig_md.hf_proto = PROTO; 
            }
            if(
            ig_md.d_1_above_threshold == 1
            || ig_md.d_2_above_threshold == 1
            || ig_md.d_3_above_threshold == 1
            || ig_md.d_4_above_threshold == 1
            || ig_md.d_5_above_threshold == 1
            || ig_md.d_6_above_threshold == 1
            ) {
                heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport, ig_md.hf_proto); 
            }
        }
    }
}

struct heavy_flowkey_digest_t {
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<16> src_port;
    bit<16> dst_port;
    bit<8> proto;
    bit<16> epoch_index;
    bit<32> epoch_count;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport, ig_md.hf_proto, ig_md.epoch_index, ig_md.epoch_count});
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