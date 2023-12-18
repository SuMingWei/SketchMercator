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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(8192, 13, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;
        action d_11_xor_construction() { ig_md.d_11_sampling_hash_16 = ig_md.d_9_sampling_hash_16 ^ ig_md.d_10_sampling_hash_16; }

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;
        action d_4_xor_construction() { ig_md.d_4_sampling_hash_16 = ig_md.d_1_sampling_hash_16 ^ ig_md.d_3_sampling_hash_16; }

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

    //

    MRAC_INIT_1( 1, 100, 8192, 10,  8)
    T2_INIT_5( 2, 100, 8192)
    MRAC_INIT_1( 3, 100, 8192, 10,  8)
    MRB_INIT_1( 4, 200, 524288, 15, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_6_above_threshold;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_1;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_2;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_3;
        T3_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_5_4;
    //

    UM_INIT_5( 7, 200, 11, 32768)
    T1_INIT_1( 8, 110, 262144)
    MRAC_INIT_1( 9, 110, 16384, 10, 16)
    MRAC_INIT_1(10, 110, 16384, 10, 16)
    MRB_INIT_1(11, 220, 262144, 15,  8)
    T3_INIT_HH_1(12, 220, 16384)
    MRB_INIT_1(13, 221, 524288, 15, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_16);
            d_10_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_sampling_hash_16);
            d_11_xor_construction();
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);
            d_4_xor_construction();
            d_7_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_sampling_hash_16);

        //

        // MRAC for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_16, ig_md.d_1_index1_16);
        //

        T2_RUN_5_KEY_1( 2, DSTIP, SIZE)
        // MRAC for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16);
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_16, ig_md.d_3_index1_16);
        //

        // MRB for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_32);
            d_4_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_32, ig_md.d_4_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[1:1], 1, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[3:3], 1, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[4:4], 1, ig_md.d_5_est_4);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_est_4, ig_md.d_6_above_threshold);
        //

        // UnivMon for inst 7
            d_7_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_7_index2_16); 
            d_7_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_7_index3_16); 
            d_7_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_7_index4_16); 
            d_7_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_7_index5_16); 
            UM_RUN_END_5(7, ig_md.d_7_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(7) 
        //

        T1_RUN_1_KEY_2( 8, SRCIP, SRCPORT)
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        // MRB for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_32);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_32, ig_md.d_11_index1_16);
        //

        T3_RUN_AFTER_1_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRB for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_32);
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_32, ig_md.d_13_index1_16);
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_6_above_threshold == 1
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