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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_210(16384, 14, 4096)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 4096)
    T4_INIT_1( 2, 100, 16384)
    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T2_INIT_3( 4, 200, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_res_hash_call;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_2;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_3;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_4;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_5;
    //

    MRAC_INIT_1( 7, 200, 32768, 11, 16)
    MRAC_INIT_1( 8, 200, 32768, 11, 16)
    UM_INIT_3( 9, 110, 11, 32768)
    T1_INIT_1(10, 110, 524288)
    MRAC_INIT_1(11, 220, 32768, 11, 16)
    MRAC_INIT_1(12, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1_1.apply(SRCIP, ig_md.d_1_level);
        //

        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_2_level);
            update_2_1.apply(SRCIP, ig_md.d_2_level);
        //

        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
            update_3_1.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        T2_RUN_3_KEY_2( 4, SRCIP, DSTIP, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash);
            update_6_1.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[0:0], 1, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[3:3], ig_md.d_6_est_4);
            update_6_5.apply(SRCIP, DSTIP, 1, ig_md.d_6_res_hash[4:4], ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //

        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16);
            update_7_1.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
            update_8_1.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //

        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_9_index3_16); 
            UM_RUN_END_3(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(9) 
        //

        T1_RUN_1_KEY_2(10, DSTIP, DSTPORT)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_index1_16);
            update_11_1.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index1_16);
            update_12_1.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport); 
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