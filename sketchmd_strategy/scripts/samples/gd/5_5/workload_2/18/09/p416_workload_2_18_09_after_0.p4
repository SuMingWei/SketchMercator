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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //

    T1_INIT_2( 3, 110, 131072)
    T1_INIT_4( 2, 110, 131072)

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_4_1;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_4_2;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_4_3;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_4_4;
    // 

    T1_INIT_5( 1, 110, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_9_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_9_hash_call;
        TCAM_LPM_HLLPCSA() d_9_tcam_lpm;
        GET_BITMASK() d_9_get_bitmask;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_4;
    //


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_7_above_threshold;
    // 

    T3_INIT_HH_2(10, 110, 8192)
    T2_INIT_HH_4(15, 110, 4096)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_8_above_threshold;
    // 

    T2_INIT_HH_5(12, 110, 4096)
    T2_INIT_HH_5(14, 110, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_sampling_hash_call;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_17_index_hash_call_1;
        LPM_OPT_MRAC_2() d_17_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_17;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_sampling_hash_32);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

        //

        T1_RUN_2_KEY_2( 3, DSTIP, DSTPORT) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 2, DSTIP, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_4_KEY_2(4, DSTIP, DSTPORT) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_5_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_9_level);
            d_9_get_bitmask.apply(ig_md.d_9_level, ig_md.d_9_bitmask);
            update_9_1.apply(DSTIP, DSTPORT, 1, ig_md.d_9_bitmask, ig_md.d_9_est_1);
            update_9_2.apply(DSTIP, DSTPORT, 1, ig_md.d_9_est_2);
            update_9_3.apply(DSTIP, DSTPORT, 1, ig_md.d_9_est_3);
            update_9_4.apply(DSTIP, DSTPORT, 1, ig_md.d_9_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(9)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(7, DSTIP, DSTPORT, 1)
        // 

        T3_RUN_AFTER_2_KEY_2(10, DSTIP, DSTPORT, SIZE)
        T2_RUN_AFTER_4_KEY_2(15, DSTIP, DSTPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(8, DSTIP, DSTPORT, SIZE)
        // 

        T2_RUN_AFTER_5_KEY_2(12, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_2(14, DSTIP, DSTPORT, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048);
        d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16);
        update_17.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index1_16);
        // 

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip, ig_md.hf_dstport); 
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