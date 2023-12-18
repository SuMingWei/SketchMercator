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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T2_INIT_HH_2( 1, 100, 8192)
    UM_INIT_2( 3, 100, 10, 16384)
    UM_INIT_5( 2, 100, 11, 32768)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_2;
    //
    T1_INIT_4( 6, 110, 262144)
    T3_INIT_HH_2( 7, 110, 8192)
    MRB_INIT_1( 8, 220, 524288, 15, 16)

    // apply O2
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_9_above_threshold;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T2_RUN_AFTER_2_KEY_1( 1, SRCIP, SIZE)
        UM_RUN_AFTER_2_KEY_1( 3, DSTIP, SIZE)
        UM_RUN_AFTER_5_KEY_1( 2, DSTIP, 1)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_5_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(5)
        //
        T1_RUN_4_KEY_2( 6, SRCIP, SRCPORT) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_2_KEY_2( 7, DSTIP, DSTPORT, 1)
        MRB_RUN_1_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O2
        T2_RUN_AFTER_3_KEY_4(9, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
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