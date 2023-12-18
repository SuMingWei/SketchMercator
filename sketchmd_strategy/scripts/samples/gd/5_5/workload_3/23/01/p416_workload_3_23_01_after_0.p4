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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;
        action d_12_xor_construction() { ig_md.d_12_sampling_hash_16 = ig_md.d_2_sampling_hash_16 ^ ig_md.d_9_sampling_hash_16; }

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 524288)
    MRB_INIT_1( 2, 100, 524288, 15, 16)
    T2_INIT_HH_1( 4, 100, 16384)
    T2_INIT_HH_5( 3, 100, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(7, 100)
        ABOVE_THRESHOLD_4() d_7_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_7_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_7_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_7_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_7_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_7_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_7_3;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_7_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_7_4;
    // 

    T5_INIT_1( 8, 100, 4096)
    MRAC_INIT_1( 9, 100, 32768, 11, 16)
    T1_INIT_1(11, 200, 131072)
    T1_INIT_2(10, 200, 131072)
    MRB_INIT_1(12, 200, 262144, 14, 16)
    T2_INIT_HH_4(13, 200, 16384)
    T3_INIT_HH_1(15, 110, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_16_above_threshold;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_1;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_2;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_3;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_4;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_5;
    //

    T1_INIT_4(17, 110, 262144)
    T2_INIT_HH_4(18, 110, 16384)
    T2_INIT_HH_2(19, 220, 16384)
    T2_INIT_HH_5(20, 220, 16384)
    T1_INIT_5(21, 221, 262144)
    T2_INIT_5(22, 221, 16384)
    UM_INIT_3(23, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);
            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);
            d_12_xor_construction();
            d_7_auto_sampling_hash_call.apply(SRCIP, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_32);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //

        T2_RUN_AFTER_1_KEY_1( 4, SRCIP, 1)
        T2_RUN_AFTER_5_KEY_1( 3, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_7_res_hash_call.apply(SRCIP, ig_md.d_7_res_hash);
        d_7_tcam_lpm_2.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16_1024, ig_md.d_7_base_16_2048, ig_md.d_7_threshold);
        d_7_index_hash_call_1.apply(SRCIP, ig_md.d_7_index1_16);
        update_7_1.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index1_16, ig_md.d_7_res_hash[1:1], 1, ig_md.d_7_est_1);
        d_7_index_hash_call_2.apply(SRCIP, ig_md.d_7_index2_16);
        update_7_2.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index2_16, ig_md.d_7_res_hash[2:2], 1, ig_md.d_7_est_2);
        d_7_index_hash_call_3.apply(SRCIP, ig_md.d_7_index3_16);
        update_7_3.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index3_16, ig_md.d_7_res_hash[3:3], 1, ig_md.d_7_est_3);
        d_7_index_hash_call_4.apply(SRCIP, ig_md.d_7_index4_16);
        update_7_4.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index4_16, ig_md.d_7_res_hash[4:4], 1, ig_md.d_7_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(7)
        // 

        // PCSA for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            update_8.apply(DSTIP, ig_md.d_8_bitmask);
        //

        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        T1_RUN_1_KEY_2(11, SRCIP, DSTIP)
        T1_RUN_2_KEY_2(10, SRCIP, DSTIP) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0) { /* process_new_flow() */ }
        // MRB for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_32);
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_32, ig_md.d_12_index1_16);
        //

        T2_RUN_AFTER_4_KEY_2(13, SRCIP, DSTIP, 1)
        T3_RUN_AFTER_1_KEY_2(15, SRCIP, SRCPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_14_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_res_hash);
            update_14_1.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
            update_14_3.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[3:3], 1, ig_md.d_14_est_3);
            update_14_4.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[4:4], 1, ig_md.d_14_est_4);
            update_14_5.apply(SRCIP, SRCPORT, 1, ig_md.d_14_res_hash[5:5], 1, ig_md.d_14_est_5);
            d_16_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_14_est_2, ig_md.d_14_est_3, ig_md.d_14_est_4, ig_md.d_14_est_5, ig_md.d_16_above_threshold);
        //

        T1_RUN_4_KEY_2(17, DSTIP, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_2(18, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_2_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_5_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0 || ig_md.d_21_est1_4 == 0 || ig_md.d_21_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_5_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // UnivMon for inst 23
            d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_res_hash); 
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16, ig_md.d_23_threshold); 
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16); 
            d_23_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index2_16); 
            d_23_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index3_16); 
            UM_RUN_END_3(23, ig_md.d_23_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(23) 
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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