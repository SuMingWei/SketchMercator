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
    METADATA_DIM(21)
    METADATA_DIM(22)
    METADATA_DIM(23)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    MRB_INIT_1( 1, 100, 524288, 15, 16)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
    //

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(4, 100)
        ABOVE_THRESHOLD_1() d_4_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_4_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_4_1;
    // 


    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_7_3;
    //
    UM_INIT_2( 8, 100, 11, 32768)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_10_4;
    //
    UM_INIT_4(11, 200, 10, 16384)
    T1_INIT_1(12, 110, 262144)
    T2_INIT_HH_3(14, 110, 4096)
    T2_INIT_HH_5(13, 110, 16384)
    UM_INIT_2(15, 110, 11, 32768)
    T1_INIT_1(16, 110, 262144)
    T4_INIT_1(17, 110, 32768)
    T2_INIT_4(18, 110, 8192)
    UM_INIT_4(19, 110, 11, 32768)
    T1_INIT_1(20, 221, 524288)
    T2_INIT_HH_5(21, 221, 16384)

    // apply O3; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(22, 221)
        ABOVE_THRESHOLD_1() d_22_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_22_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_22_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        MRB_RUN_1_KEY_1( 1, SRCIP)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
            update_2_1.apply(SRCIP, 1, ig_md.d_2_res_hash[1:1], 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_res_hash[2:2], 1, ig_md.d_2_est_2);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_3_above_threshold);
        //

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_4_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);
        d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash);
        d_4_tcam_lpm_2.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16_1024, ig_md.d_4_base_16_2048, ig_md.d_4_threshold);
        d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
        update_4_1.apply(ig_md.d_4_base_16_1024, ig_md.d_4_index1_16, ig_md.d_4_res_hash[1:1], 1, ig_md.d_4_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(4)
        // 


        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_7_1.apply(DSTIP, 1, 1, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, 1, ig_md.d_7_est_3);
        //
        UM_RUN_AFTER_2_KEY_1( 8, DSTIP, 1)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_10_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_1);
            update_10_2.apply(SRCIP, DSTIP, 1, 1, ig_md.d_10_est_2);
            update_10_3.apply(SRCIP, DSTIP, 1, ig_md.d_10_est_3);
            update_10_4.apply(SRCIP, DSTIP, 1, ig_md.d_10_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(10)
        //
        UM_RUN_AFTER_4_KEY_2(11, SRCIP, DSTIP, 1)
        T1_RUN_1_KEY_2(12, SRCIP, SRCPORT)
        T2_RUN_AFTER_3_KEY_2(14, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_5_KEY_2(13, SRCIP, SRCPORT, 1)
        UM_RUN_AFTER_2_KEY_2(15, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(16, DSTIP, DSTPORT) if (ig_md.d_16_est1_1 == 0) { /* process_new_flow() */ }
        T4_RUN_1_KEY_2(17, DSTIP, DSTPORT)
        T2_RUN_4_KEY_2(18, DSTIP, DSTPORT, 1)
        UM_RUN_AFTER_4_KEY_2(19, DSTIP, DSTPORT, 1)
        T1_RUN_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_AFTER_5_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply O3; big - MRAC (1 row) / small - UnivMon (1 row)
        d_22_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);
        d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_res_hash);
        d_22_tcam_lpm_2.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16_1024, ig_md.d_22_base_16_2048, ig_md.d_22_threshold);
        d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16);
        update_22_1.apply(ig_md.d_22_base_16_2048, ig_md.d_22_index1_16, ig_md.d_22_res_hash[1:1], 1, ig_md.d_22_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(22)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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