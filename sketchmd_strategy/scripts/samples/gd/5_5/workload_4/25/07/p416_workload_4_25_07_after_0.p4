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
    METADATA_DIM(25)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 24576)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_23_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 100, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_5;
    //

    T3_INIT_HH_3( 4, 100, 8192)
    MRAC_INIT_1( 5, 100, 16384, 11,  8)
    T1_INIT_3( 6, 200, 262144)
    T2_INIT_HH_3( 7, 200, 8192)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(8, 200)
        ABOVE_THRESHOLD_1() d_8_above_threshold;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_8_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_8_1;
    // 

    T4_INIT_1(10, 110, 65536)
    T3_INIT_HH_2(12, 110, 8192)
    T2_INIT_HH_3(11, 110, 8192)
    MRAC_INIT_1(13, 110, 16384, 11,  8)
    T1_INIT_1(14, 110, 524288)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_2;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_3;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_15_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_15_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_3;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_4;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_16_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_16_above_threshold;
    // 

    T1_INIT_3(20, 220, 524288)
    T2_INIT_1(21, 220, 16384)
    UM_INIT_4(22, 220, 11, 32768)
    MRB_INIT_1(23, 221, 131072, 14,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_1(100) d_25_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_24_1;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_2;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_24_3;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(DSTIP, ig_md.d_5_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_32);

            d_13_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_13_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_sampling_hash_16);

            d_23_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_sampling_hash_16);

        //

        T1_RUN_5_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(SRCIP, 1, SIZE, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, 1, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, 1, ig_md.d_3_est_4);
            update_3_5.apply(SRCIP, 1, ig_md.d_3_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(3)
        //

        T3_RUN_AFTER_3_KEY_1( 4, DSTIP, 1)
        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        T1_RUN_3_KEY_2( 6, SRCIP, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_2( 7, SRCIP, DSTIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_8_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_8_res_hash);
        d_8_tcam_lpm_2.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16_1024, ig_md.d_8_base_16_2048, ig_md.d_8_threshold);
        d_8_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_8_index1_16);
        update_8_1.apply(ig_md.d_8_base_16_1024, ig_md.d_8_index1_16, ig_md.d_8_res_hash[1:1], SIZE, ig_md.d_8_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(8)
        // 

        // HLL for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
            update_10.apply(SRCIP, SRCPORT, ig_md.d_10_level);
        //

        T3_RUN_AFTER_2_KEY_2(12, SRCIP, SRCPORT, SIZE)
        T2_RUN_AFTER_3_KEY_2(11, SRCIP, SRCPORT, 1)
        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        T1_RUN_1_KEY_2(14, DSTIP, DSTPORT)

        // apply O2
        T2_RUN_AFTER_4_KEY_2(15, DSTIP, DSTPORT, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(16, DSTIP, DSTPORT, 1)
        // 

        T1_RUN_3_KEY_4(20, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0 || ig_md.d_20_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // UnivMon for inst 22
            d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index2_16); 
            d_22_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index3_16); 
            d_22_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index4_16); 
            UM_RUN_END_4(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(22) 
        //

        // MRB for inst 23
            d_23_tcam_lpm.apply(ig_md.d_23_sampling_hash_16, ig_md.d_23_base_32);
            d_23_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_23_index1_16);
            update_23.apply(ig_md.d_23_base_32, ig_md.d_23_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_24_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_24_est_1);
            d_25_above_threshold.apply(ig_md.d_24_est_1, ig_md.d_25_above_threshold);
            update_24_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_24_est_2);
            update_24_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_24_est_3);
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_25_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
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