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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_1( 2, 100, 262144)
    T1_INIT_1( 3, 100, 524288)

    // apply O2
        T1_KEY_UPDATE_100_262144(32w0x30243f0b) update_4_1;
    // 

    T1_INIT_3( 1, 100, 524288)
    MRB_INIT_1( 6, 100, 262144, 14, 16)
    MRB_INIT_1( 7, 100, 262144, 15,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_16_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_16_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_16_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_16_3;
    //


    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_10_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_14_above_threshold;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_10_1;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_10_2;
        T3_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_10_3;
    //

    T3_INIT_HH_3(12, 100, 16384)
    T3_INIT_HH_4(13, 100, 16384)

    // apply O2
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_11_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(20, 100)
        ABOVE_THRESHOLD_4() d_20_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_20_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_20_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_20_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_20_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_20_3;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_20_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_20_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(DSTIP, ig_md.d_20_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_1_KEY_1(4, DSTIP) if (ig_md.d_4_est1_1 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_3_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // MRB for inst 7
            d_7_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_7_base_32);
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_32, ig_md.d_7_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_16_1.apply(DSTIP, SIZE, 1, ig_md.d_16_est_1);
            update_16_2.apply(DSTIP, SIZE, ig_md.d_16_est_2);
            update_16_3.apply(DSTIP, SIZE, ig_md.d_16_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(16)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_1(8, DSTIP, 1)
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_10_res_hash_call.apply(DSTIP, ig_md.d_10_res_hash);
            update_10_1.apply(DSTIP, SIZE, ig_md.d_10_res_hash[1:1], SIZE, ig_md.d_10_est_1);
            update_10_2.apply(DSTIP, SIZE, ig_md.d_10_res_hash[2:2], SIZE, ig_md.d_10_est_2);
            update_10_3.apply(DSTIP, SIZE, ig_md.d_10_res_hash[3:3], SIZE, ig_md.d_10_est_3);
            d_14_above_threshold.apply(ig_md.d_10_est_1, ig_md.d_10_est_2, ig_md.d_10_est_3, ig_md.d_14_above_threshold);
        //

        T3_RUN_AFTER_3_KEY_1(12, DSTIP, 1)
        T3_RUN_AFTER_4_KEY_1(13, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_1(11, DSTIP, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_20_res_hash_call.apply(DSTIP, ig_md.d_20_res_hash);
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048, ig_md.d_20_threshold);
        d_20_index_hash_call_1.apply(DSTIP, ig_md.d_20_index1_16);
        update_20_1.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16, ig_md.d_20_res_hash[1:1], SIZE, ig_md.d_20_est_1);
        d_20_index_hash_call_2.apply(DSTIP, ig_md.d_20_index2_16);
        update_20_2.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index2_16, ig_md.d_20_res_hash[2:2], SIZE, ig_md.d_20_est_2);
        d_20_index_hash_call_3.apply(DSTIP, ig_md.d_20_index3_16);
        update_20_3.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index3_16, ig_md.d_20_res_hash[3:3], SIZE, ig_md.d_20_est_3);
        d_20_index_hash_call_4.apply(DSTIP, ig_md.d_20_index4_16);
        update_20_4.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index4_16, ig_md.d_20_res_hash[4:4], SIZE, ig_md.d_20_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(20)
        // 

        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip); 
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