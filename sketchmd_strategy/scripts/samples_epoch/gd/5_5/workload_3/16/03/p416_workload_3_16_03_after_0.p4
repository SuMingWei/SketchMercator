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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    MRB_INIT_1( 1, 100, 262144, 15,  8)
    T2_INIT_2( 2, 100, 8192)
    T2_INIT_1( 3, 100, 16384)
    T2_INIT_HH_4( 4, 100, 8192)
    T1_INIT_1( 5, 100, 262144)
    T1_INIT_1( 6, 100, 524288)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 

    T2_INIT_HH_3( 9, 200, 16384)
    MRAC_INIT_1(10, 200, 32768, 11, 16)
    T1_INIT_3(11, 110, 262144)
    T3_INIT_HH_5(12, 110, 4096)
    T2_INIT_HH_5(13, 110, 8192)
    T2_INIT_1(14, 220, 16384)
    T2_INIT_2(15, 221, 16384)
    UM_INIT_5(16, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_10_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_16);

        //

        // MRB for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_32);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1_1.apply(ig_md.d_1_base_32, ig_md.d_1_index1_16);
        //

        T2_RUN_2_KEY_1( 2, SRCIP, 1)
        T2_RUN_1_KEY_1( 3, SRCIP, 1)
        T2_RUN_AFTER_4_KEY_1( 4, SRCIP, 1)
        T1_RUN_1_KEY_1( 5, DSTIP) if (ig_md.d_5_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_1( 6, DSTIP)

        // apply O2
        T2_RUN_AFTER_5_KEY_1(7, DSTIP, 1)
        // 

        T2_RUN_AFTER_3_KEY_2( 9, SRCIP, DSTIP, 1)
        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_10_index1_16);
            update_10_1.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        T1_RUN_3_KEY_2(11, SRCIP, SRCPORT) if (ig_md.d_11_est1_1 == 0 || ig_md.d_11_est1_2 == 0 || ig_md.d_11_est1_3 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_5_KEY_2(12, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_5_KEY_2(13, DSTIP, DSTPORT, 1)
        T2_RUN_1_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_2_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index3_16); 
            d_16_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index4_16); 
            d_16_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_index5_16); 
            UM_RUN_END_5(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(16) 
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
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