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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

    //

    T1_INIT_1( 3, 110, 524288)
    T1_INIT_4( 1, 110, 131072)
    T4_INIT_1( 2, 110, 65536)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_4_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_2;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_3;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_4_4;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_1;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_11_above_threshold;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_2;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_3;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_5_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_5_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_5_4;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(15, 110)
        ABOVE_THRESHOLD_4() d_15_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_15_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_15_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_3;
        T3_T2_INDEX_UPDATE_32768() update_15_3;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_15_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_15_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_2_sampling_hash_32);

            d_15_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 3, SRCIP, SRCPORT)
        T1_RUN_4_KEY_2( 1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2.apply(SRCIP, SRCPORT, ig_md.d_2_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_4_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_4_res_hash);
            update_4_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_4_est_1);
            d_7_above_threshold.apply(ig_md.d_4_est_1, ig_md.d_7_above_threshold);
            update_4_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_4_res_hash[2:2], 1, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_4_res_hash[3:3], 1, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, SRCPORT, SIZE, ig_md.d_4_res_hash[4:4], 1, ig_md.d_4_est_4);
            d_10_above_threshold.apply(ig_md.d_4_est_2, ig_md.d_4_est_3, ig_md.d_4_est_4, ig_md.d_10_above_threshold);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_res_hash);
            update_6_1.apply(SRCIP, SRCPORT, SIZE, SIZE, ig_md.d_6_est_1);
            d_9_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_9_above_threshold);
            update_6_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_6_res_hash[2:2], SIZE, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, SRCPORT, SIZE, ig_md.d_6_res_hash[3:3], SIZE, ig_md.d_6_est_3);
            d_11_above_threshold.apply(ig_md.d_6_est_2, ig_md.d_6_est_3, ig_md.d_11_above_threshold);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_5_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_5_est_3);
            d_8_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_8_above_threshold);
            update_5_4.apply(SRCIP, SRCPORT, 1, ig_md.d_5_est_4);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_15_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_res_hash);
        d_15_tcam_lpm_2.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16_1024, ig_md.d_15_base_16_2048, ig_md.d_15_threshold);
        d_15_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_15_index1_16);
        update_15_1.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index1_16, ig_md.d_15_res_hash[1:1], SIZE, ig_md.d_15_est_1);
        d_15_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_15_index2_16);
        update_15_2.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index2_16, ig_md.d_15_res_hash[2:2], SIZE, ig_md.d_15_est_2);
        d_15_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_15_index3_16);
        update_15_3.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index3_16, ig_md.d_15_res_hash[3:3], SIZE, ig_md.d_15_est_3);
        d_15_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_15_index4_16);
        update_15_4.apply(ig_md.d_15_base_16_2048, ig_md.d_15_index4_16, ig_md.d_15_res_hash[4:4], SIZE, ig_md.d_15_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(15)
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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