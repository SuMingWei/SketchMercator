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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    T2_INIT_1( 1, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(3, 100)
        ABOVE_THRESHOLD_4() d_3_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_3_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_3_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_3_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_3_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_3_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_3_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_3_4;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_5_above_threshold;
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_5_hash_call;
        TCAM_LPM_HLLPCSA() d_5_tcam_lpm;
        GET_BITMASK() d_5_get_bitmask;
        T2_T5_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_5_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_5_5;
    //

    UM_INIT_5( 6, 100, 10, 16384)
    T2_INIT_HH_5( 7, 110, 8192)
    T2_INIT_HH_3( 8, 220, 8192)
    MRAC_INIT_1( 9, 220, 16384, 10, 16)
    UM_INIT_2(10, 221, 11, 32768)
    UM_INIT_2(11, 221, 11, 32768)
    UM_INIT_5(12, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_16);

        //

        T2_RUN_1_KEY_1( 1, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash);
        d_3_tcam_lpm_2.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16_1024, ig_md.d_3_base_16_2048, ig_md.d_3_threshold);
        d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
        update_3_1.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index1_16, ig_md.d_3_res_hash[1:1], 1, ig_md.d_3_est_1);
        d_3_index_hash_call_2.apply(SRCIP, ig_md.d_3_index2_16);
        update_3_2.apply(ig_md.d_3_base_16_1024, ig_md.d_3_index2_16, ig_md.d_3_res_hash[2:2], 1, ig_md.d_3_est_2);
        d_3_index_hash_call_3.apply(SRCIP, ig_md.d_3_index3_16);
        update_3_3.apply(ig_md.d_3_base_16_1024, ig_md.d_3_index3_16, ig_md.d_3_res_hash[3:3], 1, ig_md.d_3_est_3);
        d_3_index_hash_call_4.apply(SRCIP, ig_md.d_3_index4_16);
        update_3_4.apply(ig_md.d_3_base_16_1024, ig_md.d_3_index4_16, ig_md.d_3_res_hash[4:4], 1, ig_md.d_3_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(3)
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_5_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_5_level);
            d_5_get_bitmask.apply(ig_md.d_5_level, ig_md.d_5_bitmask);
            update_5_1.apply(DSTIP, SIZE, ig_md.d_5_bitmask, ig_md.d_5_est_1);
            update_5_2.apply(DSTIP, SIZE, ig_md.d_5_est_2);
            update_5_3.apply(DSTIP, SIZE, ig_md.d_5_est_3);
            update_5_4.apply(DSTIP, SIZE, ig_md.d_5_est_4);
            update_5_5.apply(DSTIP, SIZE, ig_md.d_5_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(5)
        //

        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            d_6_index_hash_call_3.apply(DSTIP, ig_md.d_6_index3_16); 
            d_6_index_hash_call_4.apply(DSTIP, ig_md.d_6_index4_16); 
            d_6_index_hash_call_5.apply(DSTIP, ig_md.d_6_index5_16); 
            UM_RUN_END_5(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(6) 
        //

        T2_RUN_AFTER_5_KEY_2( 7, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_3_KEY_4( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16);
            d_9_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_index1_16);
            update_9.apply(ig_md.d_9_base_16, ig_md.d_9_index1_16);
        //

        // UnivMon for inst 10
            d_10_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_res_hash); 
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16, ig_md.d_10_threshold); 
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_index1_16); 
            d_10_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_index2_16); 
            UM_RUN_END_2(10, ig_md.d_10_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(10) 
        //

        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_11_index2_16); 
            UM_RUN_END_2(11, ig_md.d_11_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(11) 
        //

        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index3_16); 
            d_12_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index4_16); 
            d_12_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index5_16); 
            UM_RUN_END_5(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(12) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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