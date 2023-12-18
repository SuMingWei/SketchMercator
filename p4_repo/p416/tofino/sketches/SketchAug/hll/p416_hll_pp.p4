#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

struct metadata_t {
    bit<16> epoch_index;
    bit<16> temp_index;

    bit<20> sampling_hash_value;
    bit<16> level; // 5 bit is enough (2^5 = 32 > 20)
    bit<16> index; // 11 bit is enough (2^11 = 2048)
}

#include "headers.p4"
#include "util.p4"
#include "parser.p4"

#include "API_hash.p4"
#include "API_tcam.p4"
#include "API_salu.p4"
#include "API_debug.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;

    HLL_TCAM() tcam;

    HLL_UPDATE_512() update_512_0;
    HLL_UPDATE_1024() update_1024_0;
    HLL_UPDATE_2048() update_2048_0;
    HLL_UPDATE_4096() update_4096_0;

    HLL_UPDATE_512() update_512_1;
    HLL_UPDATE_1024() update_1024_1;
    HLL_UPDATE_2048() update_2048_1;
    HLL_UPDATE_4096() update_4096_1;

    HASH_COMPUTE_20_20(32w0x790900f3) sampling_hash;
    HASH_COMPUTE_16_16(32w0x30243f0b) index_hash;

    apply {

        if(hdr.vlan_tag.isValid() && hdr.vlan_tag.ether_type == ETHERTYPE_IPV4) {
        // if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.temp_index);

            sampling_hash.apply(hdr.ipv4.src_addr, ig_md.sampling_hash_value);
            index_hash.apply(hdr.ipv4.src_addr, ig_md.index);
            tcam.apply(ig_md.sampling_hash_value, ig_md.level);

            if (ig_md.epoch_index[0:0] == 0) {
                update_512_0.apply(ig_md.index, ig_md.level);
                update_1024_0.apply(ig_md.index, ig_md.level);
                update_2048_0.apply(ig_md.index, ig_md.level);
                update_4096_0.apply(ig_md.index, ig_md.level);
            }
            else {
                update_512_1.apply(ig_md.index, ig_md.level);
                update_1024_1.apply(ig_md.index, ig_md.level);
                update_2048_1.apply(ig_md.index, ig_md.level);
                update_4096_1.apply(ig_md.index, ig_md.level);
            }
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
