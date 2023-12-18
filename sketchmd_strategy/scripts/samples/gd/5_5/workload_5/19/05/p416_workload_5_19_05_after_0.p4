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

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_3_hash_call;
        TCAM_LPM_HLLPCSA() d_3_tcam_lpm;
        GET_BITMASK() d_3_get_bitmask;
        T2_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_4;
    //

    T1_INIT_1( 5, 100, 524288)
    MRAC_INIT_1( 6, 100, 32768, 11, 16)
    T1_INIT_1( 7, 200, 262144)
    T3_INIT_HH_1( 9, 110, 8192)
    T2_INIT_HH_2(10, 110, 4096)
    T3_INIT_HH_4( 8, 110, 8192)
    T1_INIT_1(11, 110, 524288)
    T1_INIT_2(12, 110, 524288)
    T3_INIT_HH_4(13, 110, 8192)
    UM_INIT_5(14, 110, 10, 16384)
    T2_INIT_HH_1(15, 220, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_sampling_hash_call;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        LPM_OPT_MRAC_2() d_16_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_16;
    // 

    T1_INIT_2(18, 221, 262144)
    UM_INIT_5(19, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_16);

        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_3_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_3_level);
            d_3_get_bitmask.apply(ig_md.d_3_level, ig_md.d_3_bitmask);
            update_3_1.apply(SRCIP, SIZE, ig_md.d_3_bitmask, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, SIZE, ig_md.d_3_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(3)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_4_1.apply(SRCIP, SIZE, 1, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, SIZE, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, SIZE, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, SIZE, ig_md.d_4_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(4)
        //

        T1_RUN_1_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0) { /* process_new_flow() */ }
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP)
        T3_RUN_AFTER_1_KEY_2( 9, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_2_KEY_2(10, SRCIP, SRCPORT, 1)
        T3_RUN_AFTER_4_KEY_2( 8, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2(12, DSTIP, DSTPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_2(13, DSTIP, DSTPORT, 1)
        // UnivMon for inst 14
            d_14_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_res_hash); 
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16, ig_md.d_14_threshold); 
            d_14_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_14_index1_16); 
            d_14_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_14_index2_16); 
            d_14_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_14_index3_16); 
            d_14_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_14_index4_16); 
            d_14_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_14_index5_16); 
            UM_RUN_END_5(14, ig_md.d_14_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(14) 
        //

        T2_RUN_AFTER_1_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048);
        d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
        update_16.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16);
        // 

        T1_RUN_2_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_18_est1_1 == 0 || ig_md.d_18_est1_2 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 19
            d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index3_16); 
            d_19_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index4_16); 
            d_19_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index5_16); 
            UM_RUN_END_5(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(19) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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