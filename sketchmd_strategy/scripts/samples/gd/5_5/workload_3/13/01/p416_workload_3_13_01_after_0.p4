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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

    //

    T2_INIT_HH_2( 1, 100, 8192)
    MRAC_INIT_1( 2, 100, 16384, 11,  8)
    T1_INIT_4( 3, 200, 131072)
    T2_INIT_3( 4, 110, 8192)
    T2_INIT_1( 5, 110, 16384)
    UM_INIT_1( 6, 110, 11, 32768)
    T1_INIT_1( 8, 220, 131072)
    T1_INIT_3( 7, 220, 524288)
    T4_INIT_1( 9, 221, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_11_above_threshold;
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_11_hash_call;
        TCAM_LPM_HLLPCSA() d_11_tcam_lpm;
        GET_BITMASK() d_11_get_bitmask;
        T2_T5_KEY_UPDATE_221_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_11_4;
    //

    T2_INIT_HH_3(12, 221, 16384)
    MRAC_INIT_1(13, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_9_sampling_hash_32);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_sampling_hash_16);

        //

        T2_RUN_AFTER_2_KEY_1( 1, SRCIP, 1)
        // MRAC for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16);
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_16, ig_md.d_2_index1_16);
        //

        T1_RUN_4_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_2( 4, SRCIP, SRCPORT, 1)
        T2_RUN_1_KEY_2( 5, DSTIP, DSTPORT, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_6_index1_16); 
            UM_RUN_END_1(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(6) 
        //

        T1_RUN_1_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T1_RUN_3_KEY_4( 7, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0) { /* process_new_flow() */ }
        // HLL for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
            update_9.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_9_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_11_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_11_level);
            d_11_get_bitmask.apply(ig_md.d_11_level, ig_md.d_11_bitmask);
            update_11_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_11_bitmask, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_11_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(11)
        //

        T2_RUN_AFTER_3_KEY_5(12, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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