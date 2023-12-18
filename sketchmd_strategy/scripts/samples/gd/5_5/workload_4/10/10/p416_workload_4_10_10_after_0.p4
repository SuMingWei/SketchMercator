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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_110(4096, 12, 2048)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_7_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_10_auto_sampling_hash_call;

    //

    MRAC_INIT_1( 1, 100, 8192, 10,  8)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_3_tcam_lpm;
        GET_BITMASK() d_3_get_bitmask;
        T5_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_4;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_3_5;
    //

    T1_INIT_2( 4, 110, 131072)

    // apply O2
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_5_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_5_above_threshold;
    // 

    MRAC_INIT_1( 7, 110, 32768, 11, 16)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_1;
        T2_T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_221_16384(32w0x30243f0b) update_8_5;
    //

    MRAC_INIT_1(10, 221, 16384, 10, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_110(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_16);

            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_32);

            d_7_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_7_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_sampling_hash_16);

        //

        // MRAC for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_16, ig_md.d_1_base_16);
            d_1_index_hash_call_1.apply(SRCIP, ig_md.d_1_index1_16);
            update_1.apply(ig_md.d_1_base_16, ig_md.d_1_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            d_3_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_3_level);
            d_3_get_bitmask.apply(ig_md.d_3_level, ig_md.d_3_bitmask);
            update_3_1.apply(DSTIP, SIZE, ig_md.d_3_bitmask, ig_md.d_3_est_1);
            update_3_2.apply(DSTIP, 1, ig_md.d_3_est_2);
            update_3_3.apply(DSTIP, 1, ig_md.d_3_est_3);
            update_3_4.apply(DSTIP, 1, ig_md.d_3_est_4);
            update_3_5.apply(DSTIP, 1, ig_md.d_3_est_5);
        //

        T1_RUN_2_KEY_2( 4, SRCIP, SRCPORT) if (ig_md.d_4_est1_1 == 0 || ig_md.d_4_est1_2 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_3_KEY_2(5, DSTIP, DSTPORT, 1)
        // 

        // MRAC for inst 7
            d_7_tcam_lpm.apply(ig_md.d_7_sampling_hash_16, ig_md.d_7_base_16);
            d_7_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_7_index1_16);
            update_7.apply(ig_md.d_7_base_16, ig_md.d_7_index1_16);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_8_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, 1, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_8_est_4);
            update_8_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE, ig_md.d_8_est_5);
        //

        // MRAC for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_16, ig_md.d_10_base_16);
            d_10_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_index1_16);
            update_10.apply(ig_md.d_10_base_16, ig_md.d_10_index1_16);
        //

        if(ig_md.d_5_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, DSTIP, DSTPORT);
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