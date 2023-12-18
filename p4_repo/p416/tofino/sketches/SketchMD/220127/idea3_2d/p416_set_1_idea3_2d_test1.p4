#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

#define METADATA_DIM(D) \
    bit<32> d_##D##_cm_threshold; \
    bit<32> d_##D##_kary_threshold; \
    bit<32> d_##D##_um_threshold; \
    bit<32> d_##D##_base; \
    bit<32> d_##D##_cm_est_1; \
    bit<32> d_##D##_cm_est_2; \
    bit<32> d_##D##_cm_est_3; \
    bit<16> d_##D##_mrac_hash; \
    bit<32> d_##D##_mrac_level; \
    bit<32> d_##D##_kary_est_1; \
    bit<32> d_##D##_kary_est_2; \
    bit<32> d_##D##_kary_est_3; \
    bit<32> d_##D##_ss_xy_hash; \
    bit<32> d_##D##_ss_level; \
    bit<32> d_##D##_ss_short_level; \
    bit<32> d_##D##_ss_hash_1; \
    bit<32> d_##D##_ss_hash_2; \
    bit<32> d_##D##_ss_hash_3;


struct metadata_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<1> kary_epoch;
    METADATA_DIM(1)
    METADATA_DIM(2)
}

#include "parser.p4"
#include "API_S1_hash.p4"
#include "API_S2_tcam.p4"
#include "API_S3_salu.p4"
#include "API_S4_heavy.p4"
#include "API_threshold.p4"

#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr

#define CONTROL_DIM(D) \
    GET_THRESHOLD_SET_level() d_##D##_get_threshold_level; \
    heavy_flowkey_storage_key32_3_split1() d_##D##_cm_store_flowkey; \
    HASH_COMPUTE_KEY32_16_16(32w0x30243f0b) d_##D##_mrac_hash_call; \
    lpm_optimization_16() d_##D##_mrac_lpm; \
    MRAC_UPDATE() d_##D##_mrac_update; \
    KARY_CM_UPDATE(32w0x30243f0b) d_##D##_kary_update_1; \
    KARY_CM_UPDATE(32w0x0f79f523) d_##D##_kary_update_2; \
    KARY_CM_UPDATE(32w0x6b8cb0c5) d_##D##_kary_update_3; \
    heavy_flowkey_storage_key32_3_split1() d_##D##_kary_store_flowkey; \
    HASH_COMPUTE_KEY32_KEY32_32_32(32w0x30243f0b) d_##D##_ss_xy_hash_call; \
    lpm_optimization_32() d_##D##_ss_lpm; \
    HASH_COMPUTE_KEY32_32_11(32w0x30243f0b) d_##D##_ss_hash_call_1; \
    HASH_COMPUTE_KEY32_32_11(32w0x0f79f523) d_##D##_ss_hash_call_2; \
    HASH_COMPUTE_KEY32_32_11(32w0x6b8cb0c5) d_##D##_ss_hash_call_3; \
    SS_UPDATE() d_##D##_ss_update_1; \
    SS_UPDATE() d_##D##_ss_update_2; \
    SS_UPDATE() d_##D##_ss_update_3; \
    SS_UPDATE_LOG() d_##D##_ss_update_log_1; \
    SS_UPDATE_LOG() d_##D##_ss_update_log_2; \
    SS_UPDATE_LOG() d_##D##_ss_update_log_3; \
    heavy_flowkey_storage_key32_3_split2(32w0x790900f3) d_##D##_flowkey_merged; \
    bit<1> d_##D##_cm_above; \
    bit<1> d_##D##_kary_above;

