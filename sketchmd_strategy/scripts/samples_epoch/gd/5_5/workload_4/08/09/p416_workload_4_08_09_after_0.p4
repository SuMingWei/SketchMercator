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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(8192, 13, 2048)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //

    T2_INIT_2( 1, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(3, 100)
        ABOVE_THRESHOLD_3() d_3_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_3_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_3_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_3_3;
    // 

    T1_INIT_1( 4, 200, 262144)
    T2_INIT_4( 5, 200, 16384)
    MRB_INIT_1( 6, 220, 131072, 14,  8)
    T1_INIT_2( 7, 221, 262144)
    MRAC_INIT_1( 8, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_sampling_hash_16);

        //

        T2_RUN_2_KEY_1( 1, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_3_res_hash_call.apply(DSTIP, ig_md.d_3_res_hash);
        d_3_tcam_lpm_2.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16_1024, ig_md.d_3_base_16_2048, ig_md.d_3_threshold);
        d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
        update_3_1.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index1_16, ig_md.d_3_res_hash[0:0], SIZE, ig_md.d_3_est_1);
        d_3_index_hash_call_2.apply(DSTIP, ig_md.d_3_index2_16);
        update_3_2.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index2_16, ig_md.d_3_res_hash[1:1], SIZE, ig_md.d_3_est_2);
        d_3_index_hash_call_3.apply(DSTIP, ig_md.d_3_index3_16);
        update_3_3.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index3_16, ig_md.d_3_res_hash[2:2], SIZE, ig_md.d_3_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(3)
        // 

        T1_RUN_1_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_4_KEY_2( 5, SRCIP, DSTIP, 1)
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index1_16);
            update_6_1.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        T1_RUN_2_KEY_5( 7, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0) { /* process_new_flow() */ }
        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index1_16);
            update_8_1.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //

        if(ig_md.d_3_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, DSTIP);
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