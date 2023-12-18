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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T1_INIT_3( 2, 200, 262144)
    T1_INIT_5( 1, 200, 262144)
    T1_INIT_5( 3, 200, 262144)
    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_4_tcam_lpm;
        T4_T4_KEY_UPDATE_200_32768(32w0x30243f0b) update_4_1;
    //

    T2_INIT_HH_2( 8, 200, 8192)

    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_9_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_9_above_threshold;
    // 

    T2_INIT_HH_4(11, 200, 8192)
    T2_INIT_HH_4(12, 200, 16384)

    // apply O2
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
    // 

    T2_INIT_HH_5(10, 200, 4096)
    UM_INIT_1(15, 200, 10, 16384)
    UM_INIT_5(14, 200, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_32);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_15_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_14_sampling_hash_16);

        //

        T1_RUN_3_KEY_2( 2, SRCIP, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4_1.apply(SRCIP, DSTIP, ig_md.d_4_level);
        //

        T2_RUN_AFTER_2_KEY_2( 8, SRCIP, DSTIP, SIZE)

        // apply O2
        T2_RUN_AFTER_4_KEY_2(9, SRCIP, DSTIP, SIZE)
        // 

        T2_RUN_AFTER_4_KEY_2(11, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_4_KEY_2(12, SRCIP, DSTIP, SIZE)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(6, SRCIP, DSTIP, 1)
        // 

        T2_RUN_AFTER_5_KEY_2(10, SRCIP, DSTIP, 1)
        // UnivMon for inst 15
            d_15_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_15_index1_16); 
            UM_RUN_END_1(15, ig_md.d_15_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(15) 
        //

        // UnivMon for inst 14
            d_14_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_14_index2_16); 
            d_14_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_14_index3_16); 
            d_14_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_14_index4_16); 
            d_14_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_14_index5_16); 
            UM_RUN_END_5(14, ig_md.d_14_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(14) 
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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