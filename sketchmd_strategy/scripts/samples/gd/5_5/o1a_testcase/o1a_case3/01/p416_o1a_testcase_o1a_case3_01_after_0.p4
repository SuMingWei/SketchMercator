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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

    //

    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_1_tcam_lpm;
        T4_T4_KEY_UPDATE_220_16384(32w0x30243f0b) update_1_1;
    //

    MRB_INIT_1( 3, 220, 131072, 14,  8)
    MRB_INIT_1( 4, 220, 262144, 14, 16)
    MRB_INIT_1( 5, 220, 131072, 14,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_6_tcam_lpm;
        GET_BITMASK() d_6_get_bitmask;
        T5_T5_KEY_UPDATE_220_4096(32w0x30243f0b) update_6_1;
    //

    MRAC_INIT_1( 8, 220, 16384, 11,  8)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_9_sampling_hash_call;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_9_index_hash_call_1;
        LPM_OPT_MRAC_2() d_9_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_9;
    // 





    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_3_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_1_sampling_hash_32);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_sampling_hash_16);

        //

        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_1_level);
        //

        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        // MRB for inst 4
            d_4_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_4_base_32);
            d_4_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_32, ig_md.d_4_index1_16);
        //

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_6_level);
            d_6_get_bitmask.apply(ig_md.d_6_level, ig_md.d_6_bitmask);
            update_6_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_bitmask, ig_md.d_6_est_1);
        //

        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048);
        d_9_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_index1_16);
        update_9.apply(ig_md.d_9_base_16_2048, ig_md.d_9_index1_16);
        // 


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