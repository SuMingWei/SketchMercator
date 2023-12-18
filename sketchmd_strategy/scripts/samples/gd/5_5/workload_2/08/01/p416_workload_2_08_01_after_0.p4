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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(8192, 13, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_3_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_3_hash_call;
        TCAM_LPM_HLLPCSA() d_3_tcam_lpm;
        GET_BITMASK() d_3_get_bitmask;
        T2_T5_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_3_2;
    //

    T3_INIT_HH_3( 2, 200, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 200)
        ABOVE_THRESHOLD_5() d_8_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_8_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_8_2;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_8_index_hash_call_3;
        T3_T2_INDEX_UPDATE_16384() update_8_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_8_index_hash_call_4;
        T3_T2_INDEX_UPDATE_32768() update_8_4;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_8_index_hash_call_5;
        T3_INDEX_UPDATE_16384() update_8_5;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_1_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_3_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_3_level);
            d_3_get_bitmask.apply(ig_md.d_3_level, ig_md.d_3_bitmask);
            update_3_1.apply(SRCIP, DSTIP, 1, ig_md.d_3_bitmask, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, DSTIP, 1, ig_md.d_3_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(3)
        //

        T3_RUN_AFTER_3_KEY_2( 2, SRCIP, DSTIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], SIZE, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], SIZE, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], SIZE, ig_md.d_8_est_3);
        d_8_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_8_index4_16);
        update_8_4.apply(ig_md.d_8_base_16_2048, ig_md.d_8_index4_16, ig_md.d_8_res_hash[4:4], SIZE, ig_md.d_8_est_4);
        d_8_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_8_index5_16);
        update_8_5.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index5_16, ig_md.d_8_res_hash[5:5], SIZE, ig_md.d_8_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(8)
        // 

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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