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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 131072)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_2_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(5, 100)
        ABOVE_THRESHOLD_4() d_5_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_5_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_5_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_5_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_5_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_5_4;
    // 

    T1_INIT_4( 6, 100, 131072)
    T2_INIT_HH_3( 7, 100, 8192)
    UM_INIT_3( 8, 200, 10, 16384)
    T1_INIT_5( 9, 110, 524288)
    T3_INIT_HH_4(10, 110, 4096)
    UM_INIT_1(11, 110, 10, 16384)
    T1_INIT_1(12, 110, 262144)
    T2_INIT_HH_2(13, 110, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(15, 110)
        ABOVE_THRESHOLD_2() d_15_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_15_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_15_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_15_2;
    // 

    MRAC_INIT_1(16, 220, 8192, 10,  8)
    T1_INIT_1(17, 221, 131072)
    T4_INIT_1(18, 221, 32768)

    // apply O2
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_1;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_2;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_3;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_4;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_19_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_19_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_20_1;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_20_2;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_20_3;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_20_4;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_20_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_20_above_threshold;
    // 

    MRAC_INIT_1(23, 221, 8192, 10,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_32);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_3_KEY_1(2, SRCIP, 1)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_5_res_hash_call.apply(SRCIP, ig_md.d_5_res_hash);
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048, ig_md.d_5_threshold);
        d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
        update_5_1.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index1_16, ig_md.d_5_res_hash[1:1], SIZE, ig_md.d_5_est_1);
        d_5_index_hash_call_2.apply(SRCIP, ig_md.d_5_index2_16);
        update_5_2.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index2_16, ig_md.d_5_res_hash[2:2], SIZE, ig_md.d_5_est_2);
        d_5_index_hash_call_3.apply(SRCIP, ig_md.d_5_index3_16);
        update_5_3.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index3_16, ig_md.d_5_res_hash[3:3], SIZE, ig_md.d_5_est_3);
        d_5_index_hash_call_4.apply(SRCIP, ig_md.d_5_index4_16);
        update_5_4.apply(ig_md.d_5_base_16_1024, ig_md.d_5_index4_16, ig_md.d_5_res_hash[4:4], SIZE, ig_md.d_5_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(5)
        // 

        T1_RUN_4_KEY_1( 6, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_1( 7, DSTIP, SIZE)
        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_8_index3_16); 
            UM_RUN_END_3(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(8) 
        //

        T1_RUN_5_KEY_2( 9, SRCIP, SRCPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0 || ig_md.d_9_est1_4 == 0 || ig_md.d_9_est1_5 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_2(10, SRCIP, SRCPORT, 1)
        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16); 
            UM_RUN_END_1(11, ig_md.d_11_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(11) 
        //

        T1_RUN_1_KEY_2(12, DSTIP, DSTPORT) if (ig_md.d_12_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(13, DSTIP, DSTPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_15_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_res_hash);
        d_15_tcam_lpm_2.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16_1024, ig_md.d_15_base_16_2048, ig_md.d_15_threshold);
        d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16);
        update_15_1.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index1_16, ig_md.d_15_res_hash[1:1], SIZE, ig_md.d_15_est_1);
        d_15_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_15_index2_16);
        update_15_2.apply(ig_md.d_15_base_16_1024, ig_md.d_15_index2_16, ig_md.d_15_res_hash[2:2], SIZE, ig_md.d_15_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(15)
        // 

        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        T1_RUN_1_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_17_est1_1 == 0) { /* process_new_flow() */ }
        // HLL for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_32, ig_md.d_18_level);
            update_18.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_level);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // 

        // MRAC for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_16, ig_md.d_23_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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