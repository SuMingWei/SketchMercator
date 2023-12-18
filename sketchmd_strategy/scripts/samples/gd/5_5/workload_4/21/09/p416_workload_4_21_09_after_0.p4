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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 131072, 14,  8)
    T2_INIT_HH_2( 2, 100, 4096)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
    // 

    UM_INIT_2( 5, 100, 11, 32768)
    T1_INIT_5( 6, 200, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_3;
    //

    UM_INIT_4( 9, 200, 10, 16384)
    T1_INIT_4(10, 110, 262144)
    T2_INIT_HH_4(11, 110, 8192)
    MRAC_INIT_1(12, 110, 8192, 10,  8)
    T4_INIT_1(13, 110, 16384)
    T2_INIT_HH_1(14, 110, 16384)
    T2_INIT_HH_1(15, 110, 8192)
    T2_INIT_HH_2(16, 220, 4096)
    UM_INIT_1(18, 220, 10, 16384)
    UM_INIT_3(17, 220, 10, 16384)
    T1_INIT_1(19, 221, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_21_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_21_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_21_2;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_21_3;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //

        T2_RUN_AFTER_2_KEY_1( 2, SRCIP, 1)

        // apply O2
        T2_RUN_AFTER_4_KEY_1(3, DSTIP, 1)
        // 

        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, ig_md.d_5_index2_16); 
            UM_RUN_END_2(5, ig_md.d_5_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(5) 
        //

        T1_RUN_5_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0 || ig_md.d_6_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash);
            update_7_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_7_res_hash[1:1], SIZE, ig_md.d_7_est_1);
            update_7_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_7_res_hash[2:2], SIZE, ig_md.d_7_est_2);
            d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_7_est_2, ig_md.d_8_above_threshold);
            update_7_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_7_est_3);
        //

        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16); 
            d_9_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_9_index3_16); 
            d_9_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_9_index4_16); 
            UM_RUN_END_4(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(9) 
        //

        T1_RUN_4_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_2(11, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16);
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16);
            update_12.apply(ig_md.d_12_base_16, ig_md.d_12_index1_16);
        //

        // HLL for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_32, ig_md.d_13_level);
            update_13.apply(DSTIP, DSTPORT, ig_md.d_13_level);
        //

        T2_RUN_AFTER_1_KEY_2(14, DSTIP, DSTPORT, SIZE)
        T2_RUN_AFTER_1_KEY_2(15, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_2_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_18_index1_16); 
            UM_RUN_END_1(18, ig_md.d_18_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(18) 
        //

        // UnivMon for inst 17
            d_17_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_index3_16); 
            UM_RUN_END_3(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(17) 
        //

        T1_RUN_1_KEY_5(19, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_21_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_21_est_1);
            update_21_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_21_est_2);
            update_21_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_21_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(21)
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
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