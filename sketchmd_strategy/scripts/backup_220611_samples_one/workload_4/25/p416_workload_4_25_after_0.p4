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
    METADATA_DIM(24)
    METADATA_DIM(25)
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
    T4_INIT_1( 1, 100, 32768)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_res_hash_call;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_5;
    //
    MRAC_INIT_1( 4, 100, 8192, 10,  8)
    T1_INIT_2( 5, 100, 524288)
    T3_INIT_HH_2( 6, 100, 8192)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 100)
        ABOVE_THRESHOLD_4() d_8_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_8_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_8_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_8_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_8_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_8_4;
    // 

    T1_INIT_1( 9, 200, 524288)
    T4_INIT_1(10, 200, 65536)

    // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_12_above_threshold;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_1;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_2;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_5;
    //

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_13_1;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_2;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_3;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_4;
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_5;
    // 

    T2_INIT_HH_3(15, 110, 4096)
    MRAC_INIT_1(16, 110, 8192, 10,  8)
    T5_INIT_1(17, 110, 4096)
    T2_INIT_HH_2(20, 220, 4096)

    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_18_above_threshold;
    // 

    MRAC_INIT_1(21, 220, 16384, 10, 16)
    T1_INIT_2(22, 221, 131072)
    MRB_INIT_1(23, 221, 262144, 14, 16)
    T2_INIT_HH_4(24, 221, 8192)
    T3_INIT_HH_4(25, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T4_RUN_1_KEY_1( 1, SRCIP)

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash);
            update_3_1.apply(SRCIP, 1, ig_md.d_3_res_hash[1:1], 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, ig_md.d_3_res_hash[2:2], 1, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, 1, ig_md.d_3_res_hash[3:3], 1, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, 1, ig_md.d_3_res_hash[4:4], ig_md.d_3_est_4);
            update_3_5.apply(SRCIP, 1, ig_md.d_3_res_hash[5:5], ig_md.d_3_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(3)
        //
        MRAC_RUN_1_KEY_1( 4, SRCIP)
        T1_RUN_2_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_2_KEY_1( 6, DSTIP, SIZE)

        // apply O3; big - UnivMon / small - many MRACs 
        d_8_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);
        d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(DSTIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(DSTIP, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        d_8_index_hash_call_4.apply(DSTIP, ig_md.d_8_index4_16);
        update_8_4.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index4_16, ig_md.d_8_res_hash[4:4], 1, ig_md.d_8_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(8)
        // 

        T1_RUN_1_KEY_2( 9, SRCIP, DSTIP) if (ig_md.d_9_est1_1 == 0) { /* process_new_flow() */ }
        T4_RUN_1_KEY_2(10, SRCIP, DSTIP)

        // apply O3; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_11_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_res_hash);
            update_11_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_res_hash[1:1], SIZE, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_res_hash[2:2], SIZE, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_res_hash[3:3], SIZE, ig_md.d_11_est_3);
            d_12_above_threshold.apply(ig_md.d_11_est_1, ig_md.d_11_est_2, ig_md.d_11_est_3, ig_md.d_12_above_threshold);
            update_11_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_est_5);
        //

        // apply O2
        T1_RUN_5_KEY_2(13, SRCIP, SRCPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0 || ig_md.d_13_est1_4 == 0 || ig_md.d_13_est1_5 == 0) { /* process_new_flow() */ }
        // 

        T2_RUN_AFTER_3_KEY_2(15, SRCIP, SRCPORT, 1)
        MRAC_RUN_1_KEY_2(16, SRCIP, SRCPORT)
        T5_RUN_1_KEY_2(17, DSTIP, DSTPORT)
        T2_RUN_AFTER_2_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 

        MRAC_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T1_RUN_2_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_22_est1_1 == 0 || ig_md.d_22_est1_2 == 0) { /* process_new_flow() */ }
        MRB_RUN_1_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        T2_RUN_AFTER_4_KEY_5(24, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T3_RUN_AFTER_4_KEY_5(25, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
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