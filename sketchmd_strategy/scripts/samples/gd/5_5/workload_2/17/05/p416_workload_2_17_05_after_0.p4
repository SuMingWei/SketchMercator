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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 110, 262144)
    T1_INIT_5( 2, 110, 131072)
    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_3_tcam_lpm;
        T4_T4_KEY_UPDATE_110_32768(32w0x30243f0b) update_3_1;
    //

    MRB_INIT_1( 5, 110, 262144, 14, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_13_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_13_hash_call;
        TCAM_LPM_HLLPCSA() d_13_tcam_lpm;
        GET_BITMASK() d_13_get_bitmask;
        T2_T5_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_13_3;
    //

    T2_INIT_HH_1(12, 110, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_16_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_5;
    //


    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_9_above_threshold;
    // 

    T3_INIT_HH_2(10, 110, 16384)
    T3_INIT_HH_2(11, 110, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_14_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_14_4;
    //

    MRAC_INIT_1(17, 110, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_sampling_hash_16);

            d_3_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_3_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_sampling_hash_32);

        //

        T1_RUN_4_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 2, DSTIP, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_3_level);
            update_3_1.apply(DSTIP, DSTPORT, ig_md.d_3_level);
        //

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_13_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_13_level);
            d_13_get_bitmask.apply(ig_md.d_13_level, ig_md.d_13_bitmask);
            update_13_1.apply(DSTIP, DSTPORT, 1, ig_md.d_13_bitmask, ig_md.d_13_est_1);
            update_13_2.apply(DSTIP, DSTPORT, 1, ig_md.d_13_est_2);
            update_13_3.apply(DSTIP, DSTPORT, 1, ig_md.d_13_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(13)
        //

        T2_RUN_AFTER_1_KEY_2(12, DSTIP, DSTPORT, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_16_1.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_16_est_1);
            update_16_2.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_16_est_2);
            update_16_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_est_3);
            update_16_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_est_4);
            update_16_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(16)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(9, DSTIP, DSTPORT, SIZE)
        // 

        T3_RUN_AFTER_2_KEY_2(10, DSTIP, DSTPORT, SIZE)
        T3_RUN_AFTER_2_KEY_2(11, DSTIP, DSTPORT, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_14_1.apply(DSTIP, DSTPORT, 1, SIZE, ig_md.d_14_est_1);
            update_14_2.apply(DSTIP, DSTPORT, 1, SIZE, ig_md.d_14_est_2);
            update_14_3.apply(DSTIP, DSTPORT, 1, SIZE, ig_md.d_14_est_3);
            update_14_4.apply(DSTIP, DSTPORT, 1, ig_md.d_14_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(14)
        //

        // MRAC for inst 17
            d_17_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_17_base_16);
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_16, ig_md.d_17_index1_16);
        //

        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
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