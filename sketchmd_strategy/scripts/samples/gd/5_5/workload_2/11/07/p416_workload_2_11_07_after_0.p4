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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_9_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_100_262144(32w0x30243f0b) update_1_1;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_2;
        T1_KEY_UPDATE_100_131072(32w0x30243f0b) update_1_3;
    // 

    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        T4_T4_KEY_UPDATE_100_65536(32w0x30243f0b) update_2_1;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_5_5;
    //

    T2_INIT_HH_3( 8, 100, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(9, 100)
        ABOVE_THRESHOLD_1() d_9_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_9_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_9_1;
    // 

    UM_INIT_5(11, 100, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_32);

            d_9_auto_sampling_hash_call.apply(DSTIP, ig_md.d_9_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(DSTIP, ig_md.d_11_sampling_hash_16);

        //


        // apply O2
        T1_RUN_3_KEY_1(1, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        // 

        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2_1.apply(DSTIP, ig_md.d_2_level);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(DSTIP, ig_md.d_5_res_hash);
            update_5_1.apply(DSTIP, 1, 1, ig_md.d_5_est_1);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_6_above_threshold);
            update_5_2.apply(DSTIP, SIZE, ig_md.d_5_res_hash[2:2], 1, ig_md.d_5_est_2);
            update_5_3.apply(DSTIP, SIZE, ig_md.d_5_res_hash[3:3], 1, ig_md.d_5_est_3);
            update_5_4.apply(DSTIP, SIZE, ig_md.d_5_res_hash[4:4], 1, ig_md.d_5_est_4);
            d_7_above_threshold.apply(ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_est_4, ig_md.d_7_above_threshold);
            update_5_5.apply(DSTIP, SIZE, ig_md.d_5_est_5);
        //

        T2_RUN_AFTER_3_KEY_1( 8, DSTIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_9_res_hash_call.apply(DSTIP, ig_md.d_9_res_hash);
        d_9_tcam_lpm_2.apply(ig_md.d_9_sampling_hash_16, ig_md.d_9_base_16_1024, ig_md.d_9_base_16_2048, ig_md.d_9_threshold);
        d_9_index_hash_call_1.apply(DSTIP, ig_md.d_9_index1_16);
        update_9_1.apply(ig_md.d_9_base_16_2048, ig_md.d_9_index1_16, ig_md.d_9_res_hash[1:1], 1, ig_md.d_9_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(9)
        // 

        // UnivMon for inst 11
            d_11_res_hash_call.apply(DSTIP, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(DSTIP, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(DSTIP, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(DSTIP, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(DSTIP, ig_md.d_11_index4_16); 
            d_11_index_hash_call_5.apply(DSTIP, ig_md.d_11_index5_16); 
            UM_RUN_END_5(11, ig_md.d_11_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(11) 
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
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