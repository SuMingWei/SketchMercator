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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //


    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_1_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_1_above_threshold;
    // 

    T1_INIT_1( 3, 100, 524288)
    T2_INIT_5( 4, 200, 4096)
    T3_INIT_HH_2( 5, 110, 8192)
    T1_INIT_4( 6, 110, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_2;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_5;
    //

    T1_INIT_1( 9, 220, 262144)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
    // 

    T3_INIT_HH_4(11, 220, 16384)
    T2_INIT_HH_5(13, 220, 8192)
    MRAC_INIT_1(14, 220, 16384, 10, 16)
    T1_INIT_3(15, 221, 131072)
    MRAC_INIT_1(16, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_16);

        //


        // apply O2
        T2_RUN_AFTER_3_KEY_1(1, SRCIP, 1)
        // 

        T1_RUN_1_KEY_1( 3, DSTIP)
        T2_RUN_5_KEY_2( 4, SRCIP, DSTIP, 1)
        T3_RUN_AFTER_2_KEY_2( 5, SRCIP, SRCPORT, 1)
        T1_RUN_4_KEY_2( 6, DSTIP, DSTPORT) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_7_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_7_est_3);
            update_7_4.apply(DSTIP, DSTPORT, 1, ig_md.d_7_est_4);
            update_7_5.apply(DSTIP, DSTPORT, 1, ig_md.d_7_est_5);
        //

        T1_RUN_1_KEY_4( 9, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O2
        T2_RUN_AFTER_4_KEY_4(10, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 

        T3_RUN_AFTER_4_KEY_4(11, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
            update_14.apply(ig_md.d_14_base_16, ig_md.d_14_index1_16);
        //

        T1_RUN_3_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0) { /* process_new_flow() */ }
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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