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
    METADATA_DIM(13)
    METADATA_DIM(14)
    METADATA_DIM(15)
    METADATA_DIM(16)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(65536, 16, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    T2_INIT_HH_1( 1, 100, 8192)
    T2_INIT_HH_1( 2, 100, 16384)
    MRB_INIT_1( 3, 100, 131072, 14,  8)
    T2_INIT_HH_3( 4, 100, 4096)
    T2_INIT_HH_4( 5, 100, 8192)
    MRAC_INIT_1( 6, 100, 32768, 11, 16)
    T4_INIT_1( 7, 200, 4096)
    T2_INIT_HH_5( 8, 200, 16384)
    T1_INIT_1( 9, 110, 262144)
    T2_INIT_HH_4(10, 110, 16384)
    T1_INIT_4(11, 110, 131072)
    T4_INIT_1(12, 220, 4096)
    MRB_INIT_1(13, 220, 524288, 15, 16)
    T3_INIT_HH_2(14, 220, 4096)
    T1_INIT_3(15, 221, 262144)
    UM_INIT_3(16, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_12_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_16);

        //

        T2_RUN_AFTER_1_KEY_1( 1, SRCIP, 1)
        T2_RUN_AFTER_1_KEY_1( 2, SRCIP, 1)
        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
            update_3_1.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        T2_RUN_AFTER_3_KEY_1( 4, DSTIP, SIZE)
        T2_RUN_AFTER_4_KEY_1( 5, DSTIP, SIZE)
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6_1.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        // HLL for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            update_7_1.apply(SRCIP, DSTIP, ig_md.d_7_level);
        //

        T2_RUN_AFTER_5_KEY_2( 8, SRCIP, DSTIP, 1)
        T1_RUN_1_KEY_2( 9, SRCIP, SRCPORT)
        T2_RUN_AFTER_4_KEY_2(10, SRCIP, SRCPORT, 1)
        T1_RUN_4_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            update_12_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_12_level);
        //

        // MRB for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_32);
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index1_16);
            update_13_1.apply(ig_md.d_13_base_32, ig_md.d_13_index1_16);
        //

        T3_RUN_AFTER_2_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_3_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index3_16); 
            UM_RUN_END_3(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(16) 
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
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