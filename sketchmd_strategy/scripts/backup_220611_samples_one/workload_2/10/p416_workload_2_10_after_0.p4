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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    T1_INIT_2( 1, 110, 262144)

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_3_4;
    //

    // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_6_above_threshold;
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_res_hash_call;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_1;
        T3_KEY_UPDATE_110_4096(32w0x30243f0b) update_6_2;
    //
    T2_INIT_HH_3( 7, 110, 16384)

    // apply O3; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 110)
        ABOVE_THRESHOLD_3() d_10_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_10_2;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_10_3;
    // 

    UM_INIT_4( 9, 110, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        T1_RUN_2_KEY_2( 1, DSTIP, DSTPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(DSTIP, DSTPORT, SIZE, 1, ig_md.d_3_est_1);
            update_3_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(DSTIP, DSTPORT, SIZE, ig_md.d_3_est_3);
            update_3_4.apply(DSTIP, DSTPORT, SIZE, ig_md.d_3_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(3)
        //

        // apply O3; big - CM/Kary/CS / small - Ent/PCSA 
            d_6_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_res_hash);
            update_6_1.apply(DSTIP, DSTPORT, SIZE, ig_md.d_6_res_hash[1:1], SIZE, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, DSTPORT, SIZE, ig_md.d_6_res_hash[2:2], ig_md.d_6_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(6)
        //
        T2_RUN_AFTER_3_KEY_2( 7, DSTIP, DSTPORT, 1)

        // apply O3; big - UnivMon / small - many MRACs 
        d_10_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_sampling_hash_16);
        d_10_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
        d_10_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_10_index3_16);
        update_10_3.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index3_16, ig_md.d_10_res_hash[3:3], 1, ig_md.d_10_est_3);
        RUN_HEAVY_FLOWKEY_NOIF_3(10)
        // 

        UM_RUN_AFTER_4_KEY_2( 9, DSTIP, DSTPORT, 1)
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip, ig_md.hf_dstport); 
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