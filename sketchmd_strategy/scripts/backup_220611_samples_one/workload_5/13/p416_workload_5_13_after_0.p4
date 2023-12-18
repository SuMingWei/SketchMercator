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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T1_INIT_1( 1, 100, 524288)
    T2_INIT_HH_5( 2, 100, 4096)
    UM_INIT_5( 3, 100, 11, 32768)
    T1_INIT_1( 4, 100, 131072)
    T3_INIT_HH_1( 5, 100, 8192)
    T1_INIT_4( 6, 110, 524288)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_8_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
    //
    UM_INIT_2( 9, 220, 11, 32768)
    T1_INIT_3(10, 221, 524288)
    T2_INIT_3(11, 221, 4096)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 221)
        ABOVE_THRESHOLD_2() d_13_above_threshold;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_13_1;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_13_2;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, SIZE)
        UM_RUN_AFTER_5_KEY_1( 3, SRCIP, SIZE)
        T1_RUN_1_KEY_1( 4, DSTIP)
        T3_RUN_AFTER_1_KEY_1( 5, DSTIP, SIZE)
        T1_RUN_4_KEY_2( 6, DSTIP, DSTPORT) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_7_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_7_res_hash);
            update_7_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_7_res_hash[1:1], SIZE, ig_md.d_7_est_1);
            d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_8_above_threshold);
        //
        UM_RUN_AFTER_2_KEY_4( 9, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T1_RUN_3_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_5(11, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)

        // apply O3; big - UnivMon / small - many MRACs 
        d_13_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_sampling_hash_16);
        d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(13)
        // 

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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