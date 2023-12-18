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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(16384, 14, 8192)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

    //

    T1_INIT_4( 1, 200, 262144)
    T1_INIT_4( 2, 200, 524288)
    T1_INIT_5( 3, 200, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_3;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_4;
        T2_T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_6_5;
    //

    T2_INIT_HH_4( 8, 200, 16384)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(12, 200)
        ABOVE_THRESHOLD_2() d_12_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_12_1;
        COMPUTE_HASH_200_16_10(32w0x30244f0b) d_12_index_hash_call_2;
        T3_T2_INDEX_UPDATE_16384() update_12_2;
    // 

    UM_INIT_4(11, 200, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_sampling_hash_16);

        //

        T1_RUN_4_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_2( 2, SRCIP, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_5_KEY_2( 3, SRCIP, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0 || ig_md.d_3_est1_5 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_6_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_6_est_1);
            update_6_2.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_6_est_2);
            update_6_3.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_6_est_3);
            update_6_4.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_6_est_4);
            update_6_5.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_6_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(6)
        //

        T2_RUN_AFTER_4_KEY_2( 8, SRCIP, DSTIP, SIZE)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_12_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_2048, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], SIZE, ig_md.d_12_est_1);
        d_12_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_12_index2_16);
        update_12_2.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index2_16, ig_md.d_12_res_hash[2:2], SIZE, ig_md.d_12_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(12)
        // 

        // UnivMon for inst 11
            d_11_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_11_res_hash); 
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16, ig_md.d_11_threshold); 
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16); 
            d_11_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_11_index2_16); 
            d_11_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_11_index3_16); 
            d_11_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_11_index4_16); 
            UM_RUN_END_4(11, ig_md.d_11_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(11) 
        //

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip); 
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