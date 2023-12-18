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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;
        action d_6_xor_construction() { ig_md.d_6_sampling_hash_16 = ig_md.d_2_sampling_hash_16 ^ ig_md.d_1_sampling_hash_16; }

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

    //

    MRAC_INIT_1( 1, 100, 32768, 11, 16)
    MRB_INIT_1( 2, 100, 131072, 14,  8)
    MRB_INIT_1( 3, 100, 262144, 14, 16)
    T1_INIT_1( 4, 200, 524288)
    T2_INIT_HH_4( 5, 200, 8192)
    MRAC_INIT_1( 6, 200, 16384, 11,  8)
    T4_INIT_1( 7, 110, 16384)
    T2_INIT_HH_4( 8, 110, 4096)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_3;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_12_above_threshold;
        T2_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_1;
        T2_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_2;
        T2_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_3;
        T2_T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_5;
    //

    UM_INIT_4(13, 220, 10, 16384)
    T1_INIT_3(14, 221, 524288)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_16);
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);
            d_6_xor_construction();
            d_7_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_7_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_16);

        //

        // MRAC for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_16, ig_md.d_1_index1_16);
        //

        // MRB for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_32);
            d_2_index_hash_call_1.apply(DSTIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_32, ig_md.d_2_index1_16);
        //

        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
            update_3.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        T1_RUN_1_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_4_KEY_2( 5, SRCIP, DSTIP, 1)
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        // HLL for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_7_level);
            update_7.apply(SRCIP, SRCPORT, ig_md.d_7_level);
        //

        T2_RUN_AFTER_4_KEY_2( 8, SRCIP, SRCPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_9_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_1);
            update_9_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_2);
            update_9_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_3);
            d_10_above_threshold.apply(ig_md.d_9_est_1, ig_md.d_9_est_2, ig_md.d_9_est_3, ig_md.d_10_above_threshold);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_11_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, 1, ig_md.d_11_est_4);
            d_12_above_threshold.apply(ig_md.d_11_est_1, ig_md.d_11_est_2, ig_md.d_11_est_3, ig_md.d_11_est_4, ig_md.d_12_above_threshold);
            update_11_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_11_est_5);
        //

        // UnivMon for inst 13
            d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index2_16); 
            d_13_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index3_16); 
            d_13_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index4_16); 
            UM_RUN_END_4(13, ig_md.d_13_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(13) 
        //

        T1_RUN_3_KEY_5(14, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0) { /* process_new_flow() */ }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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