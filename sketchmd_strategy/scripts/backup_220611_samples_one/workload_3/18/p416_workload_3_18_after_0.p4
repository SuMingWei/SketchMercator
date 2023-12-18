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
    METADATA_DIM(17)
    METADATA_DIM(18)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T1_INIT_5( 1, 100, 524288)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
    //
    T3_INIT_HH_2( 4, 100, 8192)
    MRAC_INIT_1( 5, 100, 16384, 11,  8)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_1;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_8_4;
    //
    T3_INIT_HH_4( 7, 200, 4096)
    T2_INIT_HH_5( 9, 200, 4096)
    T1_INIT_2(10, 110, 262144)
    UM_INIT_2(11, 110, 11, 32768)
    UM_INIT_2(12, 110, 11, 32768)
    T2_INIT_4(13, 110, 8192)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(14, 110)
        ABOVE_THRESHOLD_1() d_14_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
    // 

    T4_INIT_1(16, 220, 32768)
    MRB_INIT_1(17, 221, 131072, 14,  8)
    T2_INIT_HH_4(18, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, 1, 1, ig_md.d_2_est_1);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_3_above_threshold);
        //
        T3_RUN_AFTER_2_KEY_1( 4, DSTIP, 1)
        MRAC_RUN_1_KEY_1( 5, DSTIP)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_8_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(8)
        //
        T3_RUN_AFTER_4_KEY_2( 7, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_2( 9, SRCIP, DSTIP, 1)
        T1_RUN_2_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0) { /* process_new_flow() */ }
        UM_RUN_AFTER_2_KEY_2(11, SRCIP, SRCPORT, 1)
        UM_RUN_AFTER_2_KEY_2(12, SRCIP, SRCPORT, 1)
        T2_RUN_4_KEY_2(13, DSTIP, DSTPORT, 1)

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_14_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_16);
        d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(14)
        // 

        T4_RUN_1_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT)
        MRB_RUN_1_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_AFTER_4_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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