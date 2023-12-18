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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 131072)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(2, 100)
        ABOVE_THRESHOLD_1() d_2_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_2_1;
    // 

    T1_INIT_5( 4, 100, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_7_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_7_hash_call;
        TCAM_LPM_HLLPCSA() d_7_tcam_lpm;
        GET_BITMASK() d_7_get_bitmask;
        T2_T5_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_2;
    //


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_8_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
    // 

    MRAC_INIT_1(10, 200, 16384, 10, 16)
    T2_INIT_HH_2(13, 110, 16384)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_11_above_threshold;
    // 

    T1_INIT_4(14, 110, 262144)
    T2_INIT_HH_2(15, 110, 8192)
    T1_INIT_1(16, 220, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_18_tcam_lpm;
        GET_BITMASK() d_18_get_bitmask;
        T5_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_19_above_threshold;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_18_4;
    //

    T2_INIT_HH_1(20, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_32);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_17_sampling_hash_32);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
        d_2_tcam_lpm_2.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16_1024, ig_md.d_2_base_16_2048, ig_md.d_2_threshold);
        d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
        update_2_1.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index1_16, ig_md.d_2_res_hash[1:1], SIZE, ig_md.d_2_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(2)
        // 

        T1_RUN_5_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_7_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_7_level);
            d_7_get_bitmask.apply(ig_md.d_7_level, ig_md.d_7_bitmask);
            update_7_1.apply(DSTIP, SIZE, ig_md.d_7_bitmask, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, SIZE, 1, ig_md.d_7_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(7)
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_2(8, SRCIP, DSTIP, SIZE)
        // 

        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T2_RUN_AFTER_2_KEY_2(13, SRCIP, SRCPORT, SIZE)

        // apply O2
        T2_RUN_AFTER_3_KEY_2(11, SRCIP, SRCPORT, 1)
        // 

        T1_RUN_4_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2(15, DSTIP, DSTPORT, 1)
        T1_RUN_1_KEY_4(16, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_16_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_18_tcam_lpm.apply(ig_md.d_17_sampling_hash_32, ig_md.d_18_level);
            d_18_get_bitmask.apply(ig_md.d_18_level, ig_md.d_18_bitmask);
            update_18_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_18_bitmask, ig_md.d_18_est_1);
            update_18_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_18_est_2);
            d_19_above_threshold.apply(ig_md.d_18_est_2, ig_md.d_19_above_threshold);
            update_18_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_3);
            update_18_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_18_est_4);
        //

        T2_RUN_AFTER_1_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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