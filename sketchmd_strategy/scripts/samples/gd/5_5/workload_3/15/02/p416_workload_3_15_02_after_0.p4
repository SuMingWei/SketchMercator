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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_210(16384, 14, 10240)

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

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T2_INIT_3( 1, 100, 4096)
    UM_INIT_4( 2, 100, 10, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_2;
    //

    UM_INIT_1( 5, 200, 10, 16384)
    UM_INIT_2( 6, 200, 11, 32768)
    T5_INIT_1( 7, 110, 8192)
    T4_INIT_1( 8, 110, 65536)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_3;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_4;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_5;
    //

    MRAC_INIT_1(11, 110, 32768, 11, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_12_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_12_2;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_12_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_12_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_12_5;
    //

    MRB_INIT_1(14, 221, 262144, 14, 16)
    T2_INIT_3(15, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_7_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_8_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_sampling_hash_16);

        //

        T2_RUN_3_KEY_1( 1, SRCIP, 1)
        // UnivMon for inst 2
            d_2_res_hash_call.apply(DSTIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16); 
            d_2_index_hash_call_2.apply(DSTIP, ig_md.d_2_index2_16); 
            d_2_index_hash_call_3.apply(DSTIP, ig_md.d_2_index3_16); 
            d_2_index_hash_call_4.apply(DSTIP, ig_md.d_2_index4_16); 
            UM_RUN_END_4(2, ig_md.d_2_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(2) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(SRCIP, DSTIP, 1, 1, ig_md.d_3_est_1);
            d_4_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_4_above_threshold);
            update_3_2.apply(SRCIP, DSTIP, 1, ig_md.d_3_est_2);
        //

        // UnivMon for inst 5
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16); 
            UM_RUN_END_1(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_1(5) 
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //

        // PCSA for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            d_7_get_bitmask.apply(ig_md.d_7_level, ig_md.d_7_bitmask);
            update_7.apply(SRCIP, SRCPORT, ig_md.d_7_bitmask);
        //

        // HLL for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_32, ig_md.d_8_level);
            update_8.apply(DSTIP, DSTPORT, ig_md.d_8_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_9_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_1);
            update_9_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_2);
            update_9_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_3);
            update_9_4.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_4);
            update_9_5.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_5);
            d_10_above_threshold.apply(ig_md.d_9_est_1, ig_md.d_9_est_2, ig_md.d_9_est_3, ig_md.d_9_est_4, ig_md.d_9_est_5, ig_md.d_10_above_threshold);
        //

        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_12_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_12_est_3);
            update_12_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_12_est_4);
            update_12_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_12_est_5);
        //

        // MRB for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_32);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index1_16);
            update_14.apply(ig_md.d_14_base_32, ig_md.d_14_index1_16);
        //

        T2_RUN_3_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_dstport); 
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