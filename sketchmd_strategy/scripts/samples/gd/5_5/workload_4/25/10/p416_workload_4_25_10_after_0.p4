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
    METADATA_DIM(25)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_25_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    T2_INIT_3( 2, 100, 8192)
    T2_INIT_HH_1( 4, 100, 8192)
    T3_INIT_HH_2( 3, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(6, 100)
        ABOVE_THRESHOLD_4() d_6_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_6_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_6_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_6_3;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_6_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_6_4;
    // 

    T4_INIT_1( 7, 200, 65536)
    MRB_INIT_1( 8, 110, 131072, 14,  8)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_9_above_threshold;
    // 

    T2_INIT_HH_3(11, 110, 16384)
    MRAC_INIT_1(12, 110, 32768, 11, 16)

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_13_1;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_2;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_3;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_4;
    // 

    T2_INIT_1(15, 110, 8192)
    MRAC_INIT_1(16, 110, 8192, 10,  8)

    // apply O2
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_17_1;
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_17_2;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_20_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_2;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_20_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_20_4;
    //

    T1_INIT_1(21, 221, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_24_above_threshold;
        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_24_hash_call;
        TCAM_LPM_HLLPCSA() d_24_tcam_lpm;
        GET_BITMASK() d_24_get_bitmask;
        T2_T5_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_1;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_24_2;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_24_3;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_24_4;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_24_5;
    //

    T3_INIT_HH_3(23, 221, 16384)
    MRAC_INIT_1(25, 221, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_32);

            d_25_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_1_KEY_1( 4, DSTIP, 1)
        T3_RUN_AFTER_2_KEY_1( 3, DSTIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash);
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048, ig_md.d_6_threshold);
        d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
        update_6_1.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index1_16, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_1);
        d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16);
        update_6_2.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index2_16, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_2);
        d_6_index_hash_call_3.apply(DSTIP, ig_md.d_6_index3_16);
        update_6_3.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index3_16, ig_md.d_6_res_hash[3:3], 1, ig_md.d_6_est_3);
        d_6_index_hash_call_4.apply(DSTIP, ig_md.d_6_index4_16);
        update_6_4.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index4_16, ig_md.d_6_res_hash[4:4], 1, ig_md.d_6_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(6)
        // 

        // HLL for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            update_7.apply(SRCIP, DSTIP, ig_md.d_7_level);
        //

        // MRB for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_32);
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_32, ig_md.d_8_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_2(9, SRCIP, SRCPORT, 1)
        // 

        T2_RUN_AFTER_3_KEY_2(11, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //


        // apply O2
        T1_RUN_4_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0 || ig_md.d_13_est1_4 == 0) { /* process_new_flow() */ }
        // 

        T2_RUN_1_KEY_2(15, DSTIP, DSTPORT, SIZE)
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //


        // apply O2
        T1_RUN_2_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0) { /* process_new_flow() */ }
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_20_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_20_est_1);
            update_20_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_20_est_2);
            update_20_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_20_est_3);
            update_20_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_20_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(20)
        //

        T1_RUN_1_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_24_tcam_lpm.apply(ig_md.d_22_sampling_hash_32, ig_md.d_24_level);
            d_24_get_bitmask.apply(ig_md.d_24_level, ig_md.d_24_bitmask);
            update_24_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_bitmask, ig_md.d_24_est_1);
            update_24_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_est_2);
            update_24_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_est_3);
            update_24_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_est_4);
            update_24_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_24_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(24)
        //

        T3_RUN_AFTER_3_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 25
            d_25_tcam_lpm.apply(ig_md.d_25_sampling_hash_16, ig_md.d_25_base_16);
            d_25_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index1_16);
            update_25.apply(ig_md.d_25_base_16, ig_md.d_25_index1_16);
        //

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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