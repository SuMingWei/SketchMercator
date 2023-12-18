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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 524288)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
    //

    T2_INIT_HH_1( 5, 100, 4096)
    UM_INIT_2( 6, 100, 11, 32768)
    T1_INIT_1( 7, 200, 131072)
    MRAC_INIT_1( 8, 200, 16384, 10, 16)
    T1_INIT_2( 9, 110, 524288)
    T1_INIT_3(10, 110, 524288)
    MRB_INIT_1(11, 110, 262144, 14, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_13_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_2;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_5;
    //

    T1_INIT_1(14, 110, 131072)
    T1_INIT_1(15, 110, 131072)
    MRAC_INIT_1(16, 220, 8192, 10,  8)
    MRAC_INIT_1(17, 221, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(SRCIP, 1, 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, 1, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, 1, 1, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, 1, ig_md.d_3_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(3)
        //

        T2_RUN_AFTER_1_KEY_1( 5, DSTIP, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP)
        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
            update_8.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //

        T1_RUN_2_KEY_2( 9, SRCIP, SRCPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_2(10, SRCIP, SRCPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0) { /* process_new_flow() */ }
        // MRB for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_32);
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_32, ig_md.d_11_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_12_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_12_est_1);
            update_12_2.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_12_est_2);
            update_12_3.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_12_est_3);
            d_13_above_threshold.apply(ig_md.d_12_est_1, ig_md.d_12_est_2, ig_md.d_12_est_3, ig_md.d_13_above_threshold);
            update_12_4.apply(SRCIP, SRCPORT, 1, ig_md.d_12_est_4);
            update_12_5.apply(SRCIP, SRCPORT, 1, ig_md.d_12_est_5);
        //

        T1_RUN_1_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2(15, DSTIP, DSTPORT)
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        // MRAC for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index1_16);
            update_17.apply(ig_md.d_17_base_16, ig_md.d_17_index1_16);
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport); 
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