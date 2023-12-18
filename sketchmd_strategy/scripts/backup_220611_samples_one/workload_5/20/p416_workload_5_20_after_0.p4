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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_2_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
    //
    T1_INIT_5( 3, 100, 262144)
    T2_INIT_2( 4, 100, 16384)
    UM_INIT_2( 5, 100, 11, 32768)
    T2_INIT_HH_5( 6, 200, 16384)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 200)
        ABOVE_THRESHOLD_3() d_8_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_8_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_8_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_8_3;
    // 

    T3_INIT_HH_1( 9, 110, 4096)
    T2_INIT_4(10, 110, 8192)
    UM_INIT_4(11, 110, 10, 16384)
    T1_INIT_5(12, 220, 262144)
    MRB_INIT_1(13, 220, 131072, 14,  8)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_17_above_threshold;
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_17_res_hash_call;
        T3_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_17_1;
        T3_KEY_UPDATE_220_4096(32w0x30243f0b) update_17_2;
        T3_KEY_UPDATE_220_4096(32w0x30243f0b) update_17_3;
    //

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_16_above_threshold;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_1;
        T3_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_14_2;
    //
    T1_INIT_1(18, 221, 262144)
    T2_INIT_HH_2(19, 221, 8192)
    MRAC_INIT_1(20, 221, 8192, 10,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_1_1.apply(SRCIP, SIZE, SIZE, ig_md.d_1_est_1);
            d_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_2_above_threshold);
            update_1_2.apply(SRCIP, SIZE, ig_md.d_1_est_2);
        //
        T1_RUN_5_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_2_KEY_1( 4, DSTIP, 1)
        UM_RUN_AFTER_2_KEY_1( 5, DSTIP, SIZE)
        T2_RUN_AFTER_5_KEY_2( 6, SRCIP, DSTIP, 1)

        // apply O3; big - UnivMon / small - many MRACs 
        d_8_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);
        d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(8)
        // 

        T3_RUN_AFTER_1_KEY_2( 9, SRCIP, SRCPORT, SIZE)
        T2_RUN_4_KEY_2(10, DSTIP, DSTPORT, SIZE)
        UM_RUN_AFTER_4_KEY_2(11, DSTIP, DSTPORT, 1)
        T1_RUN_5_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0 || ig_md.d_12_est1_3 == 0 || ig_md.d_12_est1_4 == 0 || ig_md.d_12_est1_5 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_17_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_res_hash);
            update_17_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_17_res_hash[1:1], 1, ig_md.d_17_est_1);
            update_17_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_17_res_hash[2:2], ig_md.d_17_est_2);
            update_17_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_17_res_hash[3:3], ig_md.d_17_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(17)
        //

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_14_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_res_hash);
            update_14_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_res_hash[1:1], 1, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_14_res_hash[2:2], 1, ig_md.d_14_est_2);
            d_16_above_threshold.apply(ig_md.d_14_est_1, ig_md.d_14_est_2, ig_md.d_16_above_threshold);
        //
        T1_RUN_1_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_AFTER_2_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        MRAC_RUN_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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