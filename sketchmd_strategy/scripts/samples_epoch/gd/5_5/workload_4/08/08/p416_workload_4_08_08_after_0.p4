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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(16384, 14, 4096)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x30244f0b) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_8_auto_sampling_hash_call;

    //

    T4_INIT_1( 1, 100, 4096)
    T2_INIT_HH_4( 2, 100, 16384)
    T2_INIT_HH_4( 3, 200, 16384)
    T1_INIT_1( 4, 110, 131072)

    // apply O2
        T1_KEY_UPDATE_220_524288(32w0x30243f0b) update_5_1;
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_5_2;
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_5_3;
    // 

    T2_INIT_3( 7, 220, 16384)
    MRB_INIT_1( 8, 221, 524288, 15, 16)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

            d_8_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_sampling_hash_16);

        //

        // HLL for inst 1
            d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
            update_1_1.apply(SRCIP, ig_md.d_1_level);
        //

        T2_RUN_AFTER_4_KEY_1( 2, SRCIP, SIZE)
        T2_RUN_AFTER_4_KEY_2( 3, SRCIP, DSTIP, SIZE)
        T1_RUN_1_KEY_2( 4, DSTIP, DSTPORT) if (ig_md.d_4_est1_1 == 0) { /* process_new_flow() */ }

        // apply O2
        T1_RUN_3_KEY_4(5, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_5_est1_1 == 0 || ig_md.d_5_est1_2 == 0 || ig_md.d_5_est1_3 == 0) { /* process_new_flow() */ }
        // 

        T2_RUN_3_KEY_4( 7, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRB for inst 8
            d_8_tcam_lpm.apply(ig_md.d_8_sampling_hash_16, ig_md.d_8_base_32);
            d_8_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_8_index1_16);
            update_8_1.apply(ig_md.d_8_base_32, ig_md.d_8_index1_16);
        //

        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_3_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
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