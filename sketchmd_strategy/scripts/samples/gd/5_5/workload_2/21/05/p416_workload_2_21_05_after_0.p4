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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 221, 131072)
    T1_INIT_2( 2, 221, 131072)

    // apply O2
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_3_1;
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_3_2;
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_3_3;
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_3_4;
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_3_5;
    // 

    MRB_INIT_1( 5, 221, 524288, 15, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_10_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_14_above_threshold;
        T3_T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_10_1;
    //

    T2_INIT_HH_1(18, 221, 4096)

    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_7_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
    // 

    T3_INIT_HH_3(13, 221, 4096)

    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_6_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_6_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_9_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_9_above_threshold;
    // 

    T2_INIT_HH_4(17, 221, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(21, 221)
        ABOVE_THRESHOLD_5() d_21_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_21_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_21_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_21_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_21_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_21_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_21_3;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_21_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_21_4;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_21_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_21_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_5_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_sampling_hash_16);

        //

        T1_RUN_1_KEY_5( 1, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_5( 2, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_5_KEY_5(3, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        // 

        // MRB for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_32);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_32, ig_md.d_5_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_10_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_res_hash);
            update_10_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
            d_14_above_threshold.apply(ig_md.d_10_est_1, ig_md.d_14_above_threshold);
        //

        T2_RUN_AFTER_1_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)

        // apply O2
        T2_RUN_AFTER_3_KEY_5(7, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 

        T3_RUN_AFTER_3_KEY_5(13, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply O2
        T2_RUN_AFTER_4_KEY_5(6, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_5(8, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_5(9, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // 

        T2_RUN_AFTER_4_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_21_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_res_hash);
        d_21_tcam_lpm_2.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16_1024, ig_md.d_21_base_16_2048, ig_md.d_21_threshold);
        d_21_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index1_16);
        update_21_1.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index1_16, ig_md.d_21_res_hash[1:1], SIZE, ig_md.d_21_est_1);
        d_21_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index2_16);
        update_21_2.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index2_16, ig_md.d_21_res_hash[2:2], SIZE, ig_md.d_21_est_2);
        d_21_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index3_16);
        update_21_3.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index3_16, ig_md.d_21_res_hash[3:3], SIZE, ig_md.d_21_est_3);
        d_21_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index4_16);
        update_21_4.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index4_16, ig_md.d_21_res_hash[4:4], SIZE, ig_md.d_21_est_4);
        d_21_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_21_index5_16);
        update_21_5.apply(ig_md.d_21_base_16_2048, ig_md.d_21_index5_16, ig_md.d_21_res_hash[5:5], SIZE, ig_md.d_21_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(21)
        // 

        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
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