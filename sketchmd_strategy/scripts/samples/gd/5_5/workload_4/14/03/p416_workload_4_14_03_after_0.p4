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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_9_auto_sampling_hash_call;

    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(2, 100)
        ABOVE_THRESHOLD_3() d_2_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_2_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_2_2;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_2_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_2_3;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
    // 

    UM_INIT_1( 5, 200, 11, 32768)
    T4_INIT_1( 6, 110, 65536)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 

    T4_INIT_1( 9, 110, 32768)
    T2_INIT_2(10, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_12_above_threshold;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_1;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_2;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_3;
        T3_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_4;
    //

    T1_INIT_1(13, 220, 524288)
    T2_INIT_5(14, 220, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_32);

            d_9_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_9_sampling_hash_32);

        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_2_res_hash_call.apply(DSTIP, ig_md.d_2_res_hash);
        d_2_tcam_lpm_2.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16_1024, ig_md.d_2_base_16_2048, ig_md.d_2_threshold);
        d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
        update_2_1.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index1_16, ig_md.d_2_res_hash[1:1], SIZE, ig_md.d_2_est_1);
        d_2_index_hash_call_2.apply(DSTIP, ig_md.d_2_index2_16);
        update_2_2.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index2_16, ig_md.d_2_res_hash[2:2], SIZE, ig_md.d_2_est_2);
        d_2_index_hash_call_3.apply(DSTIP, ig_md.d_2_index3_16);
        update_2_3.apply(ig_md.d_2_base_16_2048, ig_md.d_2_index3_16, ig_md.d_2_res_hash[3:3], SIZE, ig_md.d_2_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(2)
        // 


        // apply O2
        T2_RUN_AFTER_2_KEY_2(3, SRCIP, DSTIP, 1)
        // 

        // UnivMon for inst 5
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16); 
            UM_RUN_END_1(5, ig_md.d_5_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(5) 
        //

        // HLL for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_6_level);
            update_6.apply(SRCIP, SRCPORT, ig_md.d_6_level);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_2(7, SRCIP, SRCPORT, SIZE)
        // 

        // HLL for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
            update_9.apply(DSTIP, DSTPORT, ig_md.d_9_level);
        //

        T2_RUN_2_KEY_2(10, DSTIP, DSTPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash);
            update_11_1.apply(DSTIP, DSTPORT, 1, ig_md.d_11_res_hash[1:1], SIZE, ig_md.d_11_est_1);
            update_11_2.apply(DSTIP, DSTPORT, 1, ig_md.d_11_res_hash[2:2], SIZE, ig_md.d_11_est_2);
            update_11_3.apply(DSTIP, DSTPORT, 1, ig_md.d_11_res_hash[3:3], SIZE, ig_md.d_11_est_3);
            update_11_4.apply(DSTIP, DSTPORT, 1, ig_md.d_11_res_hash[4:4], SIZE, ig_md.d_11_est_4);
            d_12_above_threshold.apply(ig_md.d_11_est_1, ig_md.d_11_est_2, ig_md.d_11_est_3, ig_md.d_11_est_4, ig_md.d_12_above_threshold);
        //

        T1_RUN_1_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT)
        T2_RUN_5_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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