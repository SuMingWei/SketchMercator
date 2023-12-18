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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 24576)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    T5_INIT_1( 1, 100, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_1;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_3;
    //

    T4_INIT_1( 4, 100, 32768)
    T3_INIT_HH_1( 7, 100, 16384)
    T2_INIT_HH_4( 5, 100, 16384)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_6_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
    // 

    T2_INIT_HH_5( 8, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(12, 100)
        ABOVE_THRESHOLD_2() d_12_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_12_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_12_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_12_2;
    // 

    T1_INIT_4(13, 200, 524288)
    T2_INIT_HH_5(14, 200, 8192)
    UM_INIT_5(15, 200, 10, 16384)
    T2_INIT_2(16, 110, 4096)
    UM_INIT_5(17, 110, 10, 16384)
    T2_INIT_HH_4(18, 220, 16384)
    MRAC_INIT_1(19, 220, 16384, 10, 16)
    T2_INIT_HH_5(20, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(DSTIP, ig_md.d_12_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_15_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_sampling_hash_16);

        //

        // PCSA for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            d_1_get_bitmask.apply(ig_md.d_1_level, ig_md.d_1_bitmask);
            update_1.apply(SRCIP, ig_md.d_1_bitmask);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, 1, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, 1, ig_md.d_2_est_3);
            d_3_above_threshold.apply(ig_md.d_2_est_1, ig_md.d_2_est_2, ig_md.d_2_est_3, ig_md.d_3_above_threshold);
        //

        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(DSTIP, ig_md.d_4_level);
        //

        T3_RUN_AFTER_1_KEY_1( 7, DSTIP, 1)
        T2_RUN_AFTER_4_KEY_1( 5, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_1(6, DSTIP, 1)
        // 

        T2_RUN_AFTER_5_KEY_1( 8, DSTIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_12_res_hash_call.apply(DSTIP, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(DSTIP, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], 1, ig_md.d_12_est_1);
        d_12_index_hash_call_2.apply(DSTIP, ig_md.d_12_index2_16);
        update_12_2.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index2_16, ig_md.d_12_res_hash[2:2], 1, ig_md.d_12_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(12)
        // 

        T1_RUN_4_KEY_2(13, SRCIP, DSTIP) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0 || ig_md.d_13_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_5_KEY_2(14, SRCIP, DSTIP, 1)
        // UnivMon for inst 15
            d_15_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_15_index4_16); 
            d_15_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_15_index5_16); 
            UM_RUN_END_5(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(15) 
        //

        T2_RUN_2_KEY_2(16, SRCIP, SRCPORT, 1)
        // UnivMon for inst 17
            d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_17_index3_16); 
            d_17_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_17_index4_16); 
            d_17_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_17_index5_16); 
            UM_RUN_END_5(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(17) 
        //

        T2_RUN_AFTER_4_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16);
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_19_index1_16);
            update_19.apply(ig_md.d_19_base_16, ig_md.d_19_index1_16);
        //

        T2_RUN_AFTER_5_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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
        ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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