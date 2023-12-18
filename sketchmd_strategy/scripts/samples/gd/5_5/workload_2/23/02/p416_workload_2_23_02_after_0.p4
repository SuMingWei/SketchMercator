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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 20480)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_21_auto_sampling_hash_call;

    //

    T1_INIT_1( 2, 110, 524288)
    T1_INIT_1( 4, 110, 262144)

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_3_1;
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_3_2;
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_3_3;
    // 

    T1_INIT_4( 1, 110, 524288)
    T4_INIT_1( 5, 110, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_14_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_res_hash_call;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_1;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_2;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_14_3;
    //

    T2_INIT_HH_1(16, 110, 4096)
    T3_INIT_HH_2(13, 110, 16384)

    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_9_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_10_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
    // 

    T3_INIT_HH_4(12, 110, 4096)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(22, 110)
        ABOVE_THRESHOLD_4() d_22_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_22_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_22_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_22_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_22_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_22_index_hash_call_3;
        T3_T2_INDEX_UPDATE_16384() update_22_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_22_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_22_4;
    // 

    UM_INIT_2(23, 110, 11, 32768)
    UM_INIT_4(21, 110, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_22_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_23_sampling_hash_16);

            d_21_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_21_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 2, DSTIP, DSTPORT) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2( 4, DSTIP, DSTPORT) if (ig_md.d_4_est1_1 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_3_KEY_2(3, DSTIP, DSTPORT) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_4_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            update_5.apply(DSTIP, DSTPORT, ig_md.d_5_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash);
            update_14_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
            update_14_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_14_res_hash[2:2], ig_md.d_14_est_2);
            update_14_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_14_res_hash[3:3], ig_md.d_14_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(14)
        //

        T2_RUN_AFTER_1_KEY_2(16, DSTIP, DSTPORT, 1)
        T3_RUN_AFTER_2_KEY_2(13, DSTIP, DSTPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_3_KEY_2(9, DSTIP, DSTPORT, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_3_KEY_2(10, DSTIP, DSTPORT, SIZE)
        // 

        T3_RUN_AFTER_4_KEY_2(12, DSTIP, DSTPORT, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_2(7, DSTIP, DSTPORT, 1)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_22_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_22_res_hash);
        d_22_tcam_lpm_2.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16_1024, ig_md.d_22_base_16_2048, ig_md.d_22_threshold);
        d_22_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_22_index1_16);
        update_22_1.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index1_16, ig_md.d_22_res_hash[1:1], 1, ig_md.d_22_est_1);
        d_22_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_22_index2_16);
        update_22_2.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index2_16, ig_md.d_22_res_hash[2:2], 1, ig_md.d_22_est_2);
        d_22_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_22_index3_16);
        update_22_3.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index3_16, ig_md.d_22_res_hash[3:3], 1, ig_md.d_22_est_3);
        d_22_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_22_index4_16);
        update_22_4.apply(ig_md.d_22_base_16_1024, ig_md.d_22_index4_16, ig_md.d_22_res_hash[4:4], 1, ig_md.d_22_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(22)
        // 

        // UnivMon for inst 23
            d_23_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_23_res_hash); 
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_16, ig_md.d_23_threshold); 
            d_23_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_23_index1_16); 
            d_23_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_23_index2_16); 
            UM_RUN_END_2(23, ig_md.d_23_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(23) 
        //

        // UnivMon for inst 21
            d_21_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_21_res_hash); 
            d_21_tcam_lpm.apply(ig_md.d_21_sampling_hash_16, ig_md.d_21_base_16, ig_md.d_21_threshold); 
            d_21_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_21_index1_16); 
            d_21_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_21_index2_16); 
            d_21_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_21_index3_16); 
            d_21_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_21_index4_16); 
            UM_RUN_END_4(21, ig_md.d_21_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(21) 
        //

        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_21_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip, ig_md.hf_dstport); 
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