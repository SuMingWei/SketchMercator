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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 28672)

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

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 262144)
    T4_INIT_1( 2, 100, 65536)
    T3_INIT_HH_2( 4, 100, 8192)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
    // 

    T2_INIT_HH_4( 5, 100, 4096)
    MRAC_INIT_1( 7, 100, 32768, 11, 16)
    T4_INIT_1( 8, 100, 65536)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_9_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
    // 

    T1_INIT_4(11, 200, 262144)
    T2_INIT_HH_2(12, 200, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(14, 200)
        ABOVE_THRESHOLD_2() d_14_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_14_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_14_2;
    // 

    T2_INIT_HH_2(15, 110, 4096)
    UM_INIT_1(16, 110, 11, 32768)
    UM_INIT_4(17, 110, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_19_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_19_hash_call;
        TCAM_LPM_HLLPCSA() d_19_tcam_lpm;
        GET_BITMASK() d_19_get_bitmask;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_19_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_19_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_19_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_19_4;
    //

    T3_INIT_HH_4(20, 110, 4096)
    T4_INIT_1(22, 220, 32768)

    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_23_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_23_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_23_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_23_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_23_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_23_above_threshold;
    // 

    T2_INIT_1(25, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(SRCIP, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_14_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_16_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_sampling_hash_32);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2.apply(SRCIP, ig_md.d_2_level);
        //

        T3_RUN_AFTER_2_KEY_1( 4, SRCIP, SIZE)

        // apply O2
        T2_RUN_AFTER_4_KEY_1(3, SRCIP, SIZE)
        // 

        T2_RUN_AFTER_4_KEY_1( 5, SRCIP, 1)
        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(SRCIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // HLL for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            update_8.apply(DSTIP, ig_md.d_8_level);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_1(9, DSTIP, SIZE)
        // 

        T1_RUN_4_KEY_2(11, SRCIP, DSTIP) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(12, SRCIP, DSTIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_14_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
        d_14_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_14_index2_16);
        update_14_2.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index2_16, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(14)
        // 

        T2_RUN_AFTER_2_KEY_2(15, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_16_index1_16); 
            UM_RUN_END_1(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(16) 
        //

        // UnivMon for inst 17
            d_17_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_17_index3_16); 
            d_17_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_17_index4_16); 
            UM_RUN_END_4(17, ig_md.d_17_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(17) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_19_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_19_level);
            d_19_get_bitmask.apply(ig_md.d_19_level, ig_md.d_19_bitmask);
            update_19_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_19_bitmask, ig_md.d_19_est_1);
            update_19_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_19_est_2);
            update_19_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_19_est_3);
            update_19_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_19_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(19)
        //

        T3_RUN_AFTER_4_KEY_2(20, DSTIP, DSTPORT, 1)
        // HLL for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_32, ig_md.d_22_level);
            update_22.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_level);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_4(23, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 

        T2_RUN_1_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport, ig_md.hf_dstport); 
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