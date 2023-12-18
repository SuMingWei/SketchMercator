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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 16384)
    T2_INIT_HH_1( 2, 100, 16384)
    T2_INIT_HH_4( 3, 100, 4096)
    MRAC_INIT_1( 4, 100, 32768, 11, 16)
    T1_INIT_4( 5, 100, 524288)
    MRB_INIT_1( 6, 100, 131072, 14,  8)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_7_3;
    //


    // apply O2
        T1_KEY_UPDATE_200_524288(32w0x30243f0b) update_11_1;
        T1_KEY_UPDATE_200_131072(32w0x30243f0b) update_11_2;
        T1_KEY_UPDATE_200_131072(32w0x30243f0b) update_11_3;
        T1_KEY_UPDATE_200_131072(32w0x30243f0b) update_11_4;
        T1_KEY_UPDATE_200_131072(32w0x30243f0b) update_11_5;
    // 

    T1_INIT_3(13, 110, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_15_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_15_hash_call;
        TCAM_LPM_HLLPCSA() d_15_tcam_lpm;
        GET_BITMASK() d_15_get_bitmask;
        T2_T5_KEY_UPDATE_110_8192(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_15_2;
    //

    T1_INIT_1(16, 110, 524288)
    T2_INIT_HH_3(18, 110, 16384)
    T3_INIT_HH_5(17, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_20_above_threshold;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_1;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_2;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_19_4;
    //

    T1_INIT_3(21, 221, 131072)
    T2_INIT_3(22, 221, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_32);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //

        T2_RUN_AFTER_1_KEY_1( 2, SRCIP, 1)
        T2_RUN_AFTER_4_KEY_1( 3, SRCIP, SIZE)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        T1_RUN_4_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0 || ig_md.d_5_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_32);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_32, ig_md.d_6_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_7_1.apply(DSTIP, 1, SIZE, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, 1, ig_md.d_7_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(7)
        //


        // apply O2
        T1_RUN_5_KEY_2(11, SRCIP, DSTIP) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0 || ig_md.d_11_est1_5 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_3_KEY_2(13, SRCIP, SRCPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_15_tcam_lpm.apply(ig_md.d_14_sampling_hash_32, ig_md.d_15_level);
            d_15_get_bitmask.apply(ig_md.d_15_level, ig_md.d_15_bitmask);
            update_15_1.apply(SRCIP, SRCPORT, 1, ig_md.d_15_bitmask, ig_md.d_15_est_1);
            update_15_2.apply(SRCIP, SRCPORT, 1, ig_md.d_15_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(15)
        //

        T1_RUN_1_KEY_2(16, DSTIP, DSTPORT)
        T2_RUN_AFTER_3_KEY_2(18, DSTIP, DSTPORT, 1)
        T3_RUN_AFTER_5_KEY_2(17, DSTIP, DSTPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_res_hash);
            update_19_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_19_res_hash[1:1], SIZE, ig_md.d_19_est_1);
            update_19_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_19_res_hash[2:2], SIZE, ig_md.d_19_est_2);
            update_19_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_19_res_hash[3:3], SIZE, ig_md.d_19_est_3);
            d_20_above_threshold.apply(ig_md.d_19_est_1, ig_md.d_19_est_2, ig_md.d_19_est_3, ig_md.d_20_above_threshold);
            update_19_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_19_est_4);
        //

        T1_RUN_3_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_21_est1_1 == 0 || ig_md.d_21_est1_2 == 0 || ig_md.d_21_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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