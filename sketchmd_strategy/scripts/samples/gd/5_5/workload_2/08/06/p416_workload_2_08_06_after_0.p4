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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 200, 131072)
    MRB_INIT_1( 2, 200, 131072, 14,  8)

    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(6, 200)
        ABOVE_THRESHOLD_3() d_6_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_6_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_6_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_6_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_6_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_6_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_6_3;
    // 

    UM_INIT_2( 7, 200, 10, 16384)
    UM_INIT_3( 8, 200, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_2_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_2(3, SRCIP, DSTIP, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash);
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048, ig_md.d_6_threshold);
        d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16);
        update_6_1.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index1_16, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_1);
        d_6_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_6_index2_16);
        update_6_2.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index2_16, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_2);
        d_6_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_6_index3_16);
        update_6_3.apply(ig_md.d_6_base_16_2048, ig_md.d_6_index3_16, ig_md.d_6_res_hash[3:3], 1, ig_md.d_6_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(6)
        // 

        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16); 
            UM_RUN_END_2(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(7) 
        //

        // UnivMon for inst 8
            d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_8_index3_16); 
            UM_RUN_END_3(8, ig_md.d_8_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(8) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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