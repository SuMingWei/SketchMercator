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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

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

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        GET_BITMASK() d_2_get_bitmask;
        T5_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_2;
    //

    T2_INIT_1( 3, 100, 4096)
    UM_INIT_3( 4, 100, 10, 16384)
    T2_INIT_2( 5, 200, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(7, 200)
        ABOVE_THRESHOLD_5() d_7_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_7_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_7_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_7_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_7_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_7_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_7_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_7_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_7_4;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_7_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_7_5;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_8_5;
    //

    UM_INIT_1(10, 110, 11, 32768)
    UM_INIT_5(11, 110, 11, 32768)
    T1_INIT_1(12, 220, 524288)
    T2_INIT_4(13, 220, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(14, 221)
        ABOVE_THRESHOLD_1() d_14_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_14_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_2_level);
            d_2_get_bitmask.apply(ig_md.d_2_level, ig_md.d_2_bitmask);
            update_2_1.apply(SRCIP, 1, ig_md.d_2_bitmask, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_est_2);
        //

        T2_RUN_1_KEY_1( 3, DSTIP, SIZE)
        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(DSTIP, ig_md.d_4_index3_16); 
            UM_RUN_END_3(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(4) 
        //

        T2_RUN_2_KEY_2( 5, SRCIP, DSTIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash);
        d_7_tcam_lpm_2.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16_1024, ig_md.d_7_base_16_2048, ig_md.d_7_threshold);
        d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16);
        update_7_1.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index1_16, ig_md.d_7_res_hash[1:1], 1, ig_md.d_7_est_1);
        d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16);
        update_7_2.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index2_16, ig_md.d_7_res_hash[2:2], 1, ig_md.d_7_est_2);
        d_7_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_7_index3_16);
        update_7_3.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index3_16, ig_md.d_7_res_hash[3:3], 1, ig_md.d_7_est_3);
        d_7_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_7_index4_16);
        update_7_4.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index4_16, ig_md.d_7_res_hash[4:4], 1, ig_md.d_7_est_4);
        d_7_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_7_index5_16);
        update_7_5.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index5_16, ig_md.d_7_res_hash[5:5], 1, ig_md.d_7_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(7)
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_8_1.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_8_est_2);
            d_9_above_threshold.apply(ig_md.d_8_est_1, ig_md.d_8_est_2, ig_md.d_9_above_threshold);
            update_8_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_8_est_4);
            update_8_5.apply(SRCIP, SRCPORT, SIZE, ig_md.d_8_est_5);
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_10_index1_16); 
            UM_RUN_END_1(10, ig_md.d_10_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(10) 
        //

        // UnivMon for inst 11
            d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_11_index4_16); 
            d_11_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_11_index5_16); 
            UM_RUN_END_5(11, ig_md.d_11_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(11) 
        //

        T1_RUN_1_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_4_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_14_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_2048, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(14)
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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