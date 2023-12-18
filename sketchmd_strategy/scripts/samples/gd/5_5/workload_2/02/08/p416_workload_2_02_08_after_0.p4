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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(4096, 12, 2048)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(2, 221)
        ABOVE_THRESHOLD_4() d_2_above_threshold;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_2_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_2_1;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_2_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_2_2;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_2_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_2_3;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_2_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_2_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_sampling_hash_16);

        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_2_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_res_hash);
        d_2_tcam_lpm_2.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16_1024, ig_md.d_2_base_16_2048, ig_md.d_2_threshold);
        d_2_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_index1_16);
        update_2_1.apply(ig_md.d_2_base_16_1024, ig_md.d_2_index1_16, ig_md.d_2_res_hash[1:1], 1, ig_md.d_2_est_1);
        d_2_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_index2_16);
        update_2_2.apply(ig_md.d_2_base_16_1024, ig_md.d_2_index2_16, ig_md.d_2_res_hash[2:2], 1, ig_md.d_2_est_2);
        d_2_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_index3_16);
        update_2_3.apply(ig_md.d_2_base_16_1024, ig_md.d_2_index3_16, ig_md.d_2_res_hash[3:3], 1, ig_md.d_2_est_3);
        d_2_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_2_index4_16);
        update_2_4.apply(ig_md.d_2_base_16_1024, ig_md.d_2_index4_16, ig_md.d_2_res_hash[4:4], 1, ig_md.d_2_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(2)
        // 

        if(ig_md.d_2_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO);
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