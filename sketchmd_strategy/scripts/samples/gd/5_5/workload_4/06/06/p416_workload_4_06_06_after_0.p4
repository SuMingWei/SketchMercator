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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(8192, 13, 4096)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_2_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_3;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_5;
    //

    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T4_INIT_1( 4, 200, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_6_above_threshold;
        T3_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_1;
        T3_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_2;
        T3_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_4;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_32);

        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_2_1.apply(SRCIP, 1, SIZE, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, SIZE, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, SIZE, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, SIZE, ig_md.d_2_est_4);
            update_2_5.apply(SRCIP, 1, ig_md.d_2_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(2)
        //

        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(SRCIP, DSTIP, ig_md.d_4_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_5_res_hash[1:1], SIZE, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_5_res_hash[2:2], SIZE, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_5_res_hash[3:3], SIZE, ig_md.d_5_est_3);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_6_above_threshold);
            update_5_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_5_est_4);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
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