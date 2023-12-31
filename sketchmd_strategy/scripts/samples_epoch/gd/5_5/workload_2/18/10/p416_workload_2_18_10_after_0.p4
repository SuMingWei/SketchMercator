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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(65536, 16, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 110, 131072)
    T1_INIT_5( 2, 110, 131072)
    T1_INIT_1( 3, 110, 131072)
    T1_INIT_1( 4, 110, 262144)
    MRB_INIT_1( 5, 110, 131072, 14,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_6_tcam_lpm;
        GET_BITMASK() d_6_get_bitmask;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_11_above_threshold;
        T3_T5_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_1;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_16_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_16_5;
    //


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_9_above_threshold;
    // 

    T2_INIT_HH_4(14, 110, 4096)
    T2_INIT_HH_3(15, 110, 4096)
    T3_INIT_HH_4(10, 110, 4096)
    T2_INIT_HH_4(12, 110, 4096)
    UM_INIT_5(18, 110, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_32);

            d_18_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_sampling_hash_16);

        //

        T1_RUN_2_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 3, SRCIP, SRCPORT) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 4, SRCIP, SRCPORT) if (ig_md.d_4_est1_1 == 0) { /* process_new_flow() */ }
        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_5_index1_16);
            update_5_1.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_6_level);
            d_6_get_bitmask.apply(ig_md.d_6_level, ig_md.d_6_bitmask);
            d_6_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_res_hash);
            update_6_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_6_res_hash[0:0], ig_md.d_6_bitmask, ig_md.d_6_est_1);
            d_11_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_11_above_threshold);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_16_1.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_16_est_1);
            update_16_2.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_16_est_2);
            update_16_3.apply(SRCIP, SRCPORT, SIZE, 1, ig_md.d_16_est_3);
            update_16_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_16_est_4);
            update_16_5.apply(SRCIP, SRCPORT, SIZE, ig_md.d_16_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(16)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(8, SRCIP, SRCPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_1_KEY_2(9, SRCIP, SRCPORT, SIZE)
        // 

        T2_RUN_AFTER_4_KEY_2(14, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_3_KEY_2(15, SRCIP, SRCPORT, SIZE)
        T3_RUN_AFTER_4_KEY_2(10, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_4_KEY_2(12, SRCIP, SRCPORT, 1)
        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_18_index3_16); 
            d_18_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_18_index4_16); 
            d_18_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_18_index5_16); 
            UM_RUN_END_5(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(18) 
        //

        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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