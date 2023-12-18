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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_1;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_2_2;
    //

    T1_INIT_5( 4, 100, 262144)
    UM_INIT_3( 5, 100, 11, 32768)
    UM_INIT_5( 6, 100, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_5;
    //

    MRAC_INIT_1( 9, 200, 16384, 11,  8)
    UM_INIT_5(10, 110, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_12_above_threshold;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_1;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_2;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_5;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_14_above_threshold;
        T3_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_13_1;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_13_2;
    //

    MRAC_INIT_1(15, 220, 16384, 10, 16)
    MRAC_INIT_1(16, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_9_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash);
            update_2_1.apply(SRCIP, SIZE, ig_md.d_2_res_hash[1:1], SIZE, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, SIZE, ig_md.d_2_res_hash[2:2], SIZE, ig_md.d_2_est_2);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_3_above_threshold);
        //

        T1_RUN_5_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0 || ig_md.d_4_est1_3 == 0 || ig_md.d_4_est1_4 == 0 || ig_md.d_4_est1_5 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, ig_md.d_5_index2_16); 
            d_5_index_hash_call_3.apply(DSTIP, ig_md.d_5_index3_16); 
            UM_RUN_END_3(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(5) 
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(DSTIP, ig_md.d_6_index3_16); 
            d_6_index_hash_call_4.apply(DSTIP, ig_md.d_6_index4_16); 
            d_6_index_hash_call_5.apply(DSTIP, ig_md.d_6_index5_16); 
            UM_RUN_END_5(6, ig_md.d_6_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(6) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_7_1.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_7_est_1);
            d_8_above_threshold.apply(ig_md.d_7_est_1, ig_md.d_8_above_threshold);
            update_7_2.apply(SRCIP, DSTIP, 1, ig_md.d_7_est_2);
            update_7_3.apply(SRCIP, DSTIP, 1, ig_md.d_7_est_3);
            update_7_4.apply(SRCIP, DSTIP, 1, ig_md.d_7_est_4);
            update_7_5.apply(SRCIP, DSTIP, 1, ig_md.d_7_est_5);
        //

        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_10_index2_16); 
            d_10_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_10_index3_16); 
            d_10_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_10_index4_16); 
            d_10_index_hash_call_5.apply(SRCIP, SRCPORT, ig_md.d_10_index5_16); 
            UM_RUN_END_5(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(10) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash);
            update_11_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_res_hash[1:1], SIZE, ig_md.d_11_est_1);
            update_11_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_res_hash[2:2], SIZE, ig_md.d_11_est_2);
            update_11_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_res_hash[3:3], SIZE, ig_md.d_11_est_3);
            d_12_above_threshold.apply(ig_md.d_11_est_1, ig_md.d_11_est_2, ig_md.d_11_est_3, ig_md.d_12_above_threshold);
            update_11_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_est_4);
            update_11_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_11_est_5);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_res_hash);
            update_13_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_res_hash[1:1], SIZE, ig_md.d_13_est_1);
            d_14_above_threshold.apply(ig_md.d_13_est_1, ig_md.d_14_above_threshold);
            update_13_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_13_est_2);
        //

        // MRAC for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16);
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_16, ig_md.d_15_index1_16);
        //

        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
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