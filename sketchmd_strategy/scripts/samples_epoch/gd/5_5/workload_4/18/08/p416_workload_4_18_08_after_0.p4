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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(65536, 16, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_1_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_1_above_threshold;
    // 

    MRAC_INIT_1( 3, 100, 32768, 11, 16)
    T1_INIT_4( 4, 100, 262144)
    T3_INIT_HH_4( 5, 100, 16384)
    T2_INIT_HH_5( 6, 100, 4096)
    MRAC_INIT_1( 7, 100, 32768, 11, 16)
    UM_INIT_3( 8, 200, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_10_hash_call;
        TCAM_LPM_HLLPCSA() d_10_tcam_lpm;
        GET_BITMASK() d_10_get_bitmask;
        T2_T5_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_4;
    //

    MRAC_INIT_1(11, 110, 32768, 11, 16)
    T1_INIT_5(12, 110, 262144)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(14, 110)
        ABOVE_THRESHOLD_4() d_14_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_14_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_14_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_14_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_14_4;
    // 

    T2_INIT_HH_1(15, 220, 4096)
    UM_INIT_5(16, 220, 11, 32768)
    T4_INIT_1(17, 221, 4096)
    T3_INIT_HH_1(18, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_32);

        //


        // apply O2
        T2_RUN_AFTER_5_KEY_1(1, SRCIP, 1)
        // 

        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3_1.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        T1_RUN_4_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_1( 5, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_1( 6, DSTIP, 1)
        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7_1.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_8_index3_16); 
            UM_RUN_END_3(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(8) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_10_level);
            d_10_get_bitmask.apply(ig_md.d_10_level, ig_md.d_10_bitmask);
            update_10_1.apply(SRCIP, SRCPORT, 1, ig_md.d_10_bitmask, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, SRCPORT, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, SRCPORT, 1, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, SRCPORT, 1, ig_md.d_10_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(10)
        //

        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
            update_11_1.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        T1_RUN_5_KEY_2(12, DSTIP, DSTPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0 || ig_md.d_12_est1_3 == 0 || ig_md.d_12_est1_4 == 0 || ig_md.d_12_est1_5 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[0:0], SIZE, ig_md.d_14_est_1);
        d_14_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_14_index2_16);
        update_14_2.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index2_16, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_2);
        d_14_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_14_index3_16);
        update_14_3.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index3_16, ig_md.d_14_res_hash[2:2], SIZE, ig_md.d_14_est_3);
        d_14_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_14_index4_16);
        update_14_4.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index4_16, ig_md.d_14_res_hash[3:3], SIZE, ig_md.d_14_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(14)
        // 

        T2_RUN_AFTER_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index3_16); 
            d_16_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index4_16); 
            d_16_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index5_16); 
            UM_RUN_END_5(16, ig_md.d_16_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(16) 
        //

        // HLL for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_32, ig_md.d_17_level);
            update_17_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_level);
        //

        T3_RUN_AFTER_1_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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