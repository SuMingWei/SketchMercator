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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

    //

    T2_INIT_4( 1, 100, 4096)
    T2_INIT_HH_5( 2, 200, 16384)
    T4_INIT_1( 3, 110, 4096)
    T2_INIT_HH_3( 4, 110, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_6_above_threshold;
        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_6_hash_call;
        TCAM_LPM_HLLPCSA() d_6_tcam_lpm;
        GET_BITMASK() d_6_get_bitmask;
        T2_T5_KEY_UPDATE_220_16384(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_6_4;
    //

    MRAC_INIT_1( 7, 220, 32768, 11, 16)
    T1_INIT_1( 8, 221, 131072)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_3_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_5_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_sampling_hash_16);

        //

        T2_RUN_4_KEY_1( 1, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2( 2, SRCIP, DSTIP, SIZE)
        // HLL for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_3_level);
            update_3_1.apply(DSTIP, DSTPORT, ig_md.d_3_level);
        //

        T2_RUN_AFTER_3_KEY_2( 4, DSTIP, DSTPORT, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_6_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_6_level);
            d_6_get_bitmask.apply(ig_md.d_6_level, ig_md.d_6_bitmask);
            update_6_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_6_bitmask, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_6_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(6)
        //

        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_index1_16);
            update_7_1.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        T1_RUN_1_KEY_5( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport); 
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