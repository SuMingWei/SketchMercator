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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 12288)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_221_32_32(32w0x30244f0b) d_10_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_12_auto_sampling_hash_call;

    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_2(100) d_2_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_4;
    //

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_4_above_threshold;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_1;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_2;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_3;
        T2_T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_4_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_4_5;
    //

    MRAC_INIT_1( 5, 200, 32768, 11, 16)
    T2_INIT_HH_5( 6, 110, 8192)
    T3_INIT_HH_3( 7, 110, 16384)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_220_8192(32w0x30243f0b) update_8_5;
    //

    T4_INIT_1(10, 221, 65536)
    T2_INIT_HH_4(11, 221, 8192)
    UM_INIT_1(12, 221, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_5_sampling_hash_16);

            d_10_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_sampling_hash_32);

            d_12_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_sampling_hash_16);

        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_1_1.apply(DSTIP, 1, 1, ig_md.d_1_est_1);
            update_1_2.apply(DSTIP, 1, 1, ig_md.d_1_est_2);
            d_2_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_2_above_threshold);
            update_1_3.apply(DSTIP, 1, ig_md.d_1_est_3);
            update_1_4.apply(DSTIP, 1, ig_md.d_1_est_4);
        //

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_4_1.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_4_est_1);
            update_4_2.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_4_est_2);
            update_4_3.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_4_est_3);
            update_4_4.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_4_est_4);
            update_4_5.apply(SRCIP, DSTIP, 1, ig_md.d_4_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(4)
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        T2_RUN_AFTER_5_KEY_2( 6, SRCIP, SRCPORT, SIZE)
        T3_RUN_AFTER_3_KEY_2( 7, DSTIP, DSTPORT, SIZE)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_8_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, 1, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_8_est_4);
            update_8_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE, ig_md.d_8_est_5);
        //

        // HLL for inst 10
            d_10_tcam_lpm.apply(ig_md.d_10_sampling_hash_32, ig_md.d_10_level);
            update_10.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_10_level);
        //

        T2_RUN_AFTER_4_KEY_5(11, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // UnivMon for inst 12
            d_12_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_res_hash); 
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_16, ig_md.d_12_base_16, ig_md.d_12_threshold); 
            d_12_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_12_index1_16); 
            UM_RUN_END_1(12, ig_md.d_12_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_1(12) 
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_6_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_2_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
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