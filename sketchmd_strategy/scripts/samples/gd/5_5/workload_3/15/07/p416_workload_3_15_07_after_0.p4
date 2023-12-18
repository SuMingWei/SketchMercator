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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    T2_INIT_HH_1( 2, 100, 16384)
    MRAC_INIT_1( 3, 100, 8192, 10,  8)
    T2_INIT_HH_1( 4, 100, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(5, 100)
        ABOVE_THRESHOLD_1() d_5_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_5_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_5_1;
    // 

    T1_INIT_1( 7, 200, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_res_hash_call;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_1;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_2;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_3;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_4;
        T3_KEY_UPDATE_200_8192(32w0x30243f0b) update_9_5;
    //

    UM_INIT_5(10, 200, 10, 16384)
    T2_INIT_HH_1(11, 110, 4096)
    T2_INIT_HH_1(12, 110, 8192)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_13_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_13_above_threshold;
    // 

    T2_INIT_HH_4(14, 110, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_AFTER_1_KEY_1( 2, SRCIP, 1)
        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        T2_RUN_AFTER_1_KEY_1( 4, DSTIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash);
        d_5_tcam_lpm_2.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16_1024, ig_md.d_5_base_16_2048, ig_md.d_5_threshold);
        d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
        update_5_1.apply(ig_md.d_5_base_16_2048, ig_md.d_5_index1_16, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(5)
        // 

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash);
            update_9_1.apply(SRCIP, DSTIP, 1, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, 1, ig_md.d_9_res_hash[2:2], ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, 1, ig_md.d_9_res_hash[3:3], ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, DSTIP, 1, ig_md.d_9_res_hash[4:4], ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, DSTIP, 1, ig_md.d_9_res_hash[5:5], ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_10_index2_16); 
            d_10_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_10_index3_16); 
            d_10_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_10_index4_16); 
            d_10_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_10_index5_16); 
            UM_RUN_END_5(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(10) 
        //

        T2_RUN_AFTER_1_KEY_2(11, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_1_KEY_2(12, SRCIP, SRCPORT, 1)

        // apply O2
        T2_RUN_AFTER_2_KEY_2(13, DSTIP, DSTPORT, 1)
        // 

        T2_RUN_AFTER_4_KEY_2(14, DSTIP, DSTPORT, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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