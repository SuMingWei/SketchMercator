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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(8192, 13, 8192)

control WORKLOAD4_THRESHOLD(
    inout header_t hdr,
    inout metadata_t ig_md)
{
    action tbl_get_threshold_act (bit<32> threshold_8) {
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

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;
        action d_9_xor_construction() { ig_md.d_9_sampling_hash_32 = ig_md.d_4_sampling_hash_32 ^ ig_md.d_5_sampling_hash_32; }

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;
        action d_3_xor_construction() { ig_md.d_3_sampling_hash_16 = ig_md.d_1_sampling_hash_16 ^ ig_md.d_2_sampling_hash_16; }

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

    //

    MRAC_INIT_1_WITH_POLY( 1, 100, 32768, 11, 16, 32w0x790900f3, 32w0x30243f0b)
    MRB_INIT_1_WITH_POLY( 2, 100, 131072, 14, 16, 32w0x790900f3, 32w0x30243f0b)
    MRB_INIT_1_WITH_POLY( 3, 200, 262144, 15, 16, 32w0x790900f3, 32w0x30243f0b)
    T4_INIT_1_WITH_POLY( 4, 110, 4096, 32w0x790900f3, 32w0x30243f0b)
    T5_INIT_1_WITH_POLY( 5, 110, 16384, 32w0x790900f3, 32w0x30243f0b)
    T2_INIT_3_WITH_POLY( 6, 110, 8192, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5)

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x5b445b31) d_7_res_hash_call;
        ABOVE_THRESHOLD_3() d_8_above_threshold;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_7_1;
        T3_T2_KEY_UPDATE_220_8192(32w0x0f79f523) update_7_2;
        T3_T2_KEY_UPDATE_220_8192(32w0x6b8cb0c5) update_7_3;
        T2_KEY_UPDATE_220_4096(32w0x00390fc3) update_7_4;
        T2_KEY_UPDATE_220_4096(32w0x298ac673) update_7_5;
    //

    T5_INIT_1_WITH_POLY( 9, 220, 16384, 32w0x790900f3, 32w0x30243f0b)
    T4_INIT_1_WITH_POLY(10, 221, 8192, 32w0x790900f3, 32w0x30243f0b)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;
    WORKLOAD4_THRESHOLD() threshold;
    action init() {
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
            // O1 hash run
                d_4_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_4_sampling_hash_32);
                d_5_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_sampling_hash_32);
                d_9_xor_construction();
                d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);
                d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);
                d_3_xor_construction();
                d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_sampling_hash_32);

            //

            // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
                d_7_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_res_hash);
                update_7_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_7_res_hash[0:0], 1, ig_md.d_7_est_1);
                update_7_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_7_res_hash[1:1], 1, ig_md.d_7_est_2);
                update_7_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_7_res_hash[2:2], 1, ig_md.d_7_est_3);
                d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_7_est_3, ig_md.d_8_threshold, ig_md.d_8_above_threshold);
                update_7_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_7_est_4);
                update_7_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_7_est_5);
            //

            // HLL for inst 10
                d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
                update_10_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_level);
            //

            // MRB for inst 2
                d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
                d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
                update_2_1.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
            //

            // MRAC for inst 1
                d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16);
                d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
                update_1_1.apply(ig_md.d_1_base_16, ig_md.d_1_index1_16);
            //


            // MRB for inst 3
                d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
                d_3_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_3_index1_16);
                update_3_1.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
            //

            // HLL for inst 4
                d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
                update_4_1.apply(SRCIP, SRCPORT, ig_md.d_4_level);
            //

            // PCSA for inst 5
                d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
                d_5_get_bitmask.apply(ig_md.d_5_level, ig_md.d_5_bitmask);
                update_5_1.apply(DSTIP, DSTPORT, ig_md.d_5_bitmask);
            //

            T2_RUN_3_KEY_2( 6, DSTIP, DSTPORT, 1)


            // PCSA for inst 9
                d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
                d_9_get_bitmask.apply(ig_md.d_9_level, ig_md.d_9_bitmask);
                update_9_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_bitmask);
            //


            if(ig_md.d_8_above_threshold == 1) {
                heavy_flowkey_storage.apply(ig_dprsr_md, SRCIP, DSTIP, SRCPORT, DSTPORT);
            }
        }
    }
}
struct heavy_flowkey_digest_t {
    bit<16> epoch_index;
    bit<32> epoch_count;
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<16> src_port;
    bit<16> dst_port;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.epoch_index, ig_md.epoch_count, SRCIP, DSTIP, SRCPORT, DSTPORT});
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