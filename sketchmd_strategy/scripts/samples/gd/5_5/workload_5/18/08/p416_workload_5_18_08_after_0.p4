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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T2_INIT_3( 1, 100, 8192)
    T1_INIT_1( 2, 100, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_5;
    //

    T3_INIT_HH_4( 5, 100, 8192)
    T1_INIT_2( 6, 200, 524288)
    T2_INIT_HH_5( 7, 200, 4096)
    T1_INIT_4( 8, 110, 524288)
    T4_INIT_1( 9, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_2;
    //

    T2_INIT_HH_5(12, 110, 16384)
    T1_INIT_1(13, 220, 524288)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(14, 220)
        ABOVE_THRESHOLD_1() d_14_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
    // 

    T2_INIT_4(17, 221, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_16_1;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_16_2;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_16_3;
        T2_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_16_4;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_16_5;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

        //

        T2_RUN_3_KEY_1( 1, SRCIP, SIZE)
        T1_RUN_1_KEY_1( 2, DSTIP)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_4_1.apply(DSTIP, 1, SIZE, ig_md.d_4_est_1);
            update_4_2.apply(DSTIP, 1, SIZE, ig_md.d_4_est_2);
            update_4_3.apply(DSTIP, 1, SIZE, ig_md.d_4_est_3);
            update_4_4.apply(DSTIP, 1, SIZE, ig_md.d_4_est_4);
            update_4_5.apply(DSTIP, 1, ig_md.d_4_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(4)
        //

        T3_RUN_AFTER_4_KEY_1( 5, DSTIP, 1)
        T1_RUN_2_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2( 7, SRCIP, DSTIP, SIZE)
        T1_RUN_4_KEY_2( 8, SRCIP, SRCPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
            update_9.apply(SRCIP, SRCPORT, ig_md.d_9_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_10_1.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_10_est_2);
            d_11_above_threshold.apply(ig_md.d_10_est_1, ig_md.d_10_est_2, ig_md.d_11_above_threshold);
        //

        T2_RUN_AFTER_5_KEY_2(12, DSTIP, DSTPORT, SIZE)
        T1_RUN_1_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_13_est1_1 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_14_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(14)
        // 

        T2_RUN_4_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_16_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_16_est_1);
            update_16_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_16_est_2);
            update_16_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_16_est_3);
            update_16_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_16_est_4);
            update_16_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_16_est_5);
        //

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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