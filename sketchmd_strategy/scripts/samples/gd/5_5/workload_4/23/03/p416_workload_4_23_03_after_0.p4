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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;
        action d_11_xor_construction() { ig_md.d_11_sampling_hash_16 = ig_md.d_4_sampling_hash_16 ^ ig_md.d_6_sampling_hash_16; }

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
    //

    MRAC_INIT_1( 4, 100, 8192, 10,  8)
    T4_INIT_1( 5, 100, 65536)
    MRAC_INIT_1( 6, 100, 8192, 10,  8)
    T1_INIT_4( 7, 200, 524288)
    T5_INIT_1( 8, 200, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_res_hash_call;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_2;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_3;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_4;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_5;
    //

    MRAC_INIT_1(11, 200, 16384, 10, 16)
    T1_INIT_4(12, 110, 131072)
    MRB_INIT_1(13, 110, 131072, 14,  8)
    T2_INIT_HH_3(15, 110, 16384)
    T2_INIT_HH_4(14, 110, 16384)
    T1_INIT_3(16, 110, 131072)
    T2_INIT_3(17, 110, 4096)

    // apply O2
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_18_1;
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_18_2;
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_18_3;
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_18_4;
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_18_5;
    // 

    MRAC_INIT_1(20, 220, 32768, 11, 16)
    T1_INIT_5(21, 221, 524288)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(23, 221)
        ABOVE_THRESHOLD_5() d_23_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_23_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_23_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_23_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_23_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_23_3;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_23_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_23_4;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_23_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_23_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);
            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);
            d_11_xor_construction();
            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(SRCIP, 1, SIZE, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, ig_md.d_3_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(3)
        //

        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        // HLL for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            update_5.apply(DSTIP, ig_md.d_5_level);
        //

        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        T1_RUN_4_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0 || ig_md.d_7_est1_3 == 0 || ig_md.d_7_est1_4 == 0) { /* process_new_flow() */ }
        // PCSA for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            update_8.apply(SRCIP, DSTIP, ig_md.d_8_bitmask);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
            update_10_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_res_hash[3:3], SIZE, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_res_hash[4:4], SIZE, ig_md.d_10_est_4);
            update_10_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_10_res_hash[5:5], ig_md.d_10_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(10)
        //

        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        T1_RUN_4_KEY_2(12, SRCIP, SRCPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0 || ig_md.d_12_est1_3 == 0 || ig_md.d_12_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_32);
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_32, ig_md.d_13_index1_16);
        //

        T2_RUN_AFTER_3_KEY_2(15, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_4_KEY_2(14, SRCIP, SRCPORT, 1)
        T1_RUN_3_KEY_2(16, DSTIP, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_2(17, DSTIP, DSTPORT, SIZE)

        // apply O2
        T1_RUN_5_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0 || ig_md.d_18_est1_4 == 0 || ig_md.d_18_est1_5 == 0) { /* process_new_flow() */ }
        // 

        // MRAC for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16);
            d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
            update_20.apply(ig_md.d_20_base_16, ig_md.d_20_index1_16);
        //

        T1_RUN_5_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0 || ig_md.d_21_est1_4 == 0 || ig_md.d_21_est1_5 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], SIZE, ig_md.d_23_est_1);
        d_23_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index2_16);
        update_23_2.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index2_16, ig_md.d_23_res_hash[2:2], SIZE, ig_md.d_23_est_2);
        d_23_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index3_16);
        update_23_3.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index3_16, ig_md.d_23_res_hash[3:3], SIZE, ig_md.d_23_est_3);
        d_23_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index4_16);
        update_23_4.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index4_16, ig_md.d_23_res_hash[4:4], SIZE, ig_md.d_23_est_4);
        d_23_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index5_16);
        update_23_5.apply(ig_md.d_23_base_16_2048, ig_md.d_23_index5_16, ig_md.d_23_res_hash[5:5], SIZE, ig_md.d_23_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(23)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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