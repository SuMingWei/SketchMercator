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
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_200(65536, 16, 30720)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_19_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x30244f0b) d_20_auto_sampling_hash_call;

    //

    T1_INIT_1( 1, 200, 262144)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_5(100) d_8_above_threshold;
        COMPUTE_HASH_200_32_32(32w0x30244f0b) d_8_hash_call;
        TCAM_LPM_HLLPCSA() d_8_tcam_lpm;
        GET_BITMASK() d_8_get_bitmask;
        T2_T5_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_4;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_5;
    //


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_3_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_3_4;
        ABOVE_THRESHOLD_CONSTANT_4(100) d_3_above_threshold;
    // 

    T3_INIT_HH_1( 9, 200, 4096)
    T2_INIT_HH_1(10, 200, 16384)

    // apply O2
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_4_1;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_4_2;
        T2_KEY_UPDATE_200_4096(32w0x30243f0b) update_4_3;
        ABOVE_THRESHOLD_CONSTANT_3(100) d_4_above_threshold;
    // 


    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_1;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_2;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_3;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_4;
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_6_5;
        ABOVE_THRESHOLD_CONSTANT_5(100) d_6_above_threshold;
    // 

    T2_INIT_HH_5(16, 200, 4096)

    // apply O2
        T2_KEY_UPDATE_200_16384(32w0x30243f0b) update_7_1;
        ABOVE_THRESHOLD_CONSTANT_1(100) d_7_above_threshold;
    // 

    T2_INIT_HH_3(11, 200, 8192)
    MRAC_INIT_1(17, 200, 16384, 11,  8)
    UM_INIT_5(18, 200, 11, 32768)
    UM_INIT_4(19, 200, 11, 32768)
    UM_INIT_5(20, 200, 11, 32768)

    HEAVY_FLOWKEY_STORAGE_CONFIG_200(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_2_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_2_sampling_hash_32);

            d_17_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_17_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_18_sampling_hash_16);

            d_19_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_19_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_20_sampling_hash_16);

        //

        T1_RUN_1_KEY_2( 1, SRCIP, DSTIP) if (ig_md.d_1_est1_1 == 0) { /* process_new_flow() */ }
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            d_8_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_8_level);
            d_8_get_bitmask.apply(ig_md.d_8_level, ig_md.d_8_bitmask);
            update_8_1.apply(SRCIP, DSTIP, SIZE, ig_md.d_8_bitmask, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, SIZE, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, SIZE, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, SIZE, ig_md.d_8_est_4);
            update_8_5.apply(SRCIP, DSTIP, SIZE, ig_md.d_8_est_5);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_5(8)
        //


        // apply O2
        T2_RUN_AFTER_4_KEY_2(3, SRCIP, DSTIP, 1)
        // 

        T3_RUN_AFTER_1_KEY_2( 9, SRCIP, DSTIP, SIZE)
        T2_RUN_AFTER_1_KEY_2(10, SRCIP, DSTIP, 1)

        // apply O2
        T2_RUN_AFTER_3_KEY_2(4, SRCIP, DSTIP, SIZE)
        // 


        // apply O2
        T2_RUN_AFTER_5_KEY_2(6, SRCIP, DSTIP, 1)
        // 

        T2_RUN_AFTER_5_KEY_2(16, SRCIP, DSTIP, SIZE)

        // apply O2
        T2_RUN_AFTER_1_KEY_2(7, SRCIP, DSTIP, SIZE)
        // 

        T2_RUN_AFTER_3_KEY_2(11, SRCIP, DSTIP, 1)
        // MRAC for inst 17
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16);
            d_17_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_17_index1_16);
            update_17_1.apply(ig_md.d_17_base_16, ig_md.d_17_index1_16);
        //

        // UnivMon for inst 18
            d_18_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_18_res_hash); 
            d_18_tcam_lpm.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16, ig_md.d_18_threshold); 
            d_18_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_18_index1_16); 
            d_18_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_18_index2_16); 
            d_18_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_18_index3_16); 
            d_18_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_18_index4_16); 
            d_18_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_18_index5_16); 
            UM_RUN_END_5(18, ig_md.d_18_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_5(18) 
        //

        // UnivMon for inst 19
            d_19_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_19_res_hash); 
            d_19_tcam_lpm.apply(ig_md.d_19_sampling_hash_16, ig_md.d_19_base_16, ig_md.d_19_threshold); 
            d_19_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_19_index1_16); 
            d_19_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_19_index2_16); 
            d_19_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_19_index3_16); 
            d_19_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_19_index4_16); 
            UM_RUN_END_4(19, ig_md.d_19_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(19) 
        //

        // UnivMon for inst 20
            d_20_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_20_res_hash); 
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_16, ig_md.d_20_base_16, ig_md.d_20_threshold); 
            d_20_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_20_index1_16); 
            d_20_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_20_index2_16); 
            d_20_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_20_index3_16); 
            d_20_index_hash_call_4.apply(SRCIP, DSTIP, ig_md.d_20_index4_16); 
            d_20_index_hash_call_5.apply(SRCIP, DSTIP, ig_md.d_20_index5_16); 
            UM_RUN_END_5(20, ig_md.d_20_res_hash, SIZE) 
            RUN_HEAVY_FLOWKEY_NOIF_5(20) 
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_3_above_threshold == 1
        || ig_md.d_9_above_threshold == 1
        || ig_md.d_10_above_threshold == 1
        || ig_md.d_4_above_threshold == 1
        || ig_md.d_6_above_threshold == 1
        || ig_md.d_16_above_threshold == 1
        || ig_md.d_7_above_threshold == 1
        || ig_md.d_11_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_19_above_threshold == 1
        || ig_md.d_20_above_threshold == 1
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