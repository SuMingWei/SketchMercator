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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T2_INIT_HH_1( 2, 100, 16384)
    T2_INIT_HH_4( 1, 100, 8192)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(3, 100)
        ABOVE_THRESHOLD_1() d_3_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_3_1;
    // 

    T1_INIT_4( 5, 200, 131072)
    MRB_INIT_1( 6, 200, 262144, 15,  8)
    UM_INIT_3( 7, 200, 11, 32768)
    UM_INIT_5( 8, 200, 11, 32768)
    T1_INIT_3( 9, 110, 262144)
    T2_INIT_HH_1(10, 110, 16384)
    T5_INIT_1(11, 110, 16384)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_13_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_3;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_4;
    //
    T2_INIT_2(14, 220, 4096)
    T2_INIT_HH_1(15, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T2_RUN_AFTER_1_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_4_KEY_1( 1, SRCIP, 1)

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_3_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);
        d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash);
        d_3_tcam_lpm_2.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16_1024, ig_md.d_3_base_16_2048, ig_md.d_3_threshold);
        d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
        update_3_1.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index1_16, ig_md.d_3_res_hash[1:1], SIZE, ig_md.d_3_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(3)
        // 

        T1_RUN_4_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_2( 6, SRCIP, DSTIP)
        UM_RUN_AFTER_3_KEY_2( 7, SRCIP, DSTIP, 1)
        UM_RUN_AFTER_5_KEY_2( 8, SRCIP, DSTIP, SIZE)
        T1_RUN_3_KEY_2( 9, SRCIP, SRCPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_1_KEY_2(10, SRCIP, SRCPORT, 1)
        T5_RUN_1_KEY_2(11, DSTIP, DSTPORT)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_12_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_12_est_1);
            update_12_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_12_est_2);
            update_12_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_12_est_3);
            update_12_4.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_12_est_4);
            d_13_above_threshold.apply(ig_md.d_12_est_1, ig_md.d_12_est_2, ig_md.d_12_est_3, ig_md.d_12_est_4, ig_md.d_13_above_threshold);
        //
        T2_RUN_2_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_AFTER_1_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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