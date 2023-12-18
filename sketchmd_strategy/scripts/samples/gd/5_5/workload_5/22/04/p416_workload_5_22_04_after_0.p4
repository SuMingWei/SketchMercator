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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(32768, 15, 18432)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_15_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

    //

    T2_INIT_HH_3( 4, 100, 8192)
    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_2_4;
    //

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_5_above_threshold;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_1;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_2;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_3;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_4;
        T2_T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_1_5;
    //

    T1_INIT_1( 7, 100, 524288)
    T1_INIT_5( 6, 100, 524288)

    // apply O2
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_100_16384(32w0x30243f0b) update_8_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
    // 

    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_11_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_11_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_3;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_4;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_11_5;
    //


    // apply O2
        T2_KEY_UPDATE_110_8192(32w0x30243f0b) update_12_1;
        T2_KEY_UPDATE_110_4096(32w0x30243f0b) update_12_2;
        ABOVE_THRESHOLD_CONSTANT_2(100) d_12_above_threshold;
    // 

    T2_INIT_HH_5(13, 110, 8192)
    MRAC_INIT_1(15, 110, 16384, 11,  8)
    T1_INIT_4(16, 110, 262144)
    T2_INIT_5(17, 110, 4096)
    T2_INIT_HH_1(19, 220, 4096)
    T2_INIT_HH_3(18, 220, 4096)
    T1_INIT_2(20, 221, 262144)
    T2_INIT_5(21, 221, 16384)
    UM_INIT_5(22, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_15_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_15_sampling_hash_16);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_sampling_hash_16);

        //

        T2_RUN_AFTER_3_KEY_1( 4, SRCIP, 1)
        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_2_1.apply(SRCIP, SIZE, 1, ig_md.d_2_est_1);
            update_2_2.apply(SRCIP, SIZE, 1, ig_md.d_2_est_2);
            update_2_3.apply(SRCIP, SIZE, 1, ig_md.d_2_est_3);
            update_2_4.apply(SRCIP, SIZE, 1, ig_md.d_2_est_4);
        //

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_1_1.apply(SRCIP, SIZE, 1, ig_md.d_1_est_1);
            update_1_2.apply(SRCIP, SIZE, 1, ig_md.d_1_est_2);
            update_1_3.apply(SRCIP, SIZE, 1, ig_md.d_1_est_3);
            update_1_4.apply(SRCIP, SIZE, 1, ig_md.d_1_est_4);
            update_1_5.apply(SRCIP, SIZE, 1, ig_md.d_1_est_5);
            d_5_above_threshold.apply(ig_md.d_1_est_1, ig_md.d_1_est_2, ig_md.d_1_est_3, ig_md.d_1_est_4, ig_md.d_1_est_5, ig_md.d_5_above_threshold);
        //

        T1_RUN_1_KEY_1( 7, DSTIP)
        T1_RUN_5_KEY_1( 6, DSTIP) if (ig_md.d_6_est1_1 == 0 || ig_md.d_6_est1_2 == 0 || ig_md.d_6_est1_3 == 0 || ig_md.d_6_est1_4 == 0 || ig_md.d_6_est1_5 == 0) { /* process_new_flow() */ }

        // apply O2
        T2_RUN_AFTER_4_KEY_1(8, DSTIP, 1)
        // 

        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_11_1.apply(SRCIP, DSTIP, SIZE, 1, ig_md.d_11_est_1);
            update_11_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_est_2);
            update_11_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_est_3);
            update_11_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_est_4);
            update_11_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_11_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(11)
        //


        // apply O2
        T2_RUN_AFTER_2_KEY_2(12, SRCIP, SRCPORT, SIZE)
        // 

        T2_RUN_AFTER_5_KEY_2(13, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 15
            d_15_tcam_lpm.apply(ig_md.d_15_sampling_hash_16, ig_md.d_15_base_16);
            d_15_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_15_index1_16);
            update_15.apply(ig_md.d_15_base_16, ig_md.d_15_index1_16);
        //

        T1_RUN_4_KEY_2(16, DSTIP, DSTPORT) if (ig_md.d_16_est1_1 == 0 || ig_md.d_16_est1_2 == 0 || ig_md.d_16_est1_3 == 0 || ig_md.d_16_est1_4 == 0) { /* process_new_flow() */ }
        T2_RUN_5_KEY_2(17, DSTIP, DSTPORT, 1)
        T2_RUN_AFTER_1_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        T2_RUN_AFTER_3_KEY_4(18, SRCIP, DSTIP, SRCPORT, DSTPORT, SIZE)
        T1_RUN_2_KEY_5(20, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO) if (ig_md.d_20_est1_1 == 0 || ig_md.d_20_est1_2 == 0) { /* process_new_flow() */ }
        T2_RUN_5_KEY_5(21, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, SIZE)
        // UnivMon for inst 22
            d_22_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_res_hash); 
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16, ig_md.d_22_threshold); 
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index1_16); 
            d_22_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index2_16); 
            d_22_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index3_16); 
            d_22_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index4_16); 
            d_22_index_hash_call_5.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_22_index5_16); 
            UM_RUN_END_5(22, ig_md.d_22_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(22) 
        //

        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_22_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_4_above_threshold == 1
        || ig_md.d_5_above_threshold == 1
        || ig_md.d_8_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_12_above_threshold == 1
        || ig_md.d_13_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_22_above_threshold == 1
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