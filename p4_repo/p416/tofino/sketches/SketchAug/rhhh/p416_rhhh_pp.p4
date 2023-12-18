#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

struct metadata_t {
    bit<16> epoch_index;
    bit<16> temp_index;

    bit<5> random_bits;
    bit<10> level;
    bit<16> base;
    bit<32> threshold;
    bit<32> s_mask;
    bit<32> d_mask;

    bit<32> masked_srcip;
    bit<32> masked_dstip;
    bit<64> flowkey;

    bit<16> index_1;
    bit<16> index_2;
    bit<16> index_3;
    bit<16> index_4;
    bit<16> index_5;

    // bit<5> res_all;
    bit<16> res_all;
    bit<1> res_1;
    bit<1> res_2;
    bit<1> res_3;
    bit<1> res_4;
    bit<1> res_5;

    bit<32> est_1;
    bit<32> est_2;
    bit<32> est_3;
    bit<32> est_4;
    bit<32> est_5;

    bit<1> c_1;
    bit<1> c_2;
    bit<1> c_3;
    bit<1> c_4;
    bit<1> c_5;

    bit<1> above_threshold;

    bit<32> hash_entry_srcip;
    bit<32> hash_entry_dstip;
    bit<8> hash_entry_level;
    
    bit<32> diff_srcip;
    bit<32> diff_dstip;
    bit<8> diff_level;
}

#include "headers.p4"
#include "util.p4"
#include "parser.p4"
#include "API_rand.p4"
#include "API_tcam.p4"
#include "API_hash.p4"
#include "API_salu.p4"
#include "API_debug.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    CALC_RNG() calc_rng;

    RHHH_TABLE() rhhh_table;

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;

    HASH_COMPUTE_16_SPLIT_RHHH(32w0x5b445b31) res_split;
    HASH_COMPUTE_11_ADD_BASE_RHHH(32w0x30243f0b) index_hash_1;
    HASH_COMPUTE_11_ADD_BASE_RHHH(32w0x0f79f523) index_hash_2;
    HASH_COMPUTE_11_ADD_BASE_RHHH(32w0x6b8cb0c5) index_hash_3;
    HASH_COMPUTE_11_ADD_BASE_RHHH(32w0x00390fc3) index_hash_4;

    CS_UPDATE_51200() update_1_0;
    CS_UPDATE_51200() update_2_0;
    CS_UPDATE_51200() update_3_0;
    CS_UPDATE_51200() update_4_0;

    CS_UPDATE_51200() update_1_1;
    CS_UPDATE_51200() update_2_1;
    CS_UPDATE_51200() update_3_1;
    CS_UPDATE_51200() update_4_1;

    Hash<bit<64>>(HashAlgorithm_t.IDENTITY) hash_identity;
    apply {
        if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            calc_rng.apply(ig_md.random_bits);

            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.temp_index);

            if (0 < ig_md.random_bits && ig_md.random_bits < 25) {
                rhhh_table.apply(ig_md.random_bits, ig_md.level, ig_md.base, ig_md.threshold, ig_md.s_mask, ig_md.d_mask, ig_md.masked_srcip, ig_md.masked_dstip, hdr.ipv4.src_addr, hdr.ipv4.dst_addr);
                // ig_md.masked_srcip = hdr.ipv4.src_addr & ig_md.s_mask;
                // ig_md.masked_dstip = hdr.ipv4.dst_addr & ig_md.d_mask;

                res_split.apply(ig_md.masked_srcip, ig_md.masked_dstip, ig_md.res_all,
                                ig_md.res_1,
                                ig_md.res_2,
                                ig_md.res_3,
                                ig_md.res_4,
                                ig_md.res_5);

                index_hash_1.apply(ig_md.masked_srcip, ig_md.masked_dstip, ig_md.base, ig_md.index_1);
                index_hash_2.apply(ig_md.masked_srcip, ig_md.masked_dstip, ig_md.base, ig_md.index_2);
                index_hash_3.apply(ig_md.masked_srcip, ig_md.masked_dstip, ig_md.base, ig_md.index_3);
                index_hash_4.apply(ig_md.masked_srcip, ig_md.masked_dstip, ig_md.base, ig_md.index_4);

                if (ig_md.epoch_index[0:0] == 0) {
                    update_1_0.apply(ig_md.index_1, ig_md.res_1, ig_md.est_1);
                    update_2_0.apply(ig_md.index_2, ig_md.res_2, ig_md.est_2);
                    update_3_0.apply(ig_md.index_3, ig_md.res_3, ig_md.est_3);
                    update_4_0.apply(ig_md.index_4, ig_md.res_4, ig_md.est_4);
                }
                else {
                    update_1_1.apply(ig_md.index_1, ig_md.res_1, ig_md.est_1);
                    update_2_1.apply(ig_md.index_2, ig_md.res_2, ig_md.est_2);
                    update_3_1.apply(ig_md.index_3, ig_md.res_3, ig_md.est_3);
                    update_4_1.apply(ig_md.index_4, ig_md.res_4, ig_md.est_4);
                }
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
