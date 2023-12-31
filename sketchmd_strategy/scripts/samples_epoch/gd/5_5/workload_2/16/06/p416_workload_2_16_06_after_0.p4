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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_100(65536, 16, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 100, 262144)
    T1_INIT_4( 2, 100, 131072)
    T1_INIT_4( 3, 100, 131072)
    T3_INIT_HH_4( 9, 100, 16384)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_4_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_3;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_5_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_5_above_threshold;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_7_above_threshold;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_1;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_2;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_3;
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_4;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_7_5;
    //

    T2_INIT_HH_2(11, 100, 16384)
    T2_INIT_HH_2(13, 100, 8192)
    T2_INIT_HH_2(14, 100, 8192)
    MRAC_INIT_1(15, 100, 32768, 11, 16)
    MRAC_INIT_1(16, 100, 16384, 11,  8)

    HEAVY_FLOWKEY_STORAGE_CONFIG_100(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_15_auto_sampling_hash_call.apply(DSTIP, ig_md.d_15_sampling_hash_16);

        //

        T1_RUN_1_KEY_1( 1, DSTIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 2, DSTIP) if (ig_md.d_2_est1_1 == 0 || ig_md.d_2_est1_2 == 0 || ig_md.d_2_est1_3 == 0 || ig_md.d_2_est1_4 == 0) { /* process_new_flow() */ }
        T1_RUN_4_KEY_1( 3, DSTIP) if (ig_md.d_3_est1_1 == 0 || ig_md.d_3_est1_2 == 0 || ig_md.d_3_est1_3 == 0 || ig_md.d_3_est1_4 == 0) { /* process_new_flow() */ }
        T3_RUN_AFTER_4_KEY_1( 9, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_5_KEY_1(4, DSTIP, 1)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_1(5, DSTIP, SIZE)
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_7_1.apply(DSTIP, 1, SIZE, ig_md.d_7_est_1);
            update_7_2.apply(DSTIP, 1, SIZE, ig_md.d_7_est_2);
            update_7_3.apply(DSTIP, 1, SIZE, ig_md.d_7_est_3);
            update_7_4.apply(DSTIP, 1, SIZE, ig_md.d_7_est_4);
            update_7_5.apply(DSTIP, 1, ig_md.d_7_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(7)
        //

        T2_RUN_AFTER_2_KEY_1(11, DSTIP, 1)
        T2_RUN_AFTER_2_KEY_1(13, DSTIP, SIZE)
        T2_RUN_AFTER_2_KEY_1(14, DSTIP, SIZE)
        // MRAC for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16);
            d_15_index_hash_call_1.apply(DSTIP, ig_md.d_15_index1_16);
            update_15_1.apply(ig_md.d_15_base_16, ig_md.d_15_index1_16);
        //

        // MRAC for inst 16
            d_16_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_16_base_16);
            d_16_index_hash_call_1.apply(DSTIP, ig_md.d_16_index1_16);
            update_16_1.apply(ig_md.d_16_base_16, ig_md.d_16_index1_16);
        //

        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_9_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_14_above_threshold == 1
        ) {
            heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_dstip); 
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