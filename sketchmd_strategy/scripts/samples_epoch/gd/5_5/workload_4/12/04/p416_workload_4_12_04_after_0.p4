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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_210(32768, 15, 10240)

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

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    UM_INIT_4( 1, 100, 11, 32768)
    UM_INIT_4( 2, 100, 11, 32768)
    T1_INIT_5( 3, 100, 524288)
    T4_INIT_1( 4, 100, 4096)
    T2_INIT_HH_1( 7, 100, 8192)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_res_hash_call;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_2;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_3;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_4;
        T3_KEY_UPDATE_100_16384(32w0x30243f0b) update_6_5;
    //

    MRB_INIT_1( 8, 200, 262144, 15,  8)
    T5_INIT_1( 9, 110, 4096)
    T1_INIT_5(10, 110, 262144)
    UM_INIT_5(11, 110, 11, 32768)
    T4_INIT_1(12, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

            d_9_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_9_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_32);

        //

        // UnivMon for inst 1
            d_1_res_hash_call.apply(SRCIP, ig_md.d_1_res_hash); 
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16, ig_md.d_1_threshold); 
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16); 
            d_1_index_hash_call_2.apply(SRCIP, ig_md.d_1_index2_16); 
            d_1_index_hash_call_3.apply(SRCIP, ig_md.d_1_index3_16); 
            d_1_index_hash_call_4.apply(SRCIP, ig_md.d_1_index4_16); 
            UM_RUN_END_4(1, ig_md.d_1_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(1) 
        //

        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            d_2_index_hash_call_2.apply(SRCIP, ig_md.d_2_index2_16); 
            d_2_index_hash_call_3.apply(SRCIP, ig_md.d_2_index3_16); 
            d_2_index_hash_call_4.apply(SRCIP, ig_md.d_2_index4_16); 
            UM_RUN_END_4(2, ig_md.d_2_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(2) 
        //

        T1_RUN_5_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4_1.apply(DSTIP, ig_md.d_4_level);
        //

        T2_RUN_AFTER_1_KEY_1( 7, DSTIP, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_6_res_hash_call.apply(DSTIP, ig_md.d_6_res_hash);
            update_6_1.apply(DSTIP, SIZE, ig_md.d_6_res_hash[0:0], 1, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, SIZE, ig_md.d_6_res_hash[1:1], 1, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, SIZE, ig_md.d_6_res_hash[2:2], ig_md.d_6_est_3);
            update_6_4.apply(DSTIP, SIZE, ig_md.d_6_res_hash[3:3], ig_md.d_6_est_4);
            update_6_5.apply(DSTIP, SIZE, ig_md.d_6_res_hash[4:4], ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //

        // MRB for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_32);
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
            update_8_1.apply(ig_md.d_8_base_32, ig_md.d_8_index1_16);
        //

        // PCSA for inst 9
            d_9_tcam_lpm.apply(ig_md.d_9_sampling_hash_32, ig_md.d_9_level);
            d_9_get_bitmask.apply(ig_md.d_9_level, ig_md.d_9_bitmask);
            update_9_1.apply(SRCIP, SRCPORT, ig_md.d_9_bitmask);
        //

        T1_RUN_5_KEY_2(10, DSTIP, DSTPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0 || ig_md.d_10_est1_4 == 0 || ig_md.d_10_est1_5 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 11
            d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_11_index4_16); 
            d_11_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_11_index5_16); 
            UM_RUN_END_5(11, ig_md.d_11_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(11) 
        //

        // HLL for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            update_12_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_level);
        //

        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_1_above_threshold == 1
        || ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_dstport); 
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