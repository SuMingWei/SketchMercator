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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(32768, 15, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_16_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 131072)
    T1_INIT_1( 2, 100, 131072)

    // apply O2
        T1_KEY_UPDATE_100_524288(32w0x30243f0b) update_3_1;
        T1_KEY_UPDATE_100_524288(32w0x30243f0b) update_3_2;
        T1_KEY_UPDATE_100_524288(32w0x30243f0b) update_3_3;
        T1_KEY_UPDATE_100_524288(32w0x30243f0b) update_3_4;
    // 

    T1_INIT_2( 4, 100, 262144)
    T2_INIT_4( 6, 100, 4096)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_7_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_8_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
    // 

    T2_INIT_HH_3(11, 100, 8192)
    MRAC_INIT_1(13, 100, 32768, 11, 16)
    MRAC_INIT_1(14, 100, 32768, 11, 16)
    UM_INIT_5(15, 100, 11, 32768)
    UM_INIT_3(16, 100, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_13_auto_sampling_hash_call.apply(DSTIP, ig_md.d_13_sampling_hash_16);

            d_15_auto_sampling_hash_call.apply(DSTIP, ig_md.d_15_sampling_hash_16);

            d_16_auto_sampling_hash_call.apply(DSTIP, ig_md.d_16_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        T1_RUN_1_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_4_KEY_1(3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_2_KEY_1( 4, DSTIP) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_4_KEY_1( 6, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_1(7, DSTIP, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_3_KEY_1(8, DSTIP, SIZE)
        // 

        T2_RUN_AFTER_3_KEY_1(11, DSTIP, 1)
        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(DSTIP, ig_md.d_13_index1_16);
            update_13_1.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        // MRAC for inst 14
            d_14_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_14_base_16);
            d_14_index_hash_call_1.apply(DSTIP, ig_md.d_14_index1_16);
            update_14_1.apply(ig_md.d_14_base_16, ig_md.d_14_index1_16);
        //

        // UnivMon for inst 15
            d_15_res_hash_call.apply(DSTIP, ig_md.d_15_res_hash); 
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16, ig_md.d_15_threshold); 
            d_15_index_hash_call_1.apply(DSTIP, ig_md.d_15_index1_16); 
            d_15_index_hash_call_2.apply(DSTIP, ig_md.d_15_index2_16); 
            d_15_index_hash_call_3.apply(DSTIP, ig_md.d_15_index3_16); 
            d_15_index_hash_call_4.apply(DSTIP, ig_md.d_15_index4_16); 
            d_15_index_hash_call_5.apply(DSTIP, ig_md.d_15_index5_16); 
            UM_RUN_END_5(15, ig_md.d_15_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(15) 
        //

        // UnivMon for inst 16
            d_16_res_hash_call.apply(DSTIP, ig_md.d_16_res_hash); 
            d_16_tcam_lpm.apply(ig_md.d_16_sampling_hash_16, ig_md.d_16_base_16, ig_md.d_16_threshold); 
            d_16_index_hash_call_1.apply(DSTIP, ig_md.d_16_index1_16); 
            d_16_index_hash_call_2.apply(DSTIP, ig_md.d_16_index2_16); 
            d_16_index_hash_call_3.apply(DSTIP, ig_md.d_16_index3_16); 
            UM_RUN_END_3(16, ig_md.d_16_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(16) 
        //

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip); 
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