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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T5_INIT_1( 1, 100, 8192)
    MRAC_INIT_1( 2, 100, 16384, 10, 16)
    T1_INIT_1( 3, 100, 131072)
    T1_INIT_4( 4, 100, 262144)
    T2_INIT_HH_3( 6, 100, 8192)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_5_above_threshold;
    // 

    T1_INIT_5( 8, 110, 131072)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_9_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
    // 

    MRAC_INIT_1(11, 110, 8192, 10,  8)
    T4_INIT_1(12, 110, 32768)
    T2_INIT_HH_2(13, 110, 4096)
    T3_INIT_HH_2(14, 110, 8192)
    T2_INIT_HH_2(15, 110, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(16, 110)
        ABOVE_THRESHOLD_1() d_16_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_16_1;
    // 

    T1_INIT_3(18, 220, 131072)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 220)
        ABOVE_THRESHOLD_4() d_20_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_20_2;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_20_3;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_20_4;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(22, 221)
        ABOVE_THRESHOLD_4() d_22_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_22_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_22_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_22_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_22_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_22_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_22_3;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_22_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_22_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_12_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

        //

        // PCSA for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            d_1_get_bitmask.apply(ig_md.d_1_level, ig_md.d_1_bitmask);
            update_1.apply(SRCIP, ig_md.d_1_bitmask);
        //

        // MRAC for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16);
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_16, ig_md.d_2_index1_16);
        //

        T1_RUN_1_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_1( 6, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_4_KEY_1(5, DSTIP, SIZE)
        // 

        T1_RUN_5_KEY_2( 8, SRCIP, SRCPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0 || ig_md.d_8_est1_5 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_5_KEY_2(9, SRCIP, SRCPORT, SIZE)
        // 

        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        // HLL for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            update_12.apply(DSTIP, DSTPORT, ig_md.d_12_level);
        //

        T2_RUN_AFTER_2_KEY_2(13, DSTIP, DSTPORT, SIZE)
        T3_RUN_AFTER_2_KEY_2(14, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_2_KEY_2(15, DSTIP, DSTPORT, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash);
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048, ig_md.d_16_threshold);
        d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16);
        update_16_1.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16, ig_md.d_16_res_hash[1:1], 1, ig_md.d_16_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(16)
        // 

        T1_RUN_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0 || ig_md.d_18_est1_3 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
        d_20_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index3_16);
        update_20_3.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index3_16, ig_md.d_20_res_hash[3:3], 1, ig_md.d_20_est_3);
        d_20_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index4_16);
        update_20_4.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index4_16, ig_md.d_20_res_hash[4:4], 1, ig_md.d_20_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(20)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_res_hash);
        d_22_tcam_lpm_2.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16_1024, ig_md.d_22_base_16_2048, ig_md.d_22_threshold);
        d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16);
        update_22_1.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index1_16, ig_md.d_22_res_hash[1:1], 1, ig_md.d_22_est_1);
        d_22_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index2_16);
        update_22_2.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index2_16, ig_md.d_22_res_hash[2:2], 1, ig_md.d_22_est_2);
        d_22_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index3_16);
        update_22_3.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index3_16, ig_md.d_22_res_hash[3:3], 1, ig_md.d_22_est_3);
        d_22_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index4_16);
        update_22_4.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index4_16, ig_md.d_22_res_hash[4:4], 1, ig_md.d_22_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(22)
        // 

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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