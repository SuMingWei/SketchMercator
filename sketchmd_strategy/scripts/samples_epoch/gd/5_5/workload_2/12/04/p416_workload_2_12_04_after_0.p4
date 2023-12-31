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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(32768, 15, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_110_131072(32w0x30243f0b) update_1_1;
        T1_KEY_UPDATE_110_131072(32w0x30243f0b) update_1_2;
    // 

    T1_INIT_1( 2, 110, 524288)
    T4_INIT_1( 3, 110, 4096)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_7_above_threshold;
        T3_T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_5_4;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_6_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_8_above_threshold;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_3;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_6_5;
    //

    T2_INIT_HH_5(10, 110, 4096)
    MRAC_INIT_1(11, 110, 16384, 11,  8)
    UM_INIT_3(12, 110, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_3_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

        //


        // apply O2
        T1_RUN_2_KEY_2(1, SRCIP, SRCPORT) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // 

        T1_RUN_1_KEY_2( 2, SRCIP, SRCPORT) if (ig_md.d_2_est1_1 == 0) { /* process_new_flow() */ }
        // HLL for inst 3
            d_3_tcam_lpm.apply(ig_md.d_3_sampling_hash_32, ig_md.d_3_level);
            update_3_1.apply(SRCIP, SRCPORT, ig_md.d_3_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, SRCPORT, 1, ig_md.d_5_res_hash[0:0], 1, ig_md.d_5_est_1);
            d_7_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_7_above_threshold);
            update_5_2.apply(SRCIP, SRCPORT, 1, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, SRCPORT, 1, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, SRCPORT, 1, ig_md.d_5_est_4);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_6_res_hash);
            update_6_1.apply(SRCIP, SRCPORT, SIZE, ig_md.d_6_res_hash[0:0], SIZE, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, SRCPORT, SIZE, ig_md.d_6_res_hash[1:1], SIZE, ig_md.d_6_est_2);
            d_8_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_8_above_threshold);
            update_6_3.apply(SRCIP, SRCPORT, 1, SIZE, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, SRCPORT, 1, SIZE, ig_md.d_6_est_4);
            d_9_above_threshold.apply(ig_md.d_6_est_3, ig_md.d_6_est_4, ig_md.d_9_above_threshold);
            update_6_5.apply(SRCIP, SRCPORT, 1, ig_md.d_6_est_5);
        //

        T2_RUN_AFTER_5_KEY_2(10, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16);
            update_11_1.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_12_index3_16); 
            UM_RUN_END_3(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(12) 
        //

        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_srcport); 
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