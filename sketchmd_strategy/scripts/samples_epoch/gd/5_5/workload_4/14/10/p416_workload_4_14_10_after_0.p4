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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_220(65536, 16, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T3_INIT_HH_1( 1, 100, 16384)
    T1_INIT_5( 2, 100, 131072)
    T2_INIT_HH_2( 3, 100, 4096)
    UM_INIT_5( 4, 100, 11, 32768)
    T2_INIT_HH_1( 5, 110, 16384)
    UM_INIT_4( 6, 110, 11, 32768)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_8_above_threshold;
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_8_hash_call;
        TCAM_LPM_HLLPCSA() d_8_tcam_lpm;
        GET_BITMASK() d_8_get_bitmask;
        T2_T5_KEY_UPDATE_110_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_8_5;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_220_4096(32w0x30243f0b) update_11_3;
    //

    T3_INIT_HH_3(12, 220, 4096)
    T2_INIT_5(13, 221, 16384)
    MRAC_INIT_1(14, 221, 32768, 11, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_220(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_7_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_sampling_hash_16);

        //

        T3_RUN_AFTER_1_KEY_1( 1, SRCIP, 1)
        T1_RUN_5_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0 || ig_md.d_2_est1_5 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_1( 3, DSTIP, 1)
        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(DSTIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(DSTIP, ig_md.d_4_index4_16); 
            d_4_index_hash_call_5.apply(DSTIP, ig_md.d_4_index5_16); 
            UM_RUN_END_5(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(4) 
        //

        T2_RUN_AFTER_1_KEY_2( 5, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_6_index3_16); 
            d_6_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_6_index4_16); 
            UM_RUN_END_4(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(6) 
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_8_tcam_lpm.apply(ig_md.d_7_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            update_8_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_8_bitmask, ig_md.d_8_est_1);
            update_8_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_8_est_2);
            update_8_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_8_est_4);
            update_8_5.apply(DSTIP, DSTPORT, SIZE, ig_md.d_8_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(8)
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_11_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_11_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(11)
        //

        T3_RUN_AFTER_3_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_5_KEY_5(13, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // MRAC for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_14_index1_16);
            update_14_1.apply(ig_md.d_14_base_16, ig_md.d_14_index1_16);
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
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