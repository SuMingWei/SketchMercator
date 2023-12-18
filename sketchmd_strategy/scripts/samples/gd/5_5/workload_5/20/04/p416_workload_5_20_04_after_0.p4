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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 262144)
    MRB_INIT_1( 2, 100, 262144, 15,  8)
    T2_INIT_3( 3, 100, 4096)
    T1_INIT_4( 4, 100, 524288)
    MRB_INIT_1( 5, 100, 262144, 15,  8)
    T1_INIT_1( 6, 200, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 200)
        ABOVE_THRESHOLD_5() d_10_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_10_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_10_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_10_4;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_10_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_10_5;
    // 

    UM_INIT_5(11, 200, 10, 16384)
    T2_INIT_4(12, 110, 16384)
    UM_INIT_5(13, 110, 11, 32768)
    T3_INIT_HH_1(15, 110, 4096)
    T2_INIT_HH_1(17, 110, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_16_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_16_res_hash_call;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_2;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_3;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_16_4;
    //

    MRB_INIT_1(18, 220, 262144, 15,  8)
    MRB_INIT_1(19, 220, 131072, 14,  8)
    T5_INIT_1(20, 220, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_32);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //

        T2_RUN_3_KEY_1( 3, SRCIP, 1)
        T1_RUN_4_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        T1_RUN_1_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_8_1.apply(SRCIP, DSTIP, SIZE, SIZE, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, SIZE, SIZE, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, SIZE, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_8_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(8)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], SIZE, ig_md.d_10_est_3);
        d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16);
        update_10_4.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index4_16, ig_md.d_10_res_hash[4:4], SIZE, ig_md.d_10_est_4);
        d_10_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_10_index5_16);
        update_10_5.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index5_16, ig_md.d_10_res_hash[5:5], SIZE, ig_md.d_10_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(10)
        // 

        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_11_index4_16); 
            d_11_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_11_index5_16); 
            UM_RUN_END_5(11, ig_md.d_11_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(11) 
        //

        T2_RUN_4_KEY_2(12, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 13
            d_13_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_13_index3_16); 
            d_13_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_13_index4_16); 
            d_13_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_13_index5_16); 
            UM_RUN_END_5(13, ig_md.d_13_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(13) 
        //

        T3_RUN_AFTER_1_KEY_2(15, DSTIP, DSTPORT, SIZE)
        T2_RUN_AFTER_1_KEY_2(17, DSTIP, DSTPORT, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_16_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_16_res_hash);
            update_16_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[1:1], 1, ig_md.d_16_est_1);
            update_16_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[2:2], 1, ig_md.d_16_est_2);
            update_16_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[3:3], ig_md.d_16_est_3);
            update_16_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_16_res_hash[4:4], ig_md.d_16_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(16)
        //

        // MRB for inst 18
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_32);
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16);
            update_18.apply(ig_md.d_18_base_32, ig_md.d_18_index1_16);
        //

        // MRB for inst 19
            d_19_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_19_base_32);
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16);
            update_19.apply(ig_md.d_19_base_32, ig_md.d_19_index1_16);
        //

        // PCSA for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_20_level);
            d_20_get_bitmask.apply(ig_md.d_20_level, ig_md.d_20_bitmask);
            update_20.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_bitmask);
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
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