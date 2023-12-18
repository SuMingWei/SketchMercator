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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T1_INIT_1( 2, 110, 524288)
    T1_INIT_1( 3, 110, 131072)
    T1_INIT_4( 1, 110, 524288)
    T1_INIT_5( 4, 110, 262144)
    T4_INIT_1( 5, 110, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_10_above_threshold;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_2;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_11_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_3;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_4;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_5;
    //

    T2_INIT_HH_2(17, 110, 8192)
    T2_INIT_HH_3(15, 110, 4096)
    T2_INIT_HH_4(14, 110, 8192)
    T2_INIT_HH_4(16, 110, 16384)

    // apply O2
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_6_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 

    T3_INIT_HH_5(12, 110, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(18, 110)
        ABOVE_THRESHOLD_1() d_18_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
    // 

    UM_INIT_3(20, 110, 11, 32768)
    UM_INIT_5(19, 110, 10, 16384)
    UM_INIT_5(21, 110, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_20_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_19_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_21_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 3, SRCIP, SRCPORT) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 4, SRCIP, SRCPORT) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            update_5.apply(SRCIP, SRCPORT, ig_md.d_5_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_8_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_res_hash);
            update_8_1.apply(SRCIP, SRCPORT, 1, ig_md.d_8_res_hash[1:1], SIZE, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, SRCPORT, 1, ig_md.d_8_res_hash[2:2], SIZE, ig_md.d_8_est_2);
            d_10_above_threshold.apply(ig_md.d_8_est_1, ig_md.d_8_est_2, ig_md.d_10_above_threshold);
            update_8_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_8_res_hash[3:3], SIZE, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_8_res_hash[4:4], SIZE, ig_md.d_8_est_4);
            update_8_5.apply(SRCIP, SRCPORT, SIZE, ig_md.d_8_res_hash[5:5], SIZE, ig_md.d_8_est_5);
            d_11_above_threshold.apply(ig_md.d_8_est_3, ig_md.d_8_est_4, ig_md.d_8_est_5, ig_md.d_11_above_threshold);
        //

        T2_RUN_AFTER_2_KEY_2(17, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_3_KEY_2(15, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_4_KEY_2(14, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_4_KEY_2(16, SRCIP, SRCPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(6, SRCIP, SRCPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(7, SRCIP, SRCPORT, 1)
        // 

        T3_RUN_AFTER_5_KEY_2(12, SRCIP, SRCPORT, SIZE)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_18_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(18)
        // 

        // UnivMon for inst 20
            d_20_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_20_res_hash); 
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16, ig_md.d_20_threshold); 
            d_20_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_20_index1_16); 
            d_20_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_20_index2_16); 
            d_20_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_20_index3_16); 
            UM_RUN_END_3(20, ig_md.d_20_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(20) 
        //

        // UnivMon for inst 19
            d_19_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_19_index3_16); 
            d_19_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_19_index4_16); 
            d_19_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_19_index5_16); 
            UM_RUN_END_5(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(19) 
        //

        // UnivMon for inst 21
            d_21_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_21_index3_16); 
            d_21_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_21_index4_16); 
            d_21_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_21_index5_16); 
            UM_RUN_END_5(21, ig_md.d_21_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(21) 
        //

        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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