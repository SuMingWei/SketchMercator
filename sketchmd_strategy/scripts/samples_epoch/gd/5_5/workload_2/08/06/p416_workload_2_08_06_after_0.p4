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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(8192, 13, 2048)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //

    T1_INIT_5( 1, 100, 262144)
    T4_INIT_1( 2, 100, 4096)
    T4_INIT_1( 3, 100, 16384)
    T5_INIT_1( 4, 100, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_1;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_2;
        T2_T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_100_4096(32w0x30243f0b) update_6_5;
    //

    T2_INIT_1( 7, 100, 8192)
    UM_INIT_4( 8, 100, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(DSTIP, ig_md.d_8_sampling_hash_16);

        //

        T1_RUN_5_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0 || ig_md.d_1_est1_3 == 0 || ig_md.d_1_est1_4 == 0 || ig_md.d_1_est1_5 == 0) { /* process_new_flow() */ }
        // HLL for inst 2
            d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
            update_2_1.apply(DSTIP, ig_md.d_2_level);
        //

        // HLL for inst 3
            d_3_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_3_level);
            update_3_1.apply(DSTIP, ig_md.d_3_level);
        //

        // PCSA for inst 4
            d_4_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_4_level);
            d_4_get_bitmask.apply(ig_md.d_4_level, ig_md.d_4_bitmask);
            update_4_1.apply(DSTIP, ig_md.d_4_bitmask);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_6_1.apply(DSTIP, 1, SIZE, ig_md.d_6_est_1);
            update_6_2.apply(DSTIP, 1, SIZE, ig_md.d_6_est_2);
            update_6_3.apply(DSTIP, 1, SIZE, ig_md.d_6_est_3);
            update_6_4.apply(DSTIP, 1, ig_md.d_6_est_4);
            update_6_5.apply(DSTIP, 1, ig_md.d_6_est_5);
        //

        T2_RUN_1_KEY_1( 7, DSTIP, SIZE)
        // UnivMon for inst 8
            d_8_res_hash_call.apply(DSTIP, ig_md.d_8_res_hash); 
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_16, ig_md.d_8_threshold); 
            d_8_index_hash_call_1.apply(DSTIP, ig_md.d_8_index1_16); 
            d_8_index_hash_call_2.apply(DSTIP, ig_md.d_8_index2_16); 
            d_8_index_hash_call_3.apply(DSTIP, ig_md.d_8_index3_16); 
            d_8_index_hash_call_4.apply(DSTIP, ig_md.d_8_index4_16); 
            UM_RUN_END_4(8, ig_md.d_8_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(8) 
        //

        if(ig_md.d_8_above_threshold == 1) {
            heavy_flowkey_storage.apply(ig_dprsr_md, DSTIP);
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