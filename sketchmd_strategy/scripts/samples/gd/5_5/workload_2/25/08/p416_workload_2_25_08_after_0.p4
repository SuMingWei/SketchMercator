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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //

    T1_INIT_4( 2, 220, 524288)
    T1_INIT_5( 1, 220, 262144)
    MRB_INIT_1( 3, 220, 131072, 14,  8)
    T2_INIT_HH_1(16, 220, 4096)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_8_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_7_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_4_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_4_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_5_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_5_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_5_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_6_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_9_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_10_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_8(32w0x30244f0b) d_21_sampling_hash_call;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_21_index_hash_call_1;
        LPM_OPT_MRAC_2() d_21_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_8192() update_21;
    // 

    MRAC_INIT_1(22, 220, 16384, 11,  8)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(24, 220)
        ABOVE_THRESHOLD_1() d_24_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_24_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_24_1;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_3_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_sampling_hash_16);

        //

        T1_RUN_4_KEY_4( 2, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4( 1, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        T2_RUN_AFTER_1_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_2_KEY_4(8, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_3_KEY_4(7, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_4(4, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_4(5, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_4(6, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_4(9, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_4(10, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_21_tcam_lpm_2.apply(ig_md.d_3_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16);
        update_21.apply(ig_md.d_21_base_16_1024, ig_md.d_21_index1_16);
        // 

        // MRAC for inst 22
            d_22_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_22_base_16);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_16, ig_md.d_22_index1_16);
        //


        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_res_hash);
        d_24_tcam_lpm_2.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16_1024, ig_md.d_24_base_16_2048, ig_md.d_24_threshold);
        d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_24_index1_16);
        update_24_1.apply(ig_md.d_24_base_16_2048, ig_md.d_24_index1_16, ig_md.d_24_res_hash[1:1], 1, ig_md.d_24_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(24)
        // 

        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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