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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(8192, 13, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    UM_INIT_2( 1, 100, 11, 32768)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_4_hash_call;
        TCAM_LPM_HLLPCSA() d_4_tcam_lpm;
        GET_BITMASK() d_4_get_bitmask;
        T2_T5_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_5;
    //
    T2_INIT_HH_2( 3, 200, 16384)
    T1_INIT_5( 5, 220, 131072)
    MRB_INIT_1( 6, 221, 524288, 15, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        UM_RUN_AFTER_2_KEY_1( 1, DSTIP, SIZE)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_4_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_32);
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            d_4_get_bitmask.apply(ig_md.d_4_level, ig_md.d_4_bitmask);
            update_4_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_bitmask, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_est_4);
            update_4_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_4_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(4)
        //
        T2_RUN_AFTER_2_KEY_2( 3, SRCIP, DSTIP, 1)
        T1_RUN_5_KEY_4( 5, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0 || ig_md.d_5_est1_5 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_5( 6, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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