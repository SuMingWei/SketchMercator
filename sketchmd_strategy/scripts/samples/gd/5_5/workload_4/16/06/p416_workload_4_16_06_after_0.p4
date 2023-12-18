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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 100, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_4;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_5;
    //


    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_5_above_threshold;
    // 

    T3_INIT_HH_5( 6, 100, 8192)
    T2_INIT_4( 8, 200, 4096)
    UM_INIT_2( 9, 200, 11, 32768)
    T2_INIT_HH_2(10, 110, 4096)
    T1_INIT_5(11, 110, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_13_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_res_hash_call;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_3;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_4;
        T3_KEY_UPDATE_110_16384(32w0x30243f0b) update_13_5;
    //

    T4_INIT_1(14, 220, 32768)
    T2_INIT_3(15, 220, 4096)
    MRAC_INIT_1(16, 220, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_32);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

        //

        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
            update_2_1.apply(SRCIP, 1, SIZE, ig_md.d_2_est_1);
            d_4_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_4_above_threshold);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_res_hash[2:2], SIZE, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, ig_md.d_2_res_hash[3:3], SIZE, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, ig_md.d_2_res_hash[4:4], SIZE, ig_md.d_2_est_4);
            update_2_5.apply(SRCIP, 1, ig_md.d_2_res_hash[5:5], SIZE, ig_md.d_2_est_5);
            d_3_above_threshold.apply(ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_2_est_4, ig_md.d_2_est_5, ig_md.d_3_above_threshold);
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_1(5, DSTIP, 1)
        // 

        T3_RUN_AFTER_5_KEY_1( 6, DSTIP, 1)
        T2_RUN_4_KEY_2( 8, SRCIP, DSTIP, SIZE)
        // UnivMon for inst 9
            d_9_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_res_hash); 
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16, ig_md.d_9_threshold); 
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16); 
            d_9_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_9_index2_16); 
            UM_RUN_END_2(9, ig_md.d_9_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(9) 
        //

        T2_RUN_AFTER_2_KEY_2(10, SRCIP, SRCPORT, 1)
        T1_RUN_5_KEY_2(11, DSTIP, DSTPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0 || ig_md.d_11_est1_4 == 0 || ig_md.d_11_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_13_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_res_hash);
            update_13_1.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
            update_13_2.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[2:2], SIZE, ig_md.d_13_est_2);
            update_13_3.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[3:3], SIZE, ig_md.d_13_est_3);
            update_13_4.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[4:4], SIZE, ig_md.d_13_est_4);
            update_13_5.apply(DSTIP, DSTPORT, 1, ig_md.d_13_res_hash[5:5], ig_md.d_13_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(13)
        //

        // HLL for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_32, ig_md.d_14_level);
            update_14.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_level);
        //

        T2_RUN_3_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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