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
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;
        action d_6_xor_construction() { ig_md.d_6_sampling_hash_16 = ig_md.d_1_sampling_hash_16 ^ ig_md.d_3_sampling_hash_16; }

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_16_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    MRAC_INIT_1( 1, 100, 16384, 11,  8)
    UM_INIT_3( 2, 100, 11, 32768)
    MRB_INIT_1( 3, 100, 262144, 15,  8)
    UM_INIT_4( 4, 100, 11, 32768)
    T2_INIT_5( 5, 200, 4096)
    MRAC_INIT_1( 6, 200, 32768, 11, 16)
    T2_INIT_HH_5( 7, 110, 4096)
    MRAC_INIT_1( 8, 110, 32768, 11, 16)
    T1_INIT_5( 9, 110, 131072)
    T1_INIT_3(10, 110, 524288)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_11_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_11_above_threshold;
    // 

    T2_INIT_4(12, 110, 8192)
    T1_INIT_1(14, 220, 131072)
    UM_INIT_5(15, 220, 11, 32768)
    T4_INIT_1(16, 221, 16384)
    MRAC_INIT_1(17, 221, 16384, 11,  8)
    UM_INIT_5(18, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);
            d_3_auto_sampling_hash_call.apply(DSTIP, ig_md.d_3_sampling_hash_16);
            d_6_xor_construction();
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_8_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_sampling_hash_32);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

        //

        // MRAC for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1_1.apply(ig_md.d_1_base_16, ig_md.d_1_index1_16);
        //

        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            d_2_index_hash_call_2.apply(SRCIP, ig_md.d_2_index2_16); 
            d_2_index_hash_call_3.apply(SRCIP, ig_md.d_2_index3_16); 
            UM_RUN_END_3(2, ig_md.d_2_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(2) 
        //

        // MRB for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_32);
            d_3_index_hash_call_1.apply(DSTIP, ig_md.d_3_index1_16);
            update_3_1.apply(ig_md.d_3_base_32, ig_md.d_3_index1_16);
        //

        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(DSTIP, ig_md.d_4_index3_16); 
            d_4_index_hash_call_4.apply(DSTIP, ig_md.d_4_index4_16); 
            UM_RUN_END_4(4, ig_md.d_4_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(4) 
        //

        T2_RUN_5_KEY_2( 5, SRCIP, DSTIP, SIZE)
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_6_index1_16);
            update_6_1.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        T2_RUN_AFTER_5_KEY_2( 7, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16);
            d_8_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_8_index1_16);
            update_8_1.apply(ig_md.d_8_base_16, ig_md.d_8_index1_16);
        //

        T1_RUN_5_KEY_2( 9, DSTIP, DSTPORT) if (ig_md.d_9_est1_1 == 0 || ig_md.d_9_est1_2 == 0 || ig_md.d_9_est1_3 == 0 || ig_md.d_9_est1_4 == 0 || ig_md.d_9_est1_5 == 0) { /* process_new_flow() */ }
        T1_RUN_3_KEY_2(10, DSTIP, DSTPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_2_KEY_2(11, DSTIP, DSTPORT, 1)
        // 

        T2_RUN_4_KEY_2(12, DSTIP, DSTPORT, SIZE)
        T1_RUN_1_KEY_4(14, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_14_est1_1 == 0) { /* process_new_flow() */ }
        // UnivMon for inst 15
            d_15_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index4_16); 
            d_15_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_15_index5_16); 
            UM_RUN_END_5(15, ig_md.d_15_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(15) 
        //

        // HLL for inst 16
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_32, ig_md.d_16_level);
            update_16_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_16_level);
        //

        // MRAC for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index1_16);
            update_17_1.apply(ig_md.d_17_base_16, ig_md.d_17_index1_16);
        //

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
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
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