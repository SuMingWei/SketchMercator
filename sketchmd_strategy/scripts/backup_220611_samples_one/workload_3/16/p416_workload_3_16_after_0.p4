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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T2_INIT_HH_5( 1, 100, 4096)
    T1_INIT_1( 2, 100, 262144)
    T1_INIT_1( 3, 100, 131072)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
    //
    UM_INIT_3( 6, 100, 10, 16384)
    T2_INIT_HH_1( 7, 200, 8192)
    T2_INIT_HH_5( 8, 200, 16384)

    // apply O3; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_sampling_hash_call;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_9_index_hash_call_1;
        LPM_OPT_MRAC_2() d_9_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_9;
    // 

    T2_INIT_2(11, 110, 4096)
    UM_INIT_2(13, 110, 11, 32768)
    UM_INIT_4(12, 110, 10, 16384)
    MRAC_INIT_1(14, 220, 8192, 10,  8)
    T1_INIT_5(15, 221, 262144)
    T2_INIT_HH_2(16, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T2_RUN_AFTER_5_KEY_1( 1, SRCIP, 1)
        T1_RUN_1_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_1( 3, DSTIP)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_5_1.apply(DSTIP, 1, 1, ig_md.d_5_est_1);
            update_5_2.apply(DSTIP, 1, 1, ig_md.d_5_est_2);
            update_5_3.apply(DSTIP, 1, ig_md.d_5_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(5)
        //
        UM_RUN_AFTER_3_KEY_1( 6, DSTIP, 1)
        T2_RUN_AFTER_1_KEY_2( 7, SRCIP, DSTIP, 1)
        T2_RUN_AFTER_5_KEY_2( 8, SRCIP, DSTIP, 1)

        // big - MRAC (1 row) / small - MRAC (1 row)
        d_9_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048);
        d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16);
        update_9.apply(ig_md.d_9_base_16_1024, ig_md.d_9_index1_16);
        // 

        T2_RUN_2_KEY_2(11, DSTIP, DSTPORT, 1)
        UM_RUN_AFTER_2_KEY_2(13, DSTIP, DSTPORT, 1)
        UM_RUN_AFTER_4_KEY_2(12, DSTIP, DSTPORT, 1)
        MRAC_RUN_1_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T1_RUN_5_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0 || ig_md.d_15_est1_4 == 0 || ig_md.d_15_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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