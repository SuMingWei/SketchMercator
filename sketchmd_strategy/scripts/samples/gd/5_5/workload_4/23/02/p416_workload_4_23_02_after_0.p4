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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 65536)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_2_above_threshold;
    // 

    MRAC_INIT_1( 4, 100, 16384, 10, 16)
    T4_INIT_1( 5, 100, 32768)
    T2_INIT_HH_5( 6, 100, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_hash_call;
        TCAM_LPM_HLLPCSA() d_8_tcam_lpm;
        GET_BITMASK() d_8_get_bitmask;
        T2_T5_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_3;
    //

    MRAC_INIT_1( 9, 200, 16384, 11,  8)
    T2_INIT_HH_3(10, 110, 8192)
    MRAC_INIT_1(11, 110, 16384, 10, 16)
    T2_INIT_4(12, 110, 4096)
    UM_INIT_5(13, 110, 10, 16384)
    T2_INIT_HH_2(14, 220, 4096)
    T2_INIT_HH_3(15, 220, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 220)
        ABOVE_THRESHOLD_4() d_18_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_18_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_18_2;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_18_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_18_3;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_18_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_18_4;
    // 

    UM_INIT_1(17, 220, 10, 16384)
    T1_INIT_4(19, 221, 262144)
    T2_INIT_HH_3(20, 221, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(23, 221)
        ABOVE_THRESHOLD_4() d_23_above_threshold;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_23_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_23_1;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_23_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_23_2;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_23_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_23_3;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_23_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_23_4;
    // 

    UM_INIT_3(22, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_1(2, SRCIP, SIZE)
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

        T2_RUN_AFTER_5_KEY_1( 6, DSTIP, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_8_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            update_8_1.apply(SRCIP, DSTIP, 1, ig_md.d_8_bitmask, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(8)
        //

        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        T2_RUN_AFTER_3_KEY_2(10, SRCIP, SRCPORT, 1)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        T2_RUN_4_KEY_2(12, DSTIP, DSTPORT, 1)
        // UnivMon for inst 13
            d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_13_index3_16); 
            d_13_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_13_index4_16); 
            d_13_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_13_index5_16); 
            UM_RUN_END_5(13, ig_md.d_13_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(13) 
        //

        T2_RUN_AFTER_2_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_3_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
        d_18_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index3_16);
        update_18_3.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index3_16, ig_md.d_18_res_hash[3:3], SIZE, ig_md.d_18_est_3);
        d_18_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index4_16);
        update_18_4.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index4_16, ig_md.d_18_res_hash[4:4], SIZE, ig_md.d_18_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(18)
        // 

        // UnivMon for inst 17
            d_17_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index1_16); 
            UM_RUN_END_1(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(17) 
        //

        T1_RUN_4_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_19_est1_1 == 0 || ig_md.d_19_est1_2 == 0 || ig_md.d_19_est1_3 == 0 || ig_md.d_19_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_23_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_res_hash);
        d_23_tcam_lpm_2.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16_1024, ig_md.d_23_base_16_2048, ig_md.d_23_threshold);
        d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
        update_23_1.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index1_16, ig_md.d_23_res_hash[1:1], SIZE, ig_md.d_23_est_1);
        d_23_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index2_16);
        update_23_2.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index2_16, ig_md.d_23_res_hash[2:2], SIZE, ig_md.d_23_est_2);
        d_23_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index3_16);
        update_23_3.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index3_16, ig_md.d_23_res_hash[3:3], SIZE, ig_md.d_23_est_3);
        d_23_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index4_16);
        update_23_4.apply(ig_md.d_23_base_16_1024, ig_md.d_23_index4_16, ig_md.d_23_res_hash[4:4], SIZE, ig_md.d_23_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(23)
        // 

        // UnivMon for inst 22
            d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index2_16); 
            d_22_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index3_16); 
            UM_RUN_END_3(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(22) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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