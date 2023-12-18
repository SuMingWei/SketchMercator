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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(8192, 13, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

    //

    T2_INIT_4( 1, 100, 16384)
    T2_INIT_2( 2, 100, 4096)
    UM_INIT_3( 3, 100, 10, 16384)
    T1_INIT_2( 4, 200, 524288)
    T2_INIT_5( 5, 200, 8192)
    T2_INIT_1( 6, 110, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(8, 110)
        ABOVE_THRESHOLD_4() d_8_above_threshold;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_8_1;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_8_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_8_2;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_8_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_8_3;
        COMPUTE_HASH_110_16_10(32w0x30244f0b) d_8_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_8_4;
    // 

    T4_INIT_1( 9, 220, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_11_5;
    //


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(13, 221)
        ABOVE_THRESHOLD_4() d_13_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_13_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_13_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_13_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_13_3;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_13_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_13_4;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_8_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_sampling_hash_16);

        //

        T2_RUN_4_KEY_1( 1, SRCIP, SIZE)
        T2_RUN_2_KEY_1( 2, DSTIP, SIZE)
        // UnivMon for inst 3
            d_3_res_hash_call.apply(DSTIP, ig_md.d_3_res_hash); 
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16, ig_md.d_3_threshold); 
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16); 
            d_3_index_hash_call_2.apply(DSTIP, ig_md.d_3_index2_16); 
            d_3_index_hash_call_3.apply(DSTIP, ig_md.d_3_index3_16); 
            UM_RUN_END_3(3, ig_md.d_3_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(3) 
        //

        T1_RUN_2_KEY_2( 4, SRCIP, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_5_KEY_2( 5, SRCIP, DSTIP, 1)
        T2_RUN_1_KEY_2( 6, SRCIP, SRCPORT, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_8_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], 1, ig_md.d_8_est_1);
        d_8_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_8_index2_16);
        update_8_2.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index2_16, ig_md.d_8_res_hash[2:2], 1, ig_md.d_8_est_2);
        d_8_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_8_index3_16);
        update_8_3.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index3_16, ig_md.d_8_res_hash[3:3], 1, ig_md.d_8_est_3);
        d_8_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_8_index4_16);
        update_8_4.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index4_16, ig_md.d_8_res_hash[4:4], 1, ig_md.d_8_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(8)
        // 

        // HLL for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
            update_9.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_9_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_11_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, SIZE, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, 1, ig_md.d_11_est_5);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        d_13_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index2_16);
        update_13_2.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index2_16, ig_md.d_13_res_hash[2:2], 1, ig_md.d_13_est_2);
        d_13_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index3_16);
        update_13_3.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index3_16, ig_md.d_13_res_hash[3:3], 1, ig_md.d_13_est_3);
        d_13_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_13_index4_16);
        update_13_4.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index4_16, ig_md.d_13_res_hash[4:4], 1, ig_md.d_13_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(13)
        // 

        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_13_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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