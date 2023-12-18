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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(8192, 13, 2048)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 200, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_2_1;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_2_3;
    //

    UM_INIT_5( 4, 200, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 1, SRCIP, DSTIP)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_2_est_3);
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_4_index4_16); 
            d_4_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_4_index5_16); 
            UM_RUN_END_5(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(4) 
        //

        if(ig_md.d_4_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, SRCIP, DSTIP);
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