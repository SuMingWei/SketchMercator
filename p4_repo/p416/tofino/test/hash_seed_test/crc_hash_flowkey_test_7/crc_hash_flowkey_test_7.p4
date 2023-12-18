#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "../common/headers.p4"
#include "../common/util.p4"

struct metadata_t {
    bit<11> index_1;
}

#include "../common/parser.p4"

control HASH_COMPUTE_11(
  in ipv4_addr_t srcIP,
  in bit<16> src_port,
  in ipv4_addr_t dstIP,
  in bit<16> dst_port,
  in bit<8> proto,
  out bit<11> result)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                           true,
                           false,
                           false,
                           32w0xFFFFFFFF,
                           32w0xFFFFFFFF
                           ) poly1;

    Hash<bit<11>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action action_hash() {
        // result = (bit<16>) hash.get({srcIP[31:0], dstIP[31:0]});
        result = hash.get({srcIP, src_port, dstIP});
    }

    table tbl_hash {
        actions = {
            action_hash;
        }
        const default_action = action_hash();
    }

   apply {
        tbl_hash.apply();
    }
}

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    HASH_COMPUTE_11(32w0x30243f0b) index_hash_1;

    apply {
        index_hash_1.apply(hdr.ipv4.src_addr, hdr.tcp.src_port, hdr.ipv4.dst_addr, hdr.tcp.dst_port, hdr.ipv4.protocol, ig_md.index_1);
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
