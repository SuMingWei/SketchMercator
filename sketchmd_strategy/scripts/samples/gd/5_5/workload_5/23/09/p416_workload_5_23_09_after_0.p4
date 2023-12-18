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
    METADATA_DIM(19)
    METADATA_DIM(20)
    METADATA_DIM(21)
    METADATA_DIM(22)
    METADATA_DIM(23)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 524288)
    T4_INIT_1( 2, 100, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_3;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_4;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_3_5;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_3;
    //

    UM_INIT_4( 7, 100, 10, 16384)
    T1_INIT_5( 8, 200, 524288)
    T2_INIT_HH_3(10, 200, 8192)
    T2_INIT_HH_5( 9, 200, 16384)
    T1_INIT_4(11, 110, 262144)
    T2_INIT_HH_4(12, 110, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(14, 110)
        ABOVE_THRESHOLD_3() d_14_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_14_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_14_3;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_5;
    //

    T1_INIT_1(17, 220, 262144)
    T2_INIT_HH_3(18, 220, 8192)
    UM_INIT_1(19, 220, 11, 32768)
    T1_INIT_2(20, 221, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_22_above_threshold;
        T2_T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_21_1;
        T2_T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_21_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_23_above_threshold;
        T3_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_21_3;
        T3_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_21_4;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_21_5;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_16);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2.apply(SRCIP, ig_md.d_2_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(SRCIP, SIZE, SIZE, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, SIZE, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, SIZE, SIZE, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, SIZE, SIZE, ig_md.d_3_est_4);
            update_3_5.apply(SRCIP, SIZE, SIZE, ig_md.d_3_est_5);
            d_4_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_3_est_4, ig_md.d_3_est_5, ig_md.d_4_above_threshold);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_6_1.apply(DSTIP, SIZE, SIZE, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, SIZE, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, SIZE, ig_md.d_6_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(6)
        //

        // UnivMon for inst 7
            d_7_res_hash_call.apply(DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(DSTIP, ig_md.d_7_index4_16); 
            UM_RUN_END_4(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(7) 
        //

        T1_RUN_5_KEY_2( 8, SRCIP, DSTIP) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0 || ig_md.d_8_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_2(10, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2( 9, SRCIP, DSTIP, 1)
        T1_RUN_4_KEY_2(11, SRCIP, SRCPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_2(12, SRCIP, SRCPORT, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
        d_14_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_14_index2_16);
        update_14_2.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index2_16, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
        d_14_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_14_index3_16);
        update_14_3.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index3_16, ig_md.d_14_res_hash[3:3], 1, ig_md.d_14_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(14)
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_16_1.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_16_est_1);
            update_16_2.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_16_est_2);
            update_16_3.apply(DSTIP, DSTPORT, SIZE, SIZE, ig_md.d_16_est_3);
            update_16_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_est_4);
            update_16_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_est_5);
        //

        T1_RUN_1_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 19
            d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16); 
            UM_RUN_END_1(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(19) 
        //

        T1_RUN_2_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_res_hash);
            update_21_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_21_est_1);
            update_21_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_21_est_2);
            d_22_above_threshold.apply(ig_md.d_21_est_1, ig_md.d_21_est_2, ig_md.d_22_above_threshold);
            update_21_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_21_res_hash[3:3], 1, ig_md.d_21_est_3);
            update_21_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_21_res_hash[4:4], 1, ig_md.d_21_est_4);
            d_23_above_threshold.apply(ig_md.d_21_est_3, ig_md.d_21_est_4, ig_md.d_23_above_threshold);
            update_21_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_21_est_5);
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
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