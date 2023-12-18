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
    METADATA_DIM(19)
    METADATA_DIM(20)
    METADATA_DIM(21)
    METADATA_DIM(22)
    METADATA_DIM(23)
    METADATA_DIM(24)
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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_2_5;
    //


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
    // 

    T2_INIT_HH_5( 4, 100, 8192)
    UM_INIT_2( 6, 100, 11, 32768)
    T3_INIT_HH_5( 7, 200, 8192)

    // apply O2
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_8_1;
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_8_2;
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_8_3;
        T1_KEY_UPDATE_110_524288(32w0x30243f0b) update_8_4;
    // 

    T1_INIT_4( 9, 110, 524288)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_12_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_1;
    //


    // apply O2
        T1_KEY_UPDATE_110_262144(32w0x30243f0b) update_13_1;
    // 

    T1_INIT_1(14, 110, 262144)
    T1_INIT_1(15, 110, 131072)
    T2_INIT_3(18, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_19_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_1;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_2;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_3;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_17_4;
    //

    T1_INIT_3(20, 220, 131072)
    T2_INIT_3(21, 220, 8192)
    T1_INIT_2(22, 221, 131072)
    T2_INIT_HH_2(23, 221, 4096)
    UM_INIT_5(24, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, 1, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, 1, ig_md.d_2_est_4);
            update_2_5.apply(SRCIP, 1, ig_md.d_2_est_5);
        //


        // apply O2
        T2_RUN_AFTER_5_KEY_1(3, DSTIP, 1)
        // 

        T2_RUN_AFTER_5_KEY_1( 4, DSTIP, 1)
        // UnivMon for inst 6
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash); 
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16, ig_md.d_6_threshold); 
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16); 
            d_6_index_hash_call_2.apply(DSTIP, ig_md.d_6_index2_16); 
            UM_RUN_END_2(6, ig_md.d_6_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(6) 
        //

        T3_RUN_AFTER_5_KEY_2( 7, SRCIP, DSTIP, 1)

        // apply O2
        T1_RUN_4_KEY_2(8, SRCIP, SRCPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_4_KEY_2( 9, SRCIP, SRCPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0 || ig_md.d_9_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_11_1.apply(SRCIP, SRCPORT, 1, 1, ig_md.d_11_est_1);
            d_12_above_threshold.apply(ig_md.d_11_est_1, ig_md.d_12_above_threshold);
        //


        // apply O2
        T1_RUN_1_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_1_KEY_2(14, DSTIP, DSTPORT) if (ig_md.d_14_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_2(18, DSTIP, DSTPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_17_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_1);
            update_17_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_2);
            update_17_3.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_3);
            update_17_4.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_17_est_4);
            d_19_above_threshold.apply(ig_md.d_17_est_1, ig_md.d_17_est_2, ig_md.d_17_est_3, ig_md.d_17_est_4, ig_md.d_19_above_threshold);
        //

        T1_RUN_3_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0 || ig_md.d_20_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_3_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T1_RUN_2_KEY_5(22, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_22_est1_1 == 0 || ig_md.d_22_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_2_KEY_5(23, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // UnivMon for inst 24
            d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_res_hash); 
            d_24_tcam_lpm.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16, ig_md.d_24_threshold); 
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16); 
            d_24_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index2_16); 
            d_24_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index3_16); 
            d_24_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index4_16); 
            d_24_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index5_16); 
            UM_RUN_END_5(24, ig_md.d_24_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(24) 
        //

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_23_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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