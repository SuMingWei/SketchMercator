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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    T4_INIT_1( 2, 200, 4096)
    T2_INIT_5( 3, 200, 4096)
    UM_INIT_5( 4, 200, 11, 32768)
    T2_INIT_HH_5( 5, 110, 16384)
    T1_INIT_1( 6, 110, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_2;
    //

    UM_INIT_3( 9, 110, 11, 32768)
    T1_INIT_4(10, 220, 262144)
    T1_INIT_4(11, 220, 262144)
    T2_INIT_1(12, 220, 4096)
    T1_INIT_5(13, 221, 524288)
    MRAC_INIT_1(14, 221, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_2_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_9_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2_1.apply(SRCIP, DSTIP, ig_md.d_2_level);
        //

        T2_RUN_5_KEY_2( 3, SRCIP, DSTIP, 1)
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

        T2_RUN_AFTER_5_KEY_2( 5, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2( 6, DSTIP, DSTPORT) if (ig_md.d_6_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_7_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_7_res_hash);
            update_7_1.apply(DSTIP, DSTPORT, 1, ig_md.d_7_res_hash[0:0], 1, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, DSTPORT, 1, ig_md.d_7_res_hash[1:1], 1, ig_md.d_7_est_2);
            d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_8_above_threshold);
        //

        // UnivMon for inst 9
            d_9_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_9_index3_16); 
            UM_RUN_END_3(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(9) 
        //

        T1_RUN_4_KEY_4(10, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_4(11, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_1_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_5_KEY_5(13, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0 || ig_md.d_13_est1_4 == 0 || ig_md.d_13_est1_5 == 0) { /* process_new_flow() */ }
        // MRAC for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index1_16);
            update_14_1.apply(ig_md.d_14_base_16, ig_md.d_14_index1_16);
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
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