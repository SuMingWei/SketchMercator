#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

struct metadata_t {
    bit<16> epoch_index;
    bit<16> temp_index;

    bit<16> sampling_hash_value;
    bit<10> level;
    bit<16> base;
    bit<32> threshold;

    bit<16> index_1;
    bit<16> index_2;
    bit<16> index_3;
    bit<16> index_4;

    // bit<5> res_all;
    bit<16> res_all;
    bit<1> res_1;
    bit<1> res_2;
    bit<1> res_3;
    bit<1> res_4;
    bit<1> res_5;

    bit<32> est_1024_1;
    bit<32> est_1024_2;
    bit<32> est_1024_3;
    bit<32> est_1024_4;

    bit<32> est_2048_1;
    bit<32> est_2048_2;
    bit<32> est_2048_3;
    bit<32> est_2048_4;

    bit<32> est_4096_1;
    bit<32> est_4096_2;
    bit<32> est_4096_3;
    bit<32> est_4096_4;

    bit<32> est_8192_1;
    bit<32> est_8192_2;
    bit<32> est_8192_3;
    bit<32> est_8192_4;

    bit<32> est_16384_1;
    bit<32> est_16384_2;
    bit<32> est_16384_3;
    bit<32> est_16384_4;

}

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

    HASH_COMPUTE_16_SPLIT(32w0x5b445b31) res_split;
    HASH_COMPUTE_16_16(32w0x30243f0b) index_hash_1;
    HASH_COMPUTE_16_16(32w0x0f79f523) index_hash_2;
    HASH_COMPUTE_16_16(32w0x6b8cb0c5) index_hash_3;
    HASH_COMPUTE_16_16(32w0x00390fc3) index_hash_4;

    CS_UPDATE_16384() update_16384_1_0;
    CS_UPDATE_16384() update_16384_2_0;
    CS_UPDATE_16384() update_16384_3_0;
    CS_UPDATE_16384() update_16384_4_0;

    CS_UPDATE_16384() update_16384_1_1;
    CS_UPDATE_16384() update_16384_2_1;
    CS_UPDATE_16384() update_16384_3_1;
    CS_UPDATE_16384() update_16384_4_1;

    apply {

        if(hdr.vlan_tag.isValid() && hdr.vlan_tag.ether_type == ETHERTYPE_IPV4) {
        // if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.temp_index);

            res_split.apply(hdr.ipv4.src_addr, ig_md.res_all,
                            ig_md.res_1,
                            ig_md.res_2,
                            ig_md.res_3,
                            ig_md.res_4,
                            ig_md.res_5);

            index_hash_1.apply(hdr.ipv4.src_addr, ig_md.index_1);
            index_hash_2.apply(hdr.ipv4.src_addr, ig_md.index_2);
            index_hash_3.apply(hdr.ipv4.src_addr, ig_md.index_3);
            index_hash_4.apply(hdr.ipv4.src_addr, ig_md.index_4);

            if (ig_md.epoch_index[0:0] == 0) {
                update_16384_1_0.apply(ig_md.index_1, ig_md.res_1, ig_md.est_16384_1);
                update_16384_2_0.apply(ig_md.index_2, ig_md.res_2, ig_md.est_16384_2);
                update_16384_3_0.apply(ig_md.index_3, ig_md.res_3, ig_md.est_16384_3);
                update_16384_4_0.apply(ig_md.index_4, ig_md.res_4, ig_md.est_16384_4);
            }
            else {
                update_16384_1_1.apply(ig_md.index_1, ig_md.res_1, ig_md.est_16384_1);
                update_16384_2_1.apply(ig_md.index_2, ig_md.res_2, ig_md.est_16384_2);
                update_16384_3_1.apply(ig_md.index_3, ig_md.res_3, ig_md.est_16384_3);
                update_16384_4_1.apply(ig_md.index_4, ig_md.res_4, ig_md.est_16384_4);
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