#define APPLY_DIM(D, KEY) \
    d_##D##_mrac_hash_call.apply(##KEY##, ig_md.d_##D##_mrac_hash); \
    d_##D##_mrac_lpm.apply(ig_md.d_##D##_mrac_hash, ig_md.d_##D##_mrac_level); \
    d_##D##_get_threshold_level.apply(ig_md.d_##D##_mrac_level, ig_md.d_##D##_um_threshold, ig_md.d_##D##_base); \
    d_##D##_mrac_update.apply(ig_md.d_##D##_base, (bit<32>)ig_md.d_##D##_mrac_hash[9:0]); \
    d_##D##_kary_update_1.apply(##KEY##, ig_md.kary_epoch, ig_md.d_##D##_kary_est_1, ig_md.d_##D##_cm_est_1); \
    d_##D##_kary_update_2.apply(##KEY##, ig_md.kary_epoch, ig_md.d_##D##_kary_est_2, ig_md.d_##D##_cm_est_1); \
    d_##D##_kary_update_3.apply(##KEY##, ig_md.kary_epoch, ig_md.d_##D##_kary_est_3, ig_md.d_##D##_cm_est_1); \
    d_##D##_kary_store_flowkey.apply(hdr, ig_md.d_##D##_kary_threshold, ig_md.d_##D##_kary_est_1, ig_md.d_##D##_kary_est_2, ig_md.d_##D##_kary_est_3, d_##D##_cm_above); \
    d_##D##_cm_store_flowkey.apply(hdr, ig_md.d_##D##_cm_threshold, ig_md.d_##D##_cm_est_1, ig_md.d_##D##_cm_est_2, ig_md.d_##D##_cm_est_3, d_##D##_kary_above); \
    if (d_##D##_cm_above == 1 || d_##D##_kary_above == 1) { \
        d_##D##_flowkey_merged.apply(hdr, ##KEY##, ig_tm_md); \
    } \
    d_##D##_ss_xy_hash_call.apply(SRCIP, DSTIP, ig_md.d_##D##_ss_xy_hash); \
    d_##D##_ss_hash_call_1.apply(##KEY##, ig_md.d_##D##_ss_hash_1); \
    d_##D##_ss_hash_call_2.apply(##KEY##, ig_md.d_##D##_ss_hash_2); \
    d_##D##_ss_hash_call_3.apply(##KEY##, ig_md.d_##D##_ss_hash_3); \
    d_##D##_ss_lpm.apply(ig_md.d_##D##_ss_xy_hash, ig_md.d_##D##_ss_level); \
    if(ig_md.d_##D##_ss_level > 3) { \
        ig_md.d_##D##_ss_short_level = 4; \
    } \
    else { \
        ig_md.d_##D##_ss_short_level = (bit<32>)ig_md.d_##D##_ss_level[1:0]; \
    } \
    d_##D##_ss_update_log_1.apply(##KEY##, ig_md.d_##D##_ss_hash_1, ig_md.d_##D##_ss_level); \
    d_##D##_ss_update_log_2.apply(##KEY##, ig_md.d_##D##_ss_hash_2, ig_md.d_##D##_ss_level); \
    d_##D##_ss_update_log_3.apply(##KEY##, ig_md.d_##D##_ss_hash_3, ig_md.d_##D##_ss_level); \
    d_##D##_ss_update_1.apply(ig_md.d_##D##_ss_hash_1, ig_md.d_##D##_ss_xy_hash, ig_md.d_##D##_ss_short_level); \
    d_##D##_ss_update_2.apply(ig_md.d_##D##_ss_hash_2, ig_md.d_##D##_ss_xy_hash, ig_md.d_##D##_ss_short_level); \
    d_##D##_ss_update_3.apply(ig_md.d_##D##_ss_hash_3, ig_md.d_##D##_ss_xy_hash, ig_md.d_##D##_ss_short_level);

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    GET_THRESHOLD_SET_cm_kary() get_threshold_cm_kary;

    CONTROL_DIM(1)
    CONTROL_DIM(2)

    apply {
        get_threshold_cm_kary.apply(hdr, ig_md);
        APPLY_DIM(1, SRCIP)
        APPLY_DIM(2, DSTIP)
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
