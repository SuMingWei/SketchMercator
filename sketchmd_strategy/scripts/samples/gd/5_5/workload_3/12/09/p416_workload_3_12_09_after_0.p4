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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_210(16384, 14, 10240)

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

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 131072)
    T2_INIT_HH_4( 2, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(4, 100)
        ABOVE_THRESHOLD_5() d_4_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_4_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_4_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_4_3;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_4_4;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_4_5;
    // 

    T1_INIT_1( 5, 200, 262144)
    T2_INIT_HH_5( 6, 200, 8192)
    UM_INIT_5( 7, 200, 11, 32768)
    MRB_INIT_1( 8, 110, 262144, 15,  8)
    T3_INIT_HH_3( 9, 110, 4096)
    T2_INIT_3(10, 110, 4096)
    MRAC_INIT_1(11, 220, 8192, 10,  8)
    MRAC_INIT_1(12, 221, 8192, 10,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_1( 2, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash);
        d_4_tcam_lpm_2.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16_1024, ig_md.d_4_base_16_2048, ig_md.d_4_threshold);
        d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
        update_4_1.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index1_16, ig_md.d_4_res_hash[1:1], 1, ig_md.d_4_est_1);
        d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16);
        update_4_2.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index2_16, ig_md.d_4_res_hash[2:2], 1, ig_md.d_4_est_2);
        d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16);
        update_4_3.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index3_16, ig_md.d_4_res_hash[3:3], 1, ig_md.d_4_est_3);
        d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16);
        update_4_4.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index4_16, ig_md.d_4_res_hash[4:4], 1, ig_md.d_4_est_4);
        d_4_index_hash_call_5.apply(SRCIP, ig_md.d_4_index5_16);
        update_4_5.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index5_16, ig_md.d_4_res_hash[5:5], 1, ig_md.d_4_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(4)
        // 

        T1_RUN_1_KEY_2( 5, SRCIP, DSTIP) if (ig_md.d_5_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2( 6, SRCIP, DSTIP, 1)
        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_7_index4_16); 
            d_7_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_7_index5_16); 
            UM_RUN_END_5(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(7) 
        //

        // MRB for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_32);
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_32, ig_md.d_8_index1_16);
        //

        T3_RUN_AFTER_3_KEY_2( 9, SRCIP, SRCPORT, 1)
        T2_RUN_3_KEY_2(10, DSTIP, DSTPORT, 1)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport); 
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