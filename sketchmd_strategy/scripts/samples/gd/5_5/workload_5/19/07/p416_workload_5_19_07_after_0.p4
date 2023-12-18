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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

    //

    T1_INIT_3( 1, 100, 262144)
    T2_INIT_HH_3( 2, 100, 8192)
    T2_INIT_2( 3, 100, 4096)
    UM_INIT_3( 4, 100, 11, 32768)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_6_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_7_above_threshold;
        T3_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_1;
        T3_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_3;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_res_hash_call;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_5_1;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_5_2;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_5_3;
        T3_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_5_4;
    //

    T1_INIT_1( 9, 110, 262144)
    T2_INIT_HH_3(12, 220, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_11_1;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_11_2;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_11_3;
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_11_5;
    //

    UM_INIT_2(13, 220, 10, 16384)
    T1_INIT_1(14, 221, 262144)

    // apply O2
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_15_1;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_15_2;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_15_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_15_above_threshold;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(19, 221)
        ABOVE_THRESHOLD_5() d_19_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_19_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_19_1;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_19_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_19_2;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_19_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_19_3;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_19_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_19_4;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_19_index_hash_call_5;
        T3_INDEX_UPDATE_32768() update_19_5;
    // 

    UM_INIT_5(18, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_sampling_hash_16);

        //

        T1_RUN_3_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0) { /* process_new_flow() */ }
        T2_RUN_AFTER_3_KEY_1( 2, SRCIP, SIZE)
        T2_RUN_2_KEY_1( 3, DSTIP, SIZE)
        // UnivMon for inst 4
            d_4_res_hash_call.apply(DSTIP, ig_md.d_4_res_hash); 
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16, ig_md.d_4_threshold); 
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16); 
            d_4_index_hash_call_2.apply(DSTIP, ig_md.d_4_index2_16); 
            d_4_index_hash_call_3.apply(DSTIP, ig_md.d_4_index3_16); 
            UM_RUN_END_3(4, ig_md.d_4_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_3(4) 
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_6_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_6_res_hash);
            update_6_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_res_hash[1:1], SIZE, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_res_hash[2:2], SIZE, ig_md.d_6_est_2);
            d_7_above_threshold.apply(ig_md.d_6_est_1, ig_md.d_6_est_2, ig_md.d_7_above_threshold);
            update_6_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_6_est_3);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_res_hash);
            update_5_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[1:1], SIZE, ig_md.d_5_est_1);
            update_5_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[2:2], SIZE, ig_md.d_5_est_2);
            update_5_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[3:3], SIZE, ig_md.d_5_est_3);
            update_5_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_5_res_hash[4:4], SIZE, ig_md.d_5_est_4);
            d_8_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_5_est_2, ig_md.d_5_est_3, ig_md.d_5_est_4, ig_md.d_8_above_threshold);
        //

        T1_RUN_1_KEY_2( 9, SRCIP, SRCPORT)
        T2_RUN_AFTER_3_KEY_4(12, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_11_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, SIZE, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, SIZE, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, SIZE, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, SIZE, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_11_est_5);
        //

        // UnivMon for inst 13
            d_13_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_res_hash); 
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16, ig_md.d_13_threshold); 
            d_13_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index1_16); 
            d_13_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_13_index2_16); 
            UM_RUN_END_2(13, ig_md.d_13_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_2(13) 
        //

        T1_RUN_1_KEY_5(14, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_14_est1_1 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_3_KEY_5(15, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_19_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_res_hash);
        d_19_tcam_lpm_2.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16_1024, ig_md.d_19_base_16_2048, ig_md.d_19_threshold);
        d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index1_16);
        update_19_1.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index1_16, ig_md.d_19_res_hash[1:1], SIZE, ig_md.d_19_est_1);
        d_19_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index2_16);
        update_19_2.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index2_16, ig_md.d_19_res_hash[2:2], SIZE, ig_md.d_19_est_2);
        d_19_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index3_16);
        update_19_3.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index3_16, ig_md.d_19_res_hash[3:3], SIZE, ig_md.d_19_est_3);
        d_19_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index4_16);
        update_19_4.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index4_16, ig_md.d_19_res_hash[4:4], SIZE, ig_md.d_19_est_4);
        d_19_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index5_16);
        update_19_5.apply(ig_md.d_19_base_16_2048, ig_md.d_19_index5_16, ig_md.d_19_res_hash[5:5], SIZE, ig_md.d_19_est_5);
        RUN_HEAVY_FLOWKEY_NOIF_5(19)
        // 

        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index3_16); 
            d_18_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index4_16); 
            d_18_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_18_index5_16); 
            UM_RUN_END_5(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(18) 
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_15_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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