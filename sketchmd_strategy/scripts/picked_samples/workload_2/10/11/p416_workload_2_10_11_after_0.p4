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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(16384, 14, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_1_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_2_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_1_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_1_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_1_3;
    //

    MRB_INIT_1( 3, 110, 131072, 14,  8)
    MRAC_INIT_1( 4, 110, 16384, 11,  8)
    T1_INIT_3( 5, 110, 131072)
    MRB_INIT_1( 6, 110, 262144, 14, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_2;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_4;
    //

    MRAC_INIT_1(10, 110, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_3_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_1_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_1_res_hash);
            update_1_1.apply(DSTIP, DSTPORT, 1, ig_md.d_1_res_hash[0:0], 1, ig_md.d_1_est_1);
            update_1_2.apply(DSTIP, DSTPORT, 1, ig_md.d_1_res_hash[1:1], 1, ig_md.d_1_est_2);
            update_1_3.apply(DSTIP, DSTPORT, 1, ig_md.d_1_res_hash[2:2], 1, ig_md.d_1_est_3);
            d_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_2_above_threshold);
        //

        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_3_index1_16);
            update_3_1.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_4_index1_16);
            update_4_1.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T1_RUN_3_KEY_2( 5, DSTIP, DSTPORT) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_6_index1_16);
            update_6_1.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_7_1.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_7_est_3);
            d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_7_est_3, ig_md.d_8_above_threshold);
            update_7_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_7_est_4);
        //

        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_10_index1_16);
            update_10_1.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip, ig_md.hf_dstport); 
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