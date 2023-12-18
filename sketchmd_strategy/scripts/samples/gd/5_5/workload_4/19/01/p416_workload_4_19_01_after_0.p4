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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

    //

    T1_INIT_2( 1, 100, 262144)
    MRAC_INIT_1( 2, 100, 16384, 10, 16)
    T2_INIT_HH_2( 3, 100, 4096)
    MRAC_INIT_1( 4, 100, 8192, 10,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_5_tcam_lpm;
        GET_BITMASK() d_5_get_bitmask;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_6_above_threshold;
        T2_T5_KEY_UPDATE_200_4096(32w0x30243f0b) update_5_1;
    //


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_7_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_7_above_threshold;
    // 

    T3_INIT_HH_5( 8, 110, 4096)
    T1_INIT_3(10, 110, 131072)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(11, 110)
        ABOVE_THRESHOLD_1() d_11_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_11_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_11_1;
    // 

    T2_INIT_HH_4(13, 220, 4096)

    // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row) 
        UM_INIT_SETUP(14, 220)
        ABOVE_THRESHOLD_1() d_14_above_threshold;
        COMPUTE_HASH_220_16_10(32w0x30244f0b) d_14_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_14_1;
    // 


    // apply O2
        T1_KEY_UPDATE_221_524288(32w0x30243f0b) update_16_1;
        T1_KEY_UPDATE_221_131072(32w0x30243f0b) update_16_2;
        T1_KEY_UPDATE_221_131072(32w0x30243f0b) update_16_3;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_3(100) d_19_above_threshold;
        T2_T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_19_1;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_19_2;
        T2_KEY_UPDATE_221_4096(32w0x30243f0b) update_19_3;
    //


    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, ig_md.d_2_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(DSTIP, ig_md.d_4_sampling_hash_16);

            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_32);

            d_11_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_sampling_hash_16);

            d_14_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // MRAC for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_16, ig_md.d_2_base_16);
            d_2_index_hash_call_1.apply(SRCIP, ig_md.d_2_index1_16);
            update_2.apply(ig_md.d_2_base_16, ig_md.d_2_index1_16);
        //

        T2_RUN_AFTER_2_KEY_1( 3, DSTIP, 1)
        // MRAC for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16);
            d_4_index_hash_call_1.apply(DSTIP, ig_md.d_4_index1_16);
            update_4.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_32, ig_md.d_5_level);
            d_5_get_bitmask.apply(ig_md.d_5_level, ig_md.d_5_bitmask);
            update_5_1.apply(SRCIP, DSTIP, 1, ig_md.d_5_bitmask, ig_md.d_5_est_1);
            d_6_above_threshold.apply(ig_md.d_5_est_1, ig_md.d_6_above_threshold);
        //


        // apply O2
        T2_RUN_AFTER_3_KEY_2(7, SRCIP, SRCPORT, 1)
        // 

        T3_RUN_AFTER_5_KEY_2( 8, SRCIP, SRCPORT, SIZE)
        T1_RUN_3_KEY_2(10, DSTIP, DSTPORT) if (ig_md.d_10_est1_1 == 0 || ig_md.d_10_est1_2 == 0 || ig_md.d_10_est1_3 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_11_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_11_res_hash);
        d_11_tcam_lpm_2.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16_1024, ig_md.d_11_base_16_2048, ig_md.d_11_threshold);
        d_11_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_11_index1_16);
        update_11_1.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index1_16, ig_md.d_11_res_hash[1:1], SIZE, ig_md.d_11_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(11)
        // 

        T2_RUN_AFTER_4_KEY_4(13, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - UnivMon (1 row)
        d_14_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_res_hash);
        d_14_tcam_lpm_2.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16_1024, ig_md.d_14_base_16_2048, ig_md.d_14_threshold);
        d_14_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_14_index1_16);
        update_14_1.apply(ig_md.d_14_base_16_1024, ig_md.d_14_index1_16, ig_md.d_14_res_hash[1:1], SIZE, ig_md.d_14_est_1);
        RUN_HEAVY_FLOWKEY_NOIF_1(14)
        // 


        // apply O2
        T1_RUN_3_KEY_5(16, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0) { /* process_new_flow() */ }
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_19_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_19_est_1);
            update_19_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_19_est_2);
            update_19_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_19_est_3);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_3(19)
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
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