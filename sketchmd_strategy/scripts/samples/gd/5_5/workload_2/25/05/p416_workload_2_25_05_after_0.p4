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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 28672)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_2_1;
    // 

    T1_INIT_2( 3, 110, 262144)
    T1_INIT_4( 1, 110, 131072)
    T1_INIT_5( 4, 110, 262144)
    MRB_INIT_1( 6, 110, 262144, 15,  8)
    T2_INIT_HH_1(12, 110, 8192)
    T2_INIT_HH_1(15, 110, 16384)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_7_above_threshold;
    // 

    T2_INIT_HH_2(18, 110, 4096)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_8_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
    // 

    T2_INIT_HH_5(16, 110, 8192)
    T2_INIT_HH_5(19, 110, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(24, 110)
        ABOVE_THRESHOLD_3() d_24_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_24_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_24_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_24_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_24_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_24_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_24_3;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(21, 110)
        ABOVE_THRESHOLD_1() d_21_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_21_1;
    // 

    UM_INIT_2(22, 110, 11, 32768)
    UM_INIT_4(23, 110, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_24_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_22_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_23_sampling_hash_16);

        //


        // apply O2
        T1_RUN_1_KEY_2(2, DSTIP, DSTPORT) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_2_KEY_2( 3, DSTIP, DSTPORT) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 4, DSTIP, DSTPORT) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        T2_RUN_AFTER_1_KEY_2(12, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_1_KEY_2(15, DSTIP, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_2_KEY_2(7, DSTIP, DSTPORT, 1)
        // 

        T2_RUN_AFTER_2_KEY_2(18, DSTIP, DSTPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(8, DSTIP, DSTPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(9, DSTIP, DSTPORT, SIZE)
        // 

        T2_RUN_AFTER_5_KEY_2(16, DSTIP, DSTPORT, SIZE)
        T2_RUN_AFTER_5_KEY_2(19, DSTIP, DSTPORT, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_24_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_24_res_hash);
        d_24_tcam_lpm_2.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16_1024, ig_md.d_24_base_16_2048, ig_md.d_24_threshold);
        d_24_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_24_index1_16);
        update_24_1.apply(ig_md.d_24_base_16_1024, ig_md.d_24_index1_16, ig_md.d_24_res_hash[1:1], SIZE, ig_md.d_24_est_1);
        d_24_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_24_index2_16);
        update_24_2.apply(ig_md.d_24_base_16_1024, ig_md.d_24_index2_16, ig_md.d_24_res_hash[2:2], SIZE, ig_md.d_24_est_2);
        d_24_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_24_index3_16);
        update_24_3.apply(ig_md.d_24_base_16_1024, ig_md.d_24_index3_16, ig_md.d_24_res_hash[3:3], SIZE, ig_md.d_24_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(24)
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_21_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], SIZE, ig_md.d_21_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(21)
        // 

        // UnivMon for inst 22
            d_22_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_22_index2_16); 
            UM_RUN_END_2(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(22) 
        //

        // UnivMon for inst 23
            d_23_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_23_res_hash); 
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16, ig_md.d_23_threshold); 
            d_23_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_23_index1_16); 
            d_23_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_23_index2_16); 
            d_23_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_23_index3_16); 
            d_23_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_23_index4_16); 
            UM_RUN_END_4(23, ig_md.d_23_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(23) 
        //

        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip, ig_md.hf_dstport); 
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