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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 262144, 14, 16)
    UM_INIT_1( 2, 100, 10, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_4;
    //

    T2_INIT_2( 5, 110, 16384)
    UM_INIT_2( 6, 110, 11, 32768)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_sampling_hash_call;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_7_index_hash_call_1;
        LPM_OPT_MRAC_2() d_7_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_7;
    // 

    T3_INIT_HH_1( 9, 220, 4096)
    T2_INIT_HH_5(10, 220, 16384)
    T2_INIT_3(11, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_7_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //

        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            UM_RUN_END_1(2, ig_md.d_2_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(2) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(DSTIP, 1, 1, ig_md.d_3_est_1);
            update_3_2.apply(DSTIP, 1, 1, ig_md.d_3_est_2);
            update_3_3.apply(DSTIP, 1, 1, ig_md.d_3_est_3);
            update_3_4.apply(DSTIP, 1, 1, ig_md.d_3_est_4);
            d_4_above_threshold.apply(ig_md.d_3_est_1, ig_md.d_3_est_2, ig_md.d_3_est_3, ig_md.d_3_est_4, ig_md.d_4_above_threshold);
        //

        T2_RUN_2_KEY_2( 5, SRCIP, SRCPORT, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_7_tcam_lpm_2.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16_1024, ig_md.d_7_base_16_2048);
        d_7_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_7_index1_16);
        update_7.apply(ig_md.d_7_base_16_2048, ig_md.d_7_index1_16);
        // 

        T3_RUN_AFTER_1_KEY_4( 9, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_AFTER_5_KEY_4(10, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T2_RUN_3_KEY_5(11, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
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