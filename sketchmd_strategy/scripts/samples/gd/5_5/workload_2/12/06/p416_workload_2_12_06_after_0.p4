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
    METADATA_DIM(7)
    METADATA_DIM(8)
    METADATA_DIM(9)
    METADATA_DIM(10)
    METADATA_DIM(11)
    METADATA_DIM(12)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 221, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        GET_BITMASK() d_2_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_8_above_threshold;
        T2_T5_KEY_UPDATE_221_4096(32w0x30243f0b) update_2_1;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_11_above_threshold;
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_11_hash_call;
        TCAM_LPM_HLLPCSA() d_11_tcam_lpm;
        GET_BITMASK() d_11_get_bitmask;
        T2_T5_KEY_UPDATE_221_4096(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_11_2;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_9_above_threshold;
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_9_hash_call;
        TCAM_LPM_HLLPCSA() d_9_tcam_lpm;
        GET_BITMASK() d_9_get_bitmask;
        T2_T5_KEY_UPDATE_221_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_9_2;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_7_4;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_5_2;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_5_3;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_5_4;
    //

    MRAC_INIT_1(12, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_sampling_hash_32);

            d_3_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_3_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_4_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_16);

        //

        T1_RUN_3_KEY_5( 1, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            d_2_get_bitmask.apply(ig_md.d_2_level, ig_md.d_2_bitmask);
            update_2_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_2_bitmask, ig_md.d_2_est_1);
            d_8_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_8_above_threshold);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_11_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_11_level);
            d_11_get_bitmask.apply(ig_md.d_11_level, ig_md.d_11_bitmask);
            update_11_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_11_bitmask, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_11_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(11)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_9_level);
            d_9_get_bitmask.apply(ig_md.d_9_level, ig_md.d_9_bitmask);
            update_9_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_9_bitmask, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_9_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(9)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_7_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_7_est_1);
            update_7_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_7_est_2);
            update_7_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_7_est_3);
            update_7_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_7_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(7)
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_5_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, 1, ig_md.d_5_est_4);
            d_10_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_est_4, ig_md.d_10_above_threshold);
        //

        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport, ig_md.hf_proto); 
        }

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
    SwitchIngressDeparser(),
    EgressParser(),
    EmptyEgress(),
    EgressDeparser()
) pipe;
Switch(pipe) main;