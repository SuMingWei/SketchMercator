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
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    T1_INIT_1( 2, 100, 262144)
    T2_INIT_3( 3, 100, 8192)
    UM_INIT_4( 4, 100, 11, 32768)
    T1_INIT_5( 5, 100, 524288)
    MRB_INIT_1( 6, 100, 524288, 15, 16)
    T2_INIT_HH_3( 7, 100, 8192)
    T1_INIT_1( 8, 200, 131072)
    T2_INIT_HH_1(10, 110, 4096)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_1;
        T2_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_2() d_13_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_13_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_13_2;
    // 

    T1_INIT_5(14, 110, 262144)
    UM_INIT_4(15, 110, 10, 16384)
    UM_INIT_5(16, 110, 10, 16384)
    T1_INIT_3(17, 220, 131072)
    T2_INIT_HH_2(19, 220, 8192)
    T2_INIT_HH_4(18, 220, 4096)
    T1_INIT_5(20, 221, 524288)
    T4_INIT_1(21, 221, 65536)
    MRB_INIT_1(22, 221, 131072, 14,  8)
    T2_INIT_HH_2(23, 221, 4096)
    MRAC_INIT_1(24, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_32);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_1( 2, SRCIP)
        T2_RUN_3_KEY_1( 3, SRCIP, 1)
        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16); 
            UM_RUN_END_4(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(4) 
        //

        T1_RUN_5_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0 || ig_md.d_5_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        T2_RUN_AFTER_3_KEY_1( 7, DSTIP, 1)
        T1_RUN_1_KEY_2( 8, SRCIP, DSTIP)
        T2_RUN_AFTER_1_KEY_2(10, SRCIP, SRCPORT, 1)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_11_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, SRCPORT, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, SRCPORT, 1, ig_md.d_11_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(11)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(13)
        // 

        T1_RUN_5_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0 || ig_md.d_14_est1_5 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 15
            d_15_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_15_index4_16); 
            UM_RUN_END_4(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(15) 
        //

        // UnivMon for inst 16
            d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_16_index3_16); 
            d_16_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_16_index4_16); 
            d_16_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_16_index5_16); 
            UM_RUN_END_5(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(16) 
        //

        T1_RUN_3_KEY_4(17, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_4_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_5_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0 || ig_md.d_20_est1_3 == 0 || ig_md.d_20_est1_4 == 0 || ig_md.d_20_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 21
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_32, ig_md.d_21_level);
            update_21.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_level);
        //

        // MRB for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_32);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_32, ig_md.d_22_index1_16);
        //

        T2_RUN_AFTER_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 24
            d_24_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_24_base_16);
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16);
            update_24.apply(ig_md.d_24_base_16, ig_md.d_24_index1_16);
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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