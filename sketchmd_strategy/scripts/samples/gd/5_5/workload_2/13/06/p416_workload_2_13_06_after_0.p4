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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(8192, 13, 4096)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

    //

    T1_INIT_1( 4, 200, 262144)
    T1_INIT_3( 1, 200, 524288)
    T1_INIT_3( 3, 200, 524288)
    T1_INIT_5( 2, 200, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_3;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_7_5;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_res_hash_call;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_2;
        T3_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_3;
    //

    MRAC_INIT_1(11, 200, 16384, 11,  8)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_sampling_hash_call;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_1;
        LPM_OPT_MRAC_2() d_12_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_12;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 4, SRCIP, DSTIP)
        T1_RUN_3_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 2, SRCIP, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_7_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_7_est_1);
            update_7_2.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_7_est_2);
            update_7_3.apply(SRCIP, DSTIP, SIZE, SIZE, ig_md.d_7_est_3);
            update_7_4.apply(SRCIP, DSTIP, SIZE, SIZE, ig_md.d_7_est_4);
            update_7_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_7_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(7)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_10_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_res_hash);
            update_10_1.apply(SRCIP, DSTIP, 1, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, 1, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, 1, ig_md.d_10_res_hash[3:3], ig_md.d_10_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(10)
        //

        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_12_tcam_lpm_2.apply(ig_md.d_11_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048);
        d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
        update_12.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index1_16);
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
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