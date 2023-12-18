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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 22528)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_4( 2, 220, 524288)
    T1_INIT_5( 1, 220, 524288)
    T2_INIT_HH_2(14, 220, 4096)
    T2_INIT_HH_2(15, 220, 4096)

    // apply O2
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_5_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_5_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_7_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_7_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_3_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_4_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_4_2;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_4_3;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_4_4;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_4_5;
    //

    T2_INIT_HH_5(13, 220, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(21, 220)
        ABOVE_THRESHOLD_2() d_21_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_21_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_21_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_21_2;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 220)
        ABOVE_THRESHOLD_2() d_20_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_20_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_20_2;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_16);

        //

        T1_RUN_4_KEY_4( 2, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_4( 1, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_AFTER_2_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_4_KEY_4(5, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_4(7, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_4(3, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_4_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_4_est_4);
            update_4_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_4_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(4)
        //

        T2_RUN_AFTER_5_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], SIZE, ig_md.d_21_est_1);
        d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_21_index2_16);
        update_21_2.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index2_16, ig_md.d_21_res_hash[2:2], SIZE, ig_md.d_21_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(21)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], 1, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], 1, ig_md.d_20_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(20)
        // 

        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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