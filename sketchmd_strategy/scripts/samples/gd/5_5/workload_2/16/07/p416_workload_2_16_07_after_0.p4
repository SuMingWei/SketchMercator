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
        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    T1_INIT_1( 2, 221, 524288)
    T1_INIT_3( 3, 221, 524288)
    T1_INIT_4( 1, 221, 524288)
    MRB_INIT_1( 4, 221, 262144, 14, 16)

    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_7_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_7_above_threshold;
    // 

    T2_INIT_HH_1(13, 221, 16384)

    // apply O2
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_6_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_6_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_5_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_5_above_threshold;
    // 

    T2_INIT_HH_4(11, 221, 4096)
    T2_INIT_HH_5( 8, 221, 8192)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(16, 221)
        ABOVE_THRESHOLD_3() d_16_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_16_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_16_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_16_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_16_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_16_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_16_3;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_4_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_16);

        //

        T1_RUN_1_KEY_5( 2, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_5( 3, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_5( 1, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        // MRB for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_32);
            d_4_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_32, ig_md.d_4_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_1_KEY_5(7, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 

        T2_RUN_AFTER_1_KEY_5(13, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)

        // apply O2
        T2_RUN_AFTER_2_KEY_5(6, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_4_KEY_5(5, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // 

        T2_RUN_AFTER_4_KEY_5(11, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        T2_RUN_AFTER_5_KEY_5( 8, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_res_hash);
        d_16_tcam_lpm_2.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16_1024, ig_md.d_16_base_16_2048, ig_md.d_16_threshold);
        d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index1_16);
        update_16_1.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index1_16, ig_md.d_16_res_hash[1:1], SIZE, ig_md.d_16_est_1);
        d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index2_16);
        update_16_2.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index2_16, ig_md.d_16_res_hash[2:2], SIZE, ig_md.d_16_est_2);
        d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index3_16);
        update_16_3.apply(ig_md.d_16_base_16_2048, ig_md.d_16_index3_16, ig_md.d_16_res_hash[3:3], SIZE, ig_md.d_16_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(16)
        // 

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
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