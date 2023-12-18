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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_1;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_2;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_3;
    // 

    T2_INIT_HH_1( 3, 100, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(6, 100)
        ABOVE_THRESHOLD_5() d_6_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_6_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_6_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_6_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_6_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_6_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_6_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_6_4;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_6_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_6_5;
    // 

    T4_INIT_1( 7, 100, 16384)
    MRB_INIT_1( 8, 100, 524288, 15, 16)
    T1_INIT_1( 9, 200, 524288)
    MRAC_INIT_1(10, 200, 8192, 10,  8)
    T2_INIT_1(11, 110, 4096)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_13_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_12_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_12_2;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_12_3;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_12_4;
    //

    T2_INIT_HH_1(14, 110, 4096)
    UM_INIT_2(15, 110, 11, 32768)
    T1_INIT_3(16, 220, 262144)
    MRB_INIT_1(17, 221, 262144, 14, 16)
    T2_INIT_2(18, 221, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 221)
        ABOVE_THRESHOLD_3() d_20_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_20_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_20_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_20_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_20_3;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(SRCIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_sampling_hash_16);

        //


        // apply O2
        T1_RUN_3_KEY_1(1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // 

        T2_RUN_AFTER_1_KEY_1( 3, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_6_res_hash_call.apply(SRCIP, ig_md.d_6_res_hash);
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048, ig_md.d_6_threshold);
        d_6_index_hash_call_1.apply(SRCIP, ig_md.d_6_index1_16);
        update_6_1.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index1_16, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_1);
        d_6_index_hash_call_2.apply(SRCIP, ig_md.d_6_index2_16);
        update_6_2.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index2_16, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_2);
        d_6_index_hash_call_3.apply(SRCIP, ig_md.d_6_index3_16);
        update_6_3.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index3_16, ig_md.d_6_res_hash[3:3], 1, ig_md.d_6_est_3);
        d_6_index_hash_call_4.apply(SRCIP, ig_md.d_6_index4_16);
        update_6_4.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index4_16, ig_md.d_6_res_hash[4:4], 1, ig_md.d_6_est_4);
        d_6_index_hash_call_5.apply(SRCIP, ig_md.d_6_index5_16);
        update_6_5.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index5_16, ig_md.d_6_res_hash[5:5], 1, ig_md.d_6_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(6)
        // 

        // HLL for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            update_7.apply(DSTIP, ig_md.d_7_level);
        //

        // MRB for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_32);
            d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_32, ig_md.d_8_index1_16);
        //

        T1_RUN_1_KEY_2( 9, SRCIP, DSTIP)
        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T2_RUN_1_KEY_2(11, SRCIP, SRCPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_12_1.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_12_est_3);
            update_12_4.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_12_est_4);
            d_13_above_threshold.apply(ig_md.d_12_est_1, ig_md.d_12_est_2, ig_md.d_12_est_3, ig_md.d_12_est_4, ig_md.d_13_above_threshold);
        //

        T2_RUN_AFTER_1_KEY_2(14, DSTIP, DSTPORT, SIZE)
        // UnivMon for inst 15
            d_15_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_15_index2_16); 
            UM_RUN_END_2(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(15) 
        //

        T1_RUN_3_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_32);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_32, ig_md.d_17_index1_16);
        //

        T2_RUN_2_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
        d_20_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_20_index3_16);
        update_20_3.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index3_16, ig_md.d_20_res_hash[3:3], 1, ig_md.d_20_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(20)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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