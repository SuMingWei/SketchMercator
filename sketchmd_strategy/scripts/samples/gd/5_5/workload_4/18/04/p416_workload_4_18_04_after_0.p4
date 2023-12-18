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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T2_INIT_3( 1, 100, 4096)
    UM_INIT_5( 2, 100, 11, 32768)
    T1_INIT_5( 3, 100, 524288)
    T4_INIT_1( 4, 100, 65536)
    T2_INIT_5( 5, 100, 8192)
    MRAC_INIT_1( 6, 100, 16384, 10, 16)

    // apply O2
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_7_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_7_above_threshold;
    // 

    T3_INIT_HH_4( 8, 200, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(11, 200)
        ABOVE_THRESHOLD_4() d_11_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_11_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_11_1;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_11_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_11_2;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_11_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_11_3;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_11_index_hash_call_4;
        T3_INDEX_UPDATE_32768() update_11_4;
    // 

    UM_INIT_4(12, 110, 10, 16384)
    T1_INIT_4(13, 110, 524288)
    T4_INIT_1(14, 110, 16384)
    T2_INIT_4(15, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_17_above_threshold;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_1;
        T2_T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_2;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_3;
        T2_KEY_UPDATE_220_16384(32w0x30243f0b) update_16_4;
    //

    T2_INIT_HH_4(18, 221, 8192)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_32);

            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_16);

            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_14_sampling_hash_32);

        //

        T2_RUN_3_KEY_1( 1, SRCIP, 1)
        // UnivMon for inst 2
            d_2_res_hash_call.apply(SRCIP, ig_md.d_2_res_hash); 
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16, ig_md.d_2_threshold); 
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16); 
            d_2_index_hash_call_2.apply(SRCIP, ig_md.d_2_index2_16); 
            d_2_index_hash_call_3.apply(SRCIP, ig_md.d_2_index3_16); 
            d_2_index_hash_call_4.apply(SRCIP, ig_md.d_2_index4_16); 
            d_2_index_hash_call_5.apply(SRCIP, ig_md.d_2_index5_16); 
            UM_RUN_END_5(2, ig_md.d_2_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(2) 
        //

        T1_RUN_5_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(DSTIP, ig_md.d_4_level);
        //

        T2_RUN_5_KEY_1( 5, DSTIP, 1)
        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //


        // apply O2
        T2_RUN_AFTER_4_KEY_2(7, SRCIP, DSTIP, 1)
        // 

        T3_RUN_AFTER_4_KEY_2( 8, SRCIP, DSTIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_11_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_res_hash);
        d_11_tcam_lpm_2.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16_1024, ig_md.d_11_base_16_2048, ig_md.d_11_threshold);
        d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16);
        update_11_1.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index1_16, ig_md.d_11_res_hash[1:1], SIZE, ig_md.d_11_est_1);
        d_11_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_11_index2_16);
        update_11_2.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index2_16, ig_md.d_11_res_hash[2:2], SIZE, ig_md.d_11_est_2);
        d_11_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_11_index3_16);
        update_11_3.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index3_16, ig_md.d_11_res_hash[3:3], SIZE, ig_md.d_11_est_3);
        d_11_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_11_index4_16);
        update_11_4.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index4_16, ig_md.d_11_res_hash[4:4], SIZE, ig_md.d_11_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(11)
        // 

        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_12_index1_16); 
            d_12_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_12_index2_16); 
            d_12_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_12_index3_16); 
            d_12_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_12_index4_16); 
            UM_RUN_END_4(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(12) 
        //

        T1_RUN_4_KEY_2(13, DSTIP, DSTPORT) if (ig_md.d_13_est1_1 == 0 || ig_md.d_13_est1_2 == 0 || ig_md.d_13_est1_3 == 0 || ig_md.d_13_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_32, ig_md.d_14_level);
            update_14.apply(DSTIP, DSTPORT, ig_md.d_14_level);
        //

        T2_RUN_4_KEY_2(15, DSTIP, DSTPORT, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_16_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_16_est_1);
            update_16_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_16_est_2);
            d_17_above_threshold.apply(ig_md.d_16_est_1, ig_md.d_16_est_2, ig_md.d_17_above_threshold);
            update_16_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_16_est_3);
            update_16_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_16_est_4);
        //

        T2_RUN_AFTER_4_KEY_5(18, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_17_above_threshold == 1
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
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
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