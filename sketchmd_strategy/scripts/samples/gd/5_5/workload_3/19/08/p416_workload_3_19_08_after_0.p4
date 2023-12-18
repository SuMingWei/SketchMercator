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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 26624)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_3_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 100, 262144)
    T3_INIT_HH_2( 2, 100, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(3, 100)
        ABOVE_THRESHOLD_1() d_3_above_threshold;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_3_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_3_1;
    // 

    UM_INIT_3( 5, 200, 10, 16384)
    T2_INIT_HH_3( 7, 110, 4096)
    T2_INIT_HH_5( 6, 110, 8192)
    T1_INIT_4( 8, 110, 131072)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_10_above_threshold;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_9_3;
    //

    UM_INIT_5(11, 110, 11, 32768)
    T2_INIT_2(12, 220, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(13, 220)
        ABOVE_THRESHOLD_1() d_13_above_threshold;
        COMPUTE_HASH_220_16_11(32w0x30244f0b) d_13_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_13_1;
    // 

    T2_INIT_HH_1(16, 221, 16384)
    T2_INIT_HH_5(15, 221, 4096)
    UM_INIT_3(18, 221, 11, 32768)
    UM_INIT_3(19, 221, 10, 16384)
    UM_INIT_5(17, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_3_auto_sampling_hash_call.apply(SRCIP, ig_md.d_3_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_sampling_hash_16);

        //

        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_2_KEY_1( 2, SRCIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_3_res_hash_call.apply(SRCIP, ig_md.d_3_res_hash);
        d_3_tcam_lpm_2.apply(ig_md.d_3_sampling_hash_16, ig_md.d_3_base_16_1024, ig_md.d_3_base_16_2048, ig_md.d_3_threshold);
        d_3_index_hash_call_1.apply(SRCIP, ig_md.d_3_index1_16);
        update_3_1.apply(ig_md.d_3_base_16_2048, ig_md.d_3_index1_16, ig_md.d_3_res_hash[1:1], 1, ig_md.d_3_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(3)
        // 

        // UnivMon for inst 5
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_5_index2_16); 
            d_5_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_5_index3_16); 
            UM_RUN_END_3(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(5) 
        //

        T2_RUN_AFTER_3_KEY_2( 7, SRCIP, SRCPORT, 1)
        T2_RUN_AFTER_5_KEY_2( 6, SRCIP, SRCPORT, 1)
        T1_RUN_4_KEY_2( 8, DSTIP, DSTPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0 || ig_md.d_8_est1_4 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_9_1.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_1);
            update_9_2.apply(DSTIP, DSTPORT, 1, 1, ig_md.d_9_est_2);
            d_10_above_threshold.apply(ig_md.d_9_est_1, ig_md.d_9_est_2, ig_md.d_10_above_threshold);
            update_9_3.apply(DSTIP, DSTPORT, 1, ig_md.d_9_est_3);
        //

        // UnivMon for inst 11
            d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_11_index4_16); 
            d_11_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_11_index5_16); 
            UM_RUN_END_5(11, ig_md.d_11_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(11) 
        //

        T2_RUN_2_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_res_hash);
        d_13_tcam_lpm_2.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16_1024, ig_md.d_13_base_16_2048, ig_md.d_13_threshold);
        d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index1_16);
        update_13_1.apply(ig_md.d_13_base_16_2048, ig_md.d_13_index1_16, ig_md.d_13_res_hash[1:1], 1, ig_md.d_13_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(13)
        // 

        T2_RUN_AFTER_1_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        T2_RUN_AFTER_5_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index3_16); 
            UM_RUN_END_3(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(18) 
        //

        // UnivMon for inst 19
            d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index3_16); 
            UM_RUN_END_3(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(19) 
        //

        // UnivMon for inst 17
            d_17_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index2_16); 
            d_17_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index3_16); 
            d_17_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index4_16); 
            d_17_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_17_index5_16); 
            UM_RUN_END_5(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(17) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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