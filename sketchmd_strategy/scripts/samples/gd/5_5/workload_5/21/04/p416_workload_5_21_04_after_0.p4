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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    T2_INIT_HH_2( 2, 100, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(4, 100)
        ABOVE_THRESHOLD_5() d_4_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_4_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_4_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_4_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_4_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_4_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_4_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_4_4;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_4_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_4_5;
    // 

    T1_INIT_3( 5, 200, 262144)
    T2_INIT_HH_5( 6, 200, 4096)
    UM_INIT_4( 7, 200, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_1;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(11, 110)
        ABOVE_THRESHOLD_5() d_11_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_11_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_11_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_11_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_11_4;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_11_5;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 110)
        ABOVE_THRESHOLD_5() d_13_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_13_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_13_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_13_4;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_13_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_13_5;
    // 

    T2_INIT_HH_3(16, 220, 8192)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_14_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_14_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_14_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_14_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_14_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_14_above_threshold;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(17, 220)
        ABOVE_THRESHOLD_1() d_17_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_17_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_17_1;
    // 

    T1_INIT_3(19, 221, 131072)
    T2_INIT_HH_4(20, 221, 4096)
    MRAC_INIT_1(21, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_AFTER_2_KEY_1( 2, SRCIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash);
        d_4_tcam_lpm_2.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16_1024, ig_md.d_4_base_16_2048, ig_md.d_4_threshold);
        d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16);
        update_4_1.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index1_16, ig_md.d_4_res_hash[1:1], SIZE, ig_md.d_4_est_1);
        d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16);
        update_4_2.apply(ig_md.d_4_base_16_1024, ig_md.d_4_index2_16, ig_md.d_4_res_hash[2:2], SIZE, ig_md.d_4_est_2);
        d_4_index_hash_call_3.apply(DSTIP, ig_md.d_4_index3_16);
        update_4_3.apply(ig_md.d_4_base_16_1024, ig_md.d_4_index3_16, ig_md.d_4_res_hash[3:3], SIZE, ig_md.d_4_est_3);
        d_4_index_hash_call_4.apply(DSTIP, ig_md.d_4_index4_16);
        update_4_4.apply(ig_md.d_4_base_16_1024, ig_md.d_4_index4_16, ig_md.d_4_res_hash[4:4], SIZE, ig_md.d_4_est_4);
        d_4_index_hash_call_5.apply(DSTIP, ig_md.d_4_index5_16);
        update_4_5.apply(ig_md.d_4_base_16_1024, ig_md.d_4_index5_16, ig_md.d_4_res_hash[5:5], SIZE, ig_md.d_4_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(4)
        // 

        T1_RUN_3_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2( 6, SRCIP, DSTIP, SIZE)
        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_7_index4_16); 
            UM_RUN_END_4(7, ig_md.d_7_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(7) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_8_1.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_8_est_1);
            d_9_above_threshold.apply(ig_md.d_8_est_1, ig_md.d_9_above_threshold);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_11_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_res_hash);
        d_11_tcam_lpm_2.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16_1024, ig_md.d_11_base_16_2048, ig_md.d_11_threshold);
        d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
        update_11_1.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index1_16, ig_md.d_11_res_hash[1:1], SIZE, ig_md.d_11_est_1);
        d_11_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_11_index2_16);
        update_11_2.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index2_16, ig_md.d_11_res_hash[2:2], SIZE, ig_md.d_11_est_2);
        d_11_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_11_index3_16);
        update_11_3.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index3_16, ig_md.d_11_res_hash[3:3], SIZE, ig_md.d_11_est_3);
        d_11_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_11_index4_16);
        update_11_4.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index4_16, ig_md.d_11_res_hash[4:4], SIZE, ig_md.d_11_est_4);
        d_11_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_11_index5_16);
        update_11_5.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index5_16, ig_md.d_11_res_hash[5:5], SIZE, ig_md.d_11_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(11)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        d_13_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_13_index3_16);
        update_13_3.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index3_16, ig_md.d_13_res_hash[3:3], 1, ig_md.d_13_est_3);
        d_13_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_13_index4_16);
        update_13_4.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index4_16, ig_md.d_13_res_hash[4:4], 1, ig_md.d_13_est_4);
        d_13_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_13_index5_16);
        update_13_5.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index5_16, ig_md.d_13_res_hash[5:5], 1, ig_md.d_13_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(13)
        // 

        T2_RUN_AFTER_3_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_17_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_res_hash);
        d_17_tcam_lpm_2.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16_1024, ig_md.d_17_base_16_2048, ig_md.d_17_threshold);
        d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index1_16);
        update_17_1.apply(ig_md.d_17_base_16_2048, ig_md.d_17_index1_16, ig_md.d_17_res_hash[1:1], 1, ig_md.d_17_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(17)
        // 

        T1_RUN_3_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_19_est1_1 == 0 || ig_md.d_19_est1_2 == 0 || ig_md.d_19_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 21
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16);
            d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
            update_21.apply(ig_md.d_21_base_16, ig_md.d_21_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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