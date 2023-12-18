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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(16384, 14, 14336)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_11_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    T2_INIT_HH_1( 6, 100, 4096)
    T2_INIT_HH_1( 7, 100, 16384)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_4_res_hash_call;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_1;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_2;
        T3_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_3;
        T3_KEY_UPDATE_100_4096(32w0x30243f0b) update_4_4;
        T3_KEY_UPDATE_100_4096(32w0x30243f0b) update_4_5;
    //

    T2_INIT_HH_4( 5, 100, 4096)
    T3_INIT_HH_5( 3, 100, 4096)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(12, 100)
        ABOVE_THRESHOLD_4() d_12_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_12_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_12_1;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_12_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_12_2;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_12_index_hash_call_3;
        T3_INDEX_UPDATE_16384() update_12_3;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_12_index_hash_call_4;
        T3_INDEX_UPDATE_16384() update_12_4;
    // 


    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(11, 100)
        ABOVE_THRESHOLD_2() d_11_above_threshold;
        COMPUTE_HASH_100_16_10(32w0x30244f0b) d_11_index_hash_call_1;
        T3_T2_INDEX_UPDATE_16384() update_11_1;
        COMPUTE_HASH_100_16_11(32w0x30244f0b) d_11_index_hash_call_2;
        T3_T2_INDEX_UPDATE_32768() update_11_2;
    // 


    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_12_auto_sampling_hash_call.apply(SRCIP, ig_md.d_12_sampling_hash_16);

            d_11_auto_sampling_hash_call.apply(SRCIP, ig_md.d_11_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, SRCIP)
        T2_RUN_AFTER_1_KEY_1( 6, SRCIP, 1)
        T2_RUN_AFTER_1_KEY_1( 7, SRCIP, SIZE)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_4_res_hash_call.apply(SRCIP, ig_md.d_4_res_hash);
            update_4_1.apply(SRCIP, 1, ig_md.d_4_res_hash[1:1], SIZE, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, 1, ig_md.d_4_res_hash[2:2], SIZE, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, 1, ig_md.d_4_res_hash[3:3], SIZE, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, 1, ig_md.d_4_res_hash[4:4], ig_md.d_4_est_4);
            update_4_5.apply(SRCIP, 1, ig_md.d_4_res_hash[5:5], ig_md.d_4_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(4)
        //

        T2_RUN_AFTER_4_KEY_1( 5, SRCIP, 1)
        T3_RUN_AFTER_5_KEY_1( 3, SRCIP, 1)

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_12_res_hash_call.apply(SRCIP, ig_md.d_12_res_hash);
        d_12_tcam_lpm_2.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16_1024, ig_md.d_12_base_16_2048, ig_md.d_12_threshold);
        d_12_index_hash_call_1.apply(SRCIP, ig_md.d_12_index1_16);
        update_12_1.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index1_16, ig_md.d_12_res_hash[1:1], SIZE, ig_md.d_12_est_1);
        d_12_index_hash_call_2.apply(SRCIP, ig_md.d_12_index2_16);
        update_12_2.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index2_16, ig_md.d_12_res_hash[2:2], SIZE, ig_md.d_12_est_2);
        d_12_index_hash_call_3.apply(SRCIP, ig_md.d_12_index3_16);
        update_12_3.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index3_16, ig_md.d_12_res_hash[3:3], SIZE, ig_md.d_12_est_3);
        d_12_index_hash_call_4.apply(SRCIP, ig_md.d_12_index4_16);
        update_12_4.apply(ig_md.d_12_base_16_1024, ig_md.d_12_index4_16, ig_md.d_12_res_hash[4:4], SIZE, ig_md.d_12_est_4);
        RUN_HEAVY_FLOWKEY_NOIF_4(12)
        // 


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_11_res_hash_call.apply(SRCIP, ig_md.d_11_res_hash);
        d_11_tcam_lpm_2.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16_1024, ig_md.d_11_base_16_2048, ig_md.d_11_threshold);
        d_11_index_hash_call_1.apply(SRCIP, ig_md.d_11_index1_16);
        update_11_1.apply(ig_md.d_11_base_16_1024, ig_md.d_11_index1_16, ig_md.d_11_res_hash[1:1], 1, ig_md.d_11_est_1);
        d_11_index_hash_call_2.apply(SRCIP, ig_md.d_11_index2_16);
        update_11_2.apply(ig_md.d_11_base_16_2048, ig_md.d_11_index2_16, ig_md.d_11_res_hash[2:2], 1, ig_md.d_11_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(11)
        // 

        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
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