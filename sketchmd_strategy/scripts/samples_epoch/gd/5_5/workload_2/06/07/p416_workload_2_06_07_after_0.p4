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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(16384, 14, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

    //

    T2_INIT_4( 1, 100, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
    //

    MRAC_INIT_1( 5, 100, 16384, 11,  8)
    UM_INIT_5( 6, 100, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, ig_md.d_6_sampling_hash_16);

        //

        T2_RUN_4_KEY_1( 1, SRCIP, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, SIZE, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, SIZE, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, SIZE, 1, ig_md.d_2_est_3);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_3_above_threshold);
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
            update_5_1.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(SRCIP, ig_md.d_6_index3_16); 
            d_6_index_hash_call_4.apply(SRCIP, ig_md.d_6_index4_16); 
            d_6_index_hash_call_5.apply(SRCIP, ig_md.d_6_index5_16); 
            UM_RUN_END_5(6, ig_md.d_6_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(6) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip); 
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