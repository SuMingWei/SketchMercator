#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_SETUP(D) \
    bit<16> sampling_hash_value_##D##;\
    bit<16> level_##D##;\
    bit<16> base_##D##;\
    bit<32> threshold_##D##;\
    bit<16> index_1_##D##;\
    bit<16> index_2_##D##;\
    bit<16> index_3_##D##;\
    bit<16> index_4_##D##;\
    bit<16> index_5_##D##;\
    bit<16> res_all_##D##;\
    bit<1> res_1_##D##;\
    bit<1> res_2_##D##;\
    bit<1> res_3_##D##;\
    bit<1> res_4_##D##;\
    bit<1> res_5_##D##;\
    bit<32> est_1_##D##;\
    bit<32> est_2_##D##;\
    bit<32> est_3_##D##;\
    bit<32> est_4_##D##;\
    bit<32> est_5_##D##;\
    bit<16> base_1_##D##;\
    bit<16> base_2_##D##;\
    bit<16> base_3_##D##;\
    bit<16> base_4_##D##;\
    bit<16> base_5_##D##;\
    bit<16> mem_index_1_##D##;\
    bit<16> mem_index_2_##D##;\
    bit<16> mem_index_3_##D##;\
    bit<16> mem_index_4_##D##;\
    bit<16> mem_index_5_##D##;

#define CONTROL_SETUP(D) \
    lpm_optimization() tcam_##D##;\
    HASH_COMPUTE_SRCIP_16_16(32w0x790900f3) sampling_hash_##D##;\
    hash_consolidate_and_split_srcip(32w0x5b445b31) res_split_##D##;\
    HASH_COMPUTE_SRCIP_16_11(32w0x30243f0b) index_hash_1_##D##;\
    HASH_COMPUTE_SRCIP_16_11(32w0x0f79f523) index_hash_2_##D##;\
    HASH_COMPUTE_SRCIP_16_11(32w0x6b8cb0c5) index_hash_3_##D##;\
    HASH_COMPUTE_SRCIP_16_11(32w0x00390fc3) index_hash_4_##D##;\
    HASH_COMPUTE_SRCIP_16_11(32w0x298ac673) index_hash_5_##D##;\
    consolidate_update_univmon() update_1_##D##;\
    consolidate_update_univmon() update_2_##D##;\
    consolidate_update_univmon() update_3_##D##;\
    consolidate_update_univmon() update_4_##D##;\
    consolidate_update_univmon() update_5_##D##;

#define APPLY_SETUP(FLOWKEY, D) \
        sampling_hash_##D##.apply(##FLOWKEY##, ig_md.sampling_hash_value_##D##);\
        tcam_##D##.apply(ig_md.sampling_hash_value_##D##, ig_md.level_##D##, ig_md.base_##D##, ig_md.threshold_##D##);\
        res_split_##D##.apply(##FLOWKEY##, ig_md.res_all_##D##,\
                        ig_md.res_1_##D##,\
                        ig_md.res_2_##D##,\
                        ig_md.res_3_##D##,\
                        ig_md.res_4_##D##,\
                        ig_md.res_5_##D##);\
        index_hash_1_##D##.apply(##FLOWKEY##, ig_md.index_1_##D##);\
        index_hash_2_##D##.apply(##FLOWKEY##, ig_md.index_2_##D##);\
        index_hash_3_##D##.apply(##FLOWKEY##, ig_md.index_3_##D##);\
        index_hash_4_##D##.apply(##FLOWKEY##, ig_md.index_4_##D##);\
        index_hash_5_##D##.apply(##FLOWKEY##, ig_md.index_5_##D##);\
        update_1_##D##.apply(ig_md.index_1_##D##, ig_md.res_1_##D##, ig_md.level_##D##, ig_md.base_1_##D##, ig_md.mem_index_1_##D##, ig_md.est_1_##D##);\
        update_2_##D##.apply(ig_md.index_2_##D##, ig_md.res_2_##D##, ig_md.level_##D##, ig_md.base_2_##D##, ig_md.mem_index_2_##D##, ig_md.est_2_##D##);\
        update_3_##D##.apply(ig_md.index_3_##D##, ig_md.res_3_##D##, ig_md.level_##D##, ig_md.base_3_##D##, ig_md.mem_index_3_##D##, ig_md.est_3_##D##);\
        update_4_##D##.apply(ig_md.index_4_##D##, ig_md.res_4_##D##, ig_md.level_##D##, ig_md.base_4_##D##, ig_md.mem_index_4_##D##, ig_md.est_4_##D##);\
        update_5_##D##.apply(ig_md.index_5_##D##, ig_md.res_5_##D##, ig_md.level_##D##, ig_md.base_5_##D##, ig_md.mem_index_5_##D##, ig_md.est_5_##D##);


struct metadata_t {
    #if DIM >= 1
        METADATA_SETUP(1)
    #endif

    #if DIM >= 2
        METADATA_SETUP(2)
    #endif

    #if DIM >= 3
        METADATA_SETUP(3)
    #endif

    #if DIM >= 4
        METADATA_SETUP(4)
    #endif

    #if DIM >= 5
        METADATA_SETUP(5)
    #endif
}

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

    #if DIM >= 1
        CONTROL_SETUP(1)
    #endif

    #if DIM >= 2
        CONTROL_SETUP(2)
    #endif

    #if DIM >= 3
        CONTROL_SETUP(3)
    #endif

    #if DIM >= 4
        CONTROL_SETUP(4)
    #endif

    #if DIM >= 5
        CONTROL_SETUP(5)
    #endif

    apply {
        // APPLY_SETUP(hdr.ipv4.src_addr, 1)
        #if DIM >= 1
            APPLY_SETUP(hdr.ipv4.src_addr, 1)
        #endif

        #if DIM >= 2
            APPLY_SETUP(hdr.ipv4.dst_addr, 2)
        #endif

        #if DIM >= 3
            APPLY_SETUP((bit<32>)hdr.ipv4.protocol, 3)
        #endif

        #if DIM >= 4
            APPLY_SETUP((bit<32>)hdr.ipv4.ttl, 4)
        #endif

        #if DIM >= 5
            APPLY_SETUP((bit<32>)hdr.ipv4.identification, 5)
        #endif
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
