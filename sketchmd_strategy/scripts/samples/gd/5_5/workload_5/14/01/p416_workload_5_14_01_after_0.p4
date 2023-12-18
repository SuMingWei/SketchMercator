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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 131072)
    MRAC_INIT_1( 2, 100, 16384, 11,  8)
    T1_INIT_1( 3, 200, 262144)
    T4_INIT_1( 4, 200, 65536)
    T4_INIT_1( 5, 110, 32768)
    T3_INIT_HH_3( 6, 110, 4096)
    MRAC_INIT_1( 7, 110, 8192, 10,  8)
    MRB_INIT_1( 8, 110, 131072, 14,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_res_hash_call;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_10_2;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_3;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_4;
        T3_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 220)
        ABOVE_THRESHOLD_5() d_13_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_13_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_13_2;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_13_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_13_3;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_13_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_13_4;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_13_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_13_5;
    // 

    T2_INIT_HH_1(14, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_8_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // MRAC for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16);
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_16, ig_md.d_2_index1_16);
        //

        T1_RUN_1_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(SRCIP, DSTIP, ig_md.d_4_level);
        //

        // HLL for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            update_5.apply(SRCIP, SRCPORT, ig_md.d_5_level);
        //

        T3_RUN_AFTER_3_KEY_2( 6, SRCIP, SRCPORT, 1)
        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // MRB for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_32);
            d_8_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_32, ig_md.d_8_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_res_hash);
            update_10_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
            update_10_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
            update_10_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_10_res_hash[3:3], ig_md.d_10_est_3);
            update_10_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_10_res_hash[4:4], ig_md.d_10_est_4);
            update_10_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_10_res_hash[5:5], ig_md.d_10_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(10)
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], SIZE, ig_md.d_13_est_2);
        d_13_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index3_16);
        update_13_3.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index3_16, ig_md.d_13_res_hash[3:3], SIZE, ig_md.d_13_est_3);
        d_13_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index4_16);
        update_13_4.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index4_16, ig_md.d_13_res_hash[4:4], SIZE, ig_md.d_13_est_4);
        d_13_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index5_16);
        update_13_5.apply(ig_md.d_13_base_16_1024, ig_md.d_13_index5_16, ig_md.d_13_res_hash[5:5], SIZE, ig_md.d_13_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(13)
        // 

        T2_RUN_AFTER_1_KEY_5(14, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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
        ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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