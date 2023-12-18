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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_210(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_13_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 65536)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_3_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_5;
    //


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_8(32w0x30244f0b) d_4_sampling_hash_call;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_4_index_hash_call_1;
        LPM_OPT_MRAC_2() d_4_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_16384() update_4;
    // 

    T2_INIT_1( 6, 100, 16384)
    UM_INIT_2( 7, 100, 11, 32768)
    UM_INIT_3( 8, 100, 11, 32768)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(10, 110)
        ABOVE_THRESHOLD_2() d_10_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_10_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_10_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_10_2;
    // 

    UM_INIT_4(11, 110, 11, 32768)
    T1_INIT_2(12, 110, 524288)
    MRAC_INIT_1(13, 110, 16384, 11,  8)
    MRB_INIT_1(14, 220, 524288, 15, 16)
    T2_INIT_3(15, 220, 4096)
    MRAC_INIT_1(16, 220, 16384, 10, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_18_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_18_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_18_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_18_4;
    //

    MRAC_INIT_1(19, 221, 8192, 10,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_16);

            d_7_auto_sampling_hash_call.apply(DSTIP, ig_md.d_7_sampling_hash_16);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_sampling_hash_16);

            d_13_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_13_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1.apply(SRCIP, ig_md.d_1_level);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_3_1.apply(SRCIP, 1, SIZE, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, 1, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, 1, ig_md.d_3_est_3);
            update_3_4.apply(SRCIP, 1, ig_md.d_3_est_4);
            update_3_5.apply(SRCIP, 1, ig_md.d_3_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(3)
        //


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_4_tcam_lpm_2.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16_1024, ig_md.d_4_base_16_2048);
        d_4_index_hash_call_1.apply(SRCIP, ig_md.d_4_index1_16);
        update_4.apply(ig_md.d_4_base_16_2048, ig_md.d_4_index1_16);
        // 

        T2_RUN_1_KEY_1( 6, DSTIP, SIZE)
        // UnivMon for inst 7
            d_7_res_hash_call.apply(DSTIP, ig_md.d_7_res_hash); 
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16, ig_md.d_7_threshold); 
            d_7_index_hash_call_1.apply(DSTIP, ig_md.d_7_index1_16); 
            d_7_index_hash_call_2.apply(DSTIP, ig_md.d_7_index2_16); 
            UM_RUN_END_2(7, ig_md.d_7_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(7) 
        //

        // UnivMon for inst 8
            d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(DSTIP, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(DSTIP, ig_md.d_8_index3_16); 
            UM_RUN_END_3(8, ig_md.d_8_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_3(8) 
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_10_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_10_res_hash);
        d_10_tcam_lpm_2.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16_1024, ig_md.d_10_base_16_2048, ig_md.d_10_threshold);
        d_10_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_10_index1_16);
        update_10_1.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index1_16, ig_md.d_10_res_hash[1:1], 1, ig_md.d_10_est_1);
        d_10_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_10_index2_16);
        update_10_2.apply(ig_md.d_10_base_16_2048, ig_md.d_10_index2_16, ig_md.d_10_res_hash[2:2], 1, ig_md.d_10_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(10)
        // 

        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_11_index4_16); 
            UM_RUN_END_4(11, ig_md.d_11_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_4(11) 
        //

        T1_RUN_2_KEY_2(12, DSTIP, DSTPORT) if (ig_md.d_12_est1_1 == 0 || ig_md.d_12_est1_2 == 0) { /* process_new_flow() */ }
        // MRAC for inst 13
            d_13_tcam_lpm.apply(ig_md.d_13_sampling_hash_16, ig_md.d_13_base_16);
            d_13_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_13_index1_16);
            update_13.apply(ig_md.d_13_base_16, ig_md.d_13_index1_16);
        //

        // MRB for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_32);
            d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
            update_14.apply(ig_md.d_14_base_32, ig_md.d_14_index1_16);
        //

        T2_RUN_3_KEY_4(15, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_16_index1_16);
            update_16.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_18_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_18_est_1);
            update_18_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_18_est_2);
            update_18_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_18_est_3);
            update_18_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_18_est_4);
        //

        // MRAC for inst 19
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16);
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_19_index1_16);
            update_19.apply(ig_md.d_19_base_16, ig_md.d_19_index1_16);
        //

        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport); 
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