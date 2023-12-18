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
    METADATA_DIM(24)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 131072)
    T3_INIT_HH_2( 2, 100, 16384)
    T3_INIT_HH_3( 3, 100, 16384)
    MRAC_INIT_1( 4, 100, 16384, 11,  8)
    T1_INIT_2( 5, 200, 131072)
    T2_INIT_2( 6, 200, 4096)
    T3_INIT_HH_2( 7, 110, 4096)
    UM_INIT_3( 8, 110, 10, 16384)
    T1_INIT_1( 9, 110, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_11_tcam_lpm;
        GET_BITMASK() d_11_get_bitmask;
        T5_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_1;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_12_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_2;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_5;
    //


    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_1() d_13_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_13_1;
    // 

    T1_INIT_1(17, 220, 262144)
    T1_INIT_2(15, 220, 131072)
    T1_INIT_5(16, 220, 524288)
    MRB_INIT_1(18, 220, 524288, 15, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_20_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_21_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_2;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_3;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_5;
    //

    MRAC_INIT_1(22, 220, 16384, 10, 16)
    T2_INIT_HH_1(23, 221, 16384)
    MRAC_INIT_1(24, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        T3_RUN_AFTER_2_KEY_1( 2, DSTIP, 1)
        T3_RUN_AFTER_3_KEY_1( 3, DSTIP, SIZE)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T1_RUN_2_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_2_KEY_2( 6, SRCIP, DSTIP, SIZE)
        T3_RUN_AFTER_2_KEY_2( 7, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_8_index3_16); 
            UM_RUN_END_3(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(8) 
        //

        T1_RUN_1_KEY_2( 9, DSTIP, DSTPORT)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_11_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_11_level);
            d_11_get_bitmask.apply(ig_md.d_11_level, ig_md.d_11_bitmask);
            update_11_1.apply(DSTIP, DSTPORT, 1, ig_md.d_11_bitmask, ig_md.d_11_est_1);
            update_11_2.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_11_est_2);
            update_11_3.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_11_est_3);
            d_12_above_threshold.apply(ig_md.d_11_est_2, ig_md.d_11_est_3, ig_md.d_12_above_threshold);
            update_11_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_est_4);
            update_11_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_est_5);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(13)
        // 

        T1_RUN_1_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T1_RUN_2_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0 || ig_md.d_16_est1_4 == 0 || ig_md.d_16_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_32);
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16);
            update_18.apply(ig_md.d_18_base_32, ig_md.d_18_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_19_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_19_est_1);
            d_20_above_threshold.apply(ig_md.d_19_est_1, ig_md.d_20_above_threshold);
            update_19_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_19_est_2);
            update_19_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_19_est_3);
            update_19_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_19_est_4);
            d_21_above_threshold.apply(ig_md.d_19_est_2, ig_md.d_19_est_3, ig_md.d_19_est_4, ig_md.d_21_above_threshold);
            update_19_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_19_est_5);
        //

        // MRAC for inst 22
            d_22_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_22_base_16);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_16, ig_md.d_22_index1_16);
        //

        T2_RUN_AFTER_1_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 24
            d_24_tcam_lpm.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16);
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16);
            update_24.apply(ig_md.d_24_base_16, ig_md.d_24_index1_16);
        //

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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