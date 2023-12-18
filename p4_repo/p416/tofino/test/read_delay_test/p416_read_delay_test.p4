#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "common_p4/headers.p4"
#include "common_p4/util.p4"

struct metadata_t {
    bit<32> index_1;
    bit<1> est_1;
    bit<32> est_32;
}

#include "common_p4/parser.p4"
#include "hash.p4"
#include "salu.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    HASH_COMPUTE_32(32w0x30243f0b) index_hash_1;

    CS_UPDATE_4096_1() update_4096_1;
    CS_UPDATE_8192_1() update_8192_1;
    CS_UPDATE_12288_1() update_12288_1;
    CS_UPDATE_16384_1() update_16384_1;
    CS_UPDATE_20480_1() update_20480_1;
    CS_UPDATE_32768_1() update_32768_1;
    CS_UPDATE_36864_1() update_36864_1;
    CS_UPDATE_65536_1() update_65536_1;
    // CS_UPDATE_131072_1() update_131072_1;

    CS_UPDATE_4096_32() update_4096_32;
    CS_UPDATE_8192_32() update_8192_32;
    CS_UPDATE_12288_32() update_12288_32;
    CS_UPDATE_16384_32() update_16384_32;
    CS_UPDATE_20480_32() update_20480_32;
    CS_UPDATE_32768_32() update_32768_32;
    CS_UPDATE_36864_32() update_36864_32;
    CS_UPDATE_65536_32() update_65536_32;
    // CS_UPDATE_131072_32() update_131072_32;

    // CS_UPDATE_4096_64() update_4096_64;
    // CS_UPDATE_8192_64() update_8192_64;
    // CS_UPDATE_12288_64() update_12288_64;
    // CS_UPDATE_16384_64() update_16384_64;
    // CS_UPDATE_20480_64() update_20480_64;
    // CS_UPDATE_32768_64() update_32768_64;
    // CS_UPDATE_36864_64() update_36864_64;
    // CS_UPDATE_65536_64() update_65536_64;
    // // CS_UPDATE_131072_64() update_131072_64;

    apply {
        if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            index_hash_1.apply(hdr.ipv4.src_addr, ig_md.index_1);

            update_4096_1.apply(ig_md.index_1);
            update_8192_1.apply(ig_md.index_1);
            update_12288_1.apply(ig_md.index_1);
            update_16384_1.apply(ig_md.index_1);
            update_20480_1.apply(ig_md.index_1);
            update_32768_1.apply(ig_md.index_1);
            update_36864_1.apply(ig_md.index_1);
            update_65536_1.apply(ig_md.index_1);
            // update_131072_1.apply(ig_md.index_1);

            update_4096_32.apply(ig_md.index_1);
            update_8192_32.apply(ig_md.index_1);
            update_12288_32.apply(ig_md.index_1);
            update_16384_32.apply(ig_md.index_1);
            update_20480_32.apply(ig_md.index_1);
            update_32768_32.apply(ig_md.index_1);
            update_36864_32.apply(ig_md.index_1);
            update_65536_32.apply(ig_md.index_1);
            // update_131072_32.apply(ig_md.index_1);

            // update_4096_64.apply(ig_md.index_1);
            // update_8192_64.apply(ig_md.index_1);
            // update_12288_64.apply(ig_md.index_1);
            // update_16384_64.apply(ig_md.index_1);
            // update_20480_64.apply(ig_md.index_1);
            // update_32768_64.apply(ig_md.index_1);
            // update_36864_64.apply(ig_md.index_1);
            // update_65536_64.apply(ig_md.index_1);
            // // update_131072_64.apply(ig_md.index_1);
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
