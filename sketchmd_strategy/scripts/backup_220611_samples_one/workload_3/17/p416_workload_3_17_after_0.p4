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
    MRB_INIT_1( 1, 100, 524288, 15, 16)
    T2_INIT_HH_5( 2, 100, 16384)
    UM_INIT_3( 3, 100, 10, 16384)
    T1_INIT_4( 4, 100, 262144)
    MRB_INIT_1( 5, 100, 262144, 15,  8)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_5;
    //
    T1_INIT_1( 8, 200, 131072)
    T2_INIT_HH_5( 9, 200, 8192)
    UM_INIT_3(10, 110, 11, 32768)
    T1_INIT_1(11, 110, 131072)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(12, 110)
        ABOVE_THRESHOLD_1() d_12_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_12_1;
    // 

    MRAC_INIT_1(13, 110, 16384, 11,  8)
    T1_INIT_1(15, 220, 262144)
    T2_INIT_HH_2(17, 221, 4096)
    T2_INIT_HH_4(16, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        MRB_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_AFTER_5_KEY_1( 2, SRCIP, 1)
        UM_RUN_AFTER_3_KEY_1( 3, SRCIP, 1)
        T1_RUN_4_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_1( 5, DSTIP)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_7_1.apply(DSTIP, 1, 1, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, 1, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, 1, ig_md.d_7_est_3);
            update_7_4.apply(DSTIP, 1, ig_md.d_7_est_4);
            update_7_5.apply(DSTIP, 1, ig_md.d_7_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(7)
        //
        T1_RUN_1_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2( 9, SRCIP, DSTIP, 1)
        UM_RUN_AFTER_3_KEY_2(10, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0) { /* process_new_flow() */ }

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_12_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_sampling_hash_16);
        d_12_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], 1, ig_md.d_12_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(12)
        // 

        MRAC_RUN_1_KEY_2(13, DSTIP, DSTPORT)
        T1_RUN_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_AFTER_2_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_AFTER_4_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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