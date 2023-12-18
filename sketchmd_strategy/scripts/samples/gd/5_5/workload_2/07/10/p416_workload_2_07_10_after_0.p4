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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(8192, 13, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 220, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_2_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_2_3;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_2_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(6, 220)
        ABOVE_THRESHOLD_5() d_6_above_threshold;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_6_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_6_1;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_6_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_6_2;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_6_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_6_3;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_6_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_6_4;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_6_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_6_5;
    // 

    UM_INIT_1( 7, 220, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_sampling_hash_16);

        //

        T1_RUN_2_KEY_4( 1, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_2_est_4);
            d_4_above_threshold.apply(ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_2_est_4, ig_md.d_4_above_threshold);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_6_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_res_hash);
        d_6_tcam_lpm_2.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16_1024, ig_md.d_6_base_16_2048, ig_md.d_6_threshold);
        d_6_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index1_16);
        update_6_1.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index1_16, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_1);
        d_6_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index2_16);
        update_6_2.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index2_16, ig_md.d_6_res_hash[2:2], 1, ig_md.d_6_est_2);
        d_6_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index3_16);
        update_6_3.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index3_16, ig_md.d_6_res_hash[3:3], 1, ig_md.d_6_est_3);
        d_6_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index4_16);
        update_6_4.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index4_16, ig_md.d_6_res_hash[4:4], 1, ig_md.d_6_est_4);
        d_6_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_index5_16);
        update_6_5.apply(ig_md.d_6_base_16_1024, ig_md.d_6_index5_16, ig_md.d_6_res_hash[5:5], 1, ig_md.d_6_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(6)
        // 

        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_7_index1_16); 
            UM_RUN_END_1(7, ig_md.d_7_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(7) 
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
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