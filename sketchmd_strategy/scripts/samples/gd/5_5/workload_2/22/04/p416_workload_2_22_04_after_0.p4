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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_2( 3, 100, 262144)
    T1_INIT_4( 1, 100, 131072)
    T1_INIT_4( 2, 100, 262144)
    T4_INIT_1( 4, 100, 16384)
    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_5_tcam_lpm;
        T4_T4_KEY_UPDATE_100_16384(32w0x30243f0b) update_5_1;
    //

    MRB_INIT_1( 7, 100, 524288, 15, 16)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_14_above_threshold;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_14_1;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_14_2;
    //


    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_11_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_11_above_threshold;
    // 

    T2_INIT_HH_2(12, 100, 8192)

    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_8_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_8_above_threshold;
    // 

    T2_INIT_HH_3(13, 100, 8192)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_10_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_10_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_10_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_10_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_10_above_threshold;
    // 

    T2_INIT_HH_5(16, 100, 16384)

    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_8(32w0x30244f0b) d_19_sampling_hash_call;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_19_index_hash_call_1;
        LPM_OPT_MRAC_2() d_19_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_8192() update_19;
    // 


    // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row) 
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_20_sampling_hash_call;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_20_index_hash_call_1;
        LPM_OPT_MRAC_2() d_20_tcam_lpm_2;
        T2_T2_INDEX_UPDATE_32768() update_20;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_7_auto_sampling_hash_call.apply(SRCIP, ig_md.d_7_sampling_hash_16);

            d_4_auto_sampling_hash_call.apply(SRCIP, ig_md.d_4_sampling_hash_32);

            d_20_auto_sampling_hash_call.apply(SRCIP, ig_md.d_20_sampling_hash_16);

        //

        T1_RUN_2_KEY_1( 3, SRCIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 2, SRCIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        // HLL for inst 4
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_4_level);
            update_4.apply(SRCIP, ig_md.d_4_level);
        //

        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_5_tcam_lpm.apply(ig_md.d_4_sampling_hash_32, ig_md.d_5_level);
            update_5_1.apply(SRCIP, ig_md.d_5_level);
        //

        // MRB for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_32);
            d_7_index_hash_call_1.apply(SRCIP, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_32, ig_md.d_7_index1_16);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_14_1.apply(SRCIP, 1, 1, ig_md.d_14_est_1);
            update_14_2.apply(SRCIP, 1, ig_md.d_14_est_2);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_2(14)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_1(11, SRCIP, SIZE)
        // 

        T2_RUN_AFTER_2_KEY_1(12, SRCIP, SIZE)

        // apply O2
        T2_RUN_AFTER_3_KEY_1(8, SRCIP, 1)
        // 

        T2_RUN_AFTER_3_KEY_1(13, SRCIP, SIZE)

        // apply O2
        T2_RUN_AFTER_4_KEY_1(10, SRCIP, SIZE)
        // 

        T2_RUN_AFTER_5_KEY_1(16, SRCIP, 1)

        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_19_tcam_lpm_2.apply(ig_md.d_7_sampling_hash_16, ig_md.d_19_base_16_1024, ig_md.d_19_base_16_2048);
        d_19_index_hash_call_1.apply(SRCIP, ig_md.d_19_index1_16);
        update_19.apply(ig_md.d_19_base_16_1024, ig_md.d_19_index1_16);
        // 


        // apply SALUMerge; big - MRAC (1 row) / small - MRAC (1 row)
        d_20_tcam_lpm_2.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16_1024, ig_md.d_20_base_16_2048);
        d_20_index_hash_call_1.apply(SRCIP, ig_md.d_20_index1_16);
        update_20.apply(ig_md.d_20_base_16_2048, ig_md.d_20_index1_16);
        // 

        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_14_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip); 
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