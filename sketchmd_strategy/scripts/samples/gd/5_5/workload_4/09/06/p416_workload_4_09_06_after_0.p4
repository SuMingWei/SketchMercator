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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(2, 100)
        ABOVE_THRESHOLD_5() d_2_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_2_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_2_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_2_3;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_2_4;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_2_5;
    // 

    T1_INIT_4( 3, 100, 524288)
    T2_INIT_HH_2( 4, 110, 16384)
    UM_INIT_1( 5, 110, 11, 32768)
    T2_INIT_4( 6, 110, 4096)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 

    T2_INIT_HH_5( 8, 220, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_sampling_hash_16);

        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
        d_2_tcam_lpm_2.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16_1024, ig_md.d_2_base_16_2048, ig_md.d_2_threshold);
        d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
        update_2_1.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index1_16, ig_md.d_2_res_hash[1:1], SIZE, ig_md.d_2_est_1);
        d_2_index_hash_call_2.apply(SRCIP, ig_md.d_2_index2_16);
        update_2_2.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index2_16, ig_md.d_2_res_hash[2:2], SIZE, ig_md.d_2_est_2);
        d_2_index_hash_call_3.apply(SRCIP, ig_md.d_2_index3_16);
        update_2_3.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index3_16, ig_md.d_2_res_hash[3:3], SIZE, ig_md.d_2_est_3);
        d_2_index_hash_call_4.apply(SRCIP, ig_md.d_2_index4_16);
        update_2_4.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index4_16, ig_md.d_2_res_hash[4:4], SIZE, ig_md.d_2_est_4);
        d_2_index_hash_call_5.apply(SRCIP, ig_md.d_2_index5_16);
        update_2_5.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index5_16, ig_md.d_2_res_hash[5:5], SIZE, ig_md.d_2_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(2)
        // 

        T1_RUN_4_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2( 4, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 5
            d_5_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_5_index1_16); 
            UM_RUN_END_1(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(5) 
        //

        T2_RUN_4_KEY_2( 6, DSTIP, DSTPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_4(7, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 

        T2_RUN_AFTER_5_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
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