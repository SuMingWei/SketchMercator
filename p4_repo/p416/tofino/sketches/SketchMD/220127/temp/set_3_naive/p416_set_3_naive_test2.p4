#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;

    // UM
    bit<32> um_threshold;
    bit<16> um_sample_hash;
    bit<32> um_level;
    bit<32> um_est_1;
    bit<32> um_est_2;
    bit<32> um_est_3;
    bit<32> um_hash_1;
    bit<32> um_hash_2;
    bit<32> um_hash_3;
    bit<32> um_base_1;
    bit<32> um_base_2;
    bit<32> um_base_3;
    bit<32> um_mem_index_1;
    bit<32> um_mem_index_2;
    bit<32> um_mem_index_3;
    bit<1> um_c_1;
    bit<1> um_c_2;
    bit<1> um_c_3;
    bit<1> um_above_threshold;

    // SS
    bit<32> ss_xy_hash;
    bit<32> ss_level;
    bit<32> ss_short_level;
    bit<32> ss_hash_1;
    bit<32> ss_hash_2;
    bit<32> ss_hash_3;
    bit<32> ss_base_1_1;
    bit<32> ss_base_2_1;
    bit<32> ss_base_3_1;
    bit<32> ss_base_1_2;
    bit<32> ss_base_2_2;
    bit<32> ss_base_3_2;
    bit<32> ss_mem_index_1;
    bit<32> ss_mem_index_2;
    bit<32> ss_mem_index_3;

    bit<1> kary_epoch;
    bit<32> kary_threshold;
    bit<32> cm_threshold;
}

#include "parser.p4"
#include "API_S1_hash.p4"
#include "API_S2_tcam.p4"
#include "API_S3_salu.p4"
#include "API_S4_heavy.p4"
#include "API_threshold.p4"

#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

        GET_THRESHOLD() get_threshold;

        // UM
        HASH_COMPUTE_KEY32_16_16(32w0x30243f0b) um_sampling_hash_call;
        lpm_optimization_16() um_lpm;
        HASH_COMPUTE_KEY32_32_16(32w0x30243f0b) um_hash_call_1;
        HASH_COMPUTE_KEY32_32_10(32w0x0f79f523) um_hash_call_2;
        HASH_COMPUTE_KEY32_32_10(32w0x6b8cb0c5) um_hash_call_3;
        UM_UPDATE() um_update_1;
        UM_UPDATE() um_update_2;
        UM_UPDATE() um_update_3;
        heavy_flowkey_storage_key32_3(32w0x790900f3) um_store_flowkey;

        // SS
        HASH_COMPUTE_KEY32_KEY32_32_32(32w0x30243f0b) ss_xy_hash_call;
        lpm_optimization_32() ss_lpm;

        HASH_COMPUTE_KEY32_32_11(32w0x30243f0b) ss_hash_call_1;
        HASH_COMPUTE_KEY32_32_11(32w0x0f79f523) ss_hash_call_2;
        HASH_COMPUTE_KEY32_32_11(32w0x6b8cb0c5) ss_hash_call_3;

        SS_UPDATE() ss_update_1;
        SS_UPDATE() ss_update_2;
        SS_UPDATE() ss_update_3;

        SS_UPDATE_LOG() ss_update_log_1;
        SS_UPDATE_LOG() ss_update_log_2;
        SS_UPDATE_LOG() ss_update_log_3;

    apply {
        get_threshold.apply(hdr, ig_md);

        // SS
        // stage 0
        ss_xy_hash_call.apply(SRCIP, DSTIP, ig_md.ss_xy_hash);
        ss_hash_call_1.apply(SRCIP, ig_md.ss_hash_1);
        ss_hash_call_2.apply(SRCIP, ig_md.ss_hash_2);
        ss_hash_call_3.apply(SRCIP, ig_md.ss_hash_3);

        // stage 1
        ss_lpm.apply(ig_md.ss_xy_hash, ig_md.ss_level);
        ig_md.ss_short_level = ig_md.ss_level;
        if(ig_md.ss_level > 3) {
            ig_md.ss_short_level = 4;
        }

        // stage 2
        ss_update_log_1.apply(SRCIP, ig_md.ss_hash_1, ig_md.ss_level);
        ss_update_log_2.apply(SRCIP, ig_md.ss_hash_2, ig_md.ss_level);
        ss_update_log_3.apply(SRCIP, ig_md.ss_hash_3, ig_md.ss_level);

        // stage 6 (stage 5 expected, but it is fine for now)
        ss_update_1.apply(ig_md.ss_hash_1, ig_md.ss_xy_hash, ig_md.ss_short_level, ig_md.ss_base_1_1, ig_md.ss_base_1_2, ig_md.ss_mem_index_1);
        ss_update_2.apply(ig_md.ss_hash_2, ig_md.ss_xy_hash, ig_md.ss_short_level, ig_md.ss_base_2_1, ig_md.ss_base_2_2, ig_md.ss_mem_index_2);
        ss_update_3.apply(ig_md.ss_hash_3, ig_md.ss_xy_hash, ig_md.ss_short_level, ig_md.ss_base_3_1, ig_md.ss_base_3_2, ig_md.ss_mem_index_3);

        // UM
        um_sampling_hash_call.apply(SRCIP, ig_md.um_sample_hash);
        um_lpm.apply(ig_md.um_sample_hash, ig_md.um_level);
        um_hash_call_1.apply(SRCIP, ig_md.um_hash_1);
        um_hash_call_2.apply(SRCIP, ig_md.um_hash_2);
        um_hash_call_3.apply(SRCIP, ig_md.um_hash_3);        
        um_update_1.apply((bit<32>)ig_md.um_hash_1[9:0], ig_md.um_hash_1[10:10], ig_md.um_level, ig_md.um_base_1, ig_md.um_mem_index_1, ig_md.um_est_1);
        um_update_2.apply(ig_md.um_hash_2, ig_md.um_hash_1[11:11], ig_md.um_level, ig_md.um_base_2, ig_md.um_mem_index_2, ig_md.um_est_2);
        um_update_3.apply(ig_md.um_hash_3, ig_md.um_hash_1[12:12], ig_md.um_level, ig_md.um_base_3, ig_md.um_mem_index_3, ig_md.um_est_3);
        um_store_flowkey.apply(hdr, SRCIP, ig_md.um_threshold, ig_md.um_est_1, ig_md.um_est_2, ig_md.um_est_3, ig_md.um_c_1, ig_md.um_c_2, ig_md.um_c_3, ig_md.um_above_threshold, ig_tm_md);
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
