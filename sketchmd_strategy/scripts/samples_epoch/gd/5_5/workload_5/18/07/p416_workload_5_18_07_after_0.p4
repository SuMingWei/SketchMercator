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
    METADATA_DIM(18)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(65536, 16, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_1;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_2;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_3;
    // 

    T2_INIT_HH_1( 3, 100, 4096)
    UM_INIT_5( 4, 100, 11, 32768)
    T2_INIT_HH_3( 5, 100, 4096)
    T1_INIT_3( 6, 200, 131072)
    T1_INIT_2( 7, 200, 131072)
    T2_INIT_HH_2( 8, 200, 16384)
    T2_INIT_4( 9, 110, 16384)
    T2_INIT_HH_2(10, 110, 8192)
    T1_INIT_1(11, 110, 524288)
    T2_INIT_3(12, 110, 4096)
    MRAC_INIT_1(13, 110, 16384, 11,  8)
    T1_INIT_4(14, 220, 524288)
    T2_INIT_HH_2(15, 220, 16384)
    UM_INIT_4(16, 220, 11, 32768)
    T1_INIT_4(17, 221, 524288)
    UM_INIT_5(18, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

        //


        // apply O2
        T1_RUN_3_KEY_1(1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // 

        T2_RUN_AFTER_1_KEY_1( 3, SRCIP, SIZE)
        // UnivMon for inst 4
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(SRCIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(SRCIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(SRCIP, ig_md.d_4_index4_16); 
            d_4_index_hash_call_5.apply(SRCIP, ig_md.d_4_index5_16); 
            UM_RUN_END_5(4, ig_md.d_4_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(4) 
        //

        T2_RUN_AFTER_3_KEY_1( 5, DSTIP, 1)
        T1_RUN_3_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_2_KEY_2( 7, SRCIP, DSTIP) if (ig_md.d_7_est1_1 == 0 || ig_md.d_7_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_2( 8, SRCIP, DSTIP, SIZE)
        T2_RUN_4_KEY_2( 9, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_2_KEY_2(10, SRCIP, SRCPORT, 1)
        T1_RUN_1_KEY_2(11, DSTIP, DSTPORT)
        T2_RUN_3_KEY_2(12, DSTIP, DSTPORT, 1)
        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
            update_13_1.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        T1_RUN_4_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_14_est1_1 == 0 || ig_md.d_14_est1_2 == 0 || ig_md.d_14_est1_3 == 0 || ig_md.d_14_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // UnivMon for inst 16
            d_16_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index3_16); 
            d_16_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index4_16); 
            UM_RUN_END_4(16, ig_md.d_16_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(16) 
        //

        T1_RUN_4_KEY_5(17, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_17_est1_1 == 0 || ig_md.d_17_est1_2 == 0 || ig_md.d_17_est1_3 == 0 || ig_md.d_17_est1_4 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index3_16); 
            d_18_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index4_16); 
            d_18_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index5_16); 
            UM_RUN_END_5(18, ig_md.d_18_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(18) 
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
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