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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(8192, 13, 6144)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_6_auto_sampling_hash_call;

    //

    T2_INIT_3( 1, 200, 4096)
    // apply SALUMerge; HLL (row1) - HLL (row1) 
        TCAM_LPM_HLLPCSA() d_2_tcam_lpm;
        T4_T4_KEY_UPDATE_110_65536(32w0x30243f0b) update_2_1;
    //

    T2_INIT_5( 4, 110, 8192)
    UM_INIT_5( 5, 110, 10, 16384)
    T5_INIT_1( 6, 220, 8192)
    T1_INIT_1( 7, 221, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_9_above_threshold;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_9_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_9_2;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_9_3;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_9_4;
        T2_KEY_UPDATE_221_8192(32w0x30243f0b) update_9_5;
    //

    T2_INIT_HH_3(10, 221, 4096)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_2_sampling_hash_32);

            d_5_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_sampling_hash_16);

            d_6_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_sampling_hash_32);

        //

        T2_RUN_3_KEY_2( 1, SRCIP, DSTIP, 1)
        // apply SALUMerge; HLL (row1) - HLL (row1)  
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2_1.apply(SRCIP, SRCPORT, ig_md.d_2_level);
        //

        T2_RUN_5_KEY_2( 4, SRCIP, SRCPORT, SIZE)
        // UnivMon for inst 5
            d_5_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_5_res_hash); 
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
            d_5_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_5_index1_16); 
            d_5_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_5_index2_16); 
            d_5_index_hash_call_3.apply(DSTIP, DSTPORT, ig_md.d_5_index3_16); 
            d_5_index_hash_call_4.apply(DSTIP, DSTPORT, ig_md.d_5_index4_16); 
            d_5_index_hash_call_5.apply(DSTIP, DSTPORT, ig_md.d_5_index5_16); 
            UM_RUN_END_5(5, ig_md.d_5_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(5) 
        //

        // PCSA for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_6_level);
            d_6_get_bitmask.apply(ig_md.d_6_level, ig_md.d_6_bitmask);
            update_6.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_6_bitmask);
        //

        T1_RUN_1_KEY_5( 7, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_9_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_9_est_1);
            update_9_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, SIZE, ig_md.d_9_est_2);
            update_9_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_9_est_3);
            update_9_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_9_est_4);
            update_9_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1, ig_md.d_9_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(9)
        //

        T2_RUN_AFTER_3_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_5_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
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