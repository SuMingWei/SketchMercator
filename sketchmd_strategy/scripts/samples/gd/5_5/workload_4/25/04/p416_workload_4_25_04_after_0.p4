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
    METADATA_DIM(23)
    METADATA_DIM(24)
    METADATA_DIM(25)
}
#include "parser.p4"
#include "all_include.p4"
#define SRCIP hdr.ipv4.src_addr
#define DSTIP hdr.ipv4.dst_addr
#define SRCPORT ig_md.src_port
#define DSTPORT ig_md.dst_port
#define PROTO hdr.ipv4.protocol
#define SIZE hdr.ipv4.total_len
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_221(16384, 14, 10240)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // O1 hash init
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_5_auto_sampling_hash_call;
        COMPUTE_HASH_100_16_16(32w0x30244f0b) d_6_auto_sampling_hash_call;
        action d_11_xor_construction() { ig_md.d_11_sampling_hash_16 = ig_md.d_5_sampling_hash_16 ^ ig_md.d_6_sampling_hash_16; }

        COMPUTE_HASH_110_32_32(32w0x30244f0b) d_12_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_14_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_18_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x30244f0b) d_17_auto_sampling_hash_call;

        COMPUTE_HASH_220_32_32(32w0x30244f0b) d_20_auto_sampling_hash_call;

        COMPUTE_HASH_220_16_16(32w0x30244f0b) d_22_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_25_auto_sampling_hash_call;

        COMPUTE_HASH_221_16_16(32w0x30244f0b) d_24_auto_sampling_hash_call;

    //


    // apply O2
        T1_KEY_UPDATE_100_524288(32w0x30243f0b) update_1_1;
        T1_KEY_UPDATE_100_524288(32w0x30243f0b) update_1_2;
    // 

    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        T2_T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_1;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_2;
        T2_KEY_UPDATE_100_8192(32w0x30243f0b) update_3_3;
    //

    MRAC_INIT_1( 5, 100, 32768, 11, 16)
    MRAC_INIT_1( 6, 100, 16384, 11,  8)
    T1_INIT_1( 7, 200, 131072)
    // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
        ABOVE_THRESHOLD_CONSTANT_4(100) d_8_above_threshold;
        T2_T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_1;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_2;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_3;
        T2_KEY_UPDATE_200_8192(32w0x30243f0b) update_8_4;
    //

    MRAC_INIT_1(11, 200, 32768, 11, 16)
    T4_INIT_1(12, 110, 32768)
    T2_INIT_2(13, 110, 16384)
    MRAC_INIT_1(14, 110, 32768, 11, 16)
    T1_INIT_3(15, 110, 262144)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(18, 110)
        ABOVE_THRESHOLD_2() d_18_above_threshold;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_18_1;
        COMPUTE_HASH_110_16_11(32w0x30244f0b) d_18_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_18_2;
    // 

    UM_INIT_2(17, 110, 10, 16384)
    T1_INIT_3(19, 220, 131072)
    T4_INIT_1(20, 220, 65536)
    T2_INIT_1(21, 220, 4096)
    MRAC_INIT_1(22, 220, 8192, 10,  8)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP(25, 221)
        ABOVE_THRESHOLD_2() d_25_above_threshold;
        COMPUTE_HASH_221_16_11(32w0x30244f0b) d_25_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_25_1;
        COMPUTE_HASH_221_16_10(32w0x30244f0b) d_25_index_hash_call_2;
        T3_INDEX_UPDATE_16384() update_25_2;
    // 

    UM_INIT_4(24, 221, 10, 16384)

    HEAVY_FLOWKEY_STORAGE_CONFIG_221(32w0x30243f0b) heavy_flowkey_storage;



    apply {
        // O1 hash run
            d_5_auto_sampling_hash_call.apply(SRCIP, ig_md.d_5_sampling_hash_16);
            d_6_auto_sampling_hash_call.apply(DSTIP, ig_md.d_6_sampling_hash_16);
            d_11_xor_construction();
            d_12_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_12_sampling_hash_32);

            d_14_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_14_sampling_hash_16);

            d_18_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_sampling_hash_16);

            d_17_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_sampling_hash_16);

            d_20_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_sampling_hash_32);

            d_22_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_sampling_hash_16);

            d_25_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_sampling_hash_16);

            d_24_auto_sampling_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_sampling_hash_16);

        //


        // apply O2
        T1_RUN_2_KEY_1(1, SRCIP) if (ig_md.d_1_est1_1 == 0 || ig_md.d_1_est1_2 == 0) { /* process_new_flow() */ }
        // 

        // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
            update_3_1.apply(SRCIP, SIZE, 1, ig_md.d_3_est_1);
            update_3_2.apply(SRCIP, SIZE, ig_md.d_3_est_2);
            update_3_3.apply(SRCIP, SIZE, ig_md.d_3_est_3);
        //

        // MRAC for inst 5
            d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16);
            d_5_index_hash_call_1.apply(SRCIP, ig_md.d_5_index1_16);
            update_5.apply(ig_md.d_5_base_16, ig_md.d_5_index1_16);
        //

        // MRAC for inst 6
            d_6_tcam_lpm.apply(ig_md.d_6_sampling_hash_16, ig_md.d_6_base_16);
            d_6_index_hash_call_1.apply(DSTIP, ig_md.d_6_index1_16);
            update_6.apply(ig_md.d_6_base_16, ig_md.d_6_index1_16);
        //

        T1_RUN_1_KEY_2( 7, SRCIP, DSTIP)
        // apply SALUMerge; big - CM/Kary/CS / small - Ent/PCSA 
            update_8_1.apply(SRCIP, DSTIP, 1, SIZE, ig_md.d_8_est_1);
            update_8_2.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_2);
            update_8_3.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_3);
            update_8_4.apply(SRCIP, DSTIP, 1, ig_md.d_8_est_4);
            RUN_HEAVY_FLOWKEY_CONSTANT_NOIF_4(8)
        //

        // MRAC for inst 11
            d_11_tcam_lpm.apply(ig_md.d_11_sampling_hash_16, ig_md.d_11_base_16);
            d_11_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_11_index1_16);
            update_11.apply(ig_md.d_11_base_16, ig_md.d_11_index1_16);
        //

        // HLL for inst 12
            d_12_tcam_lpm.apply(ig_md.d_12_sampling_hash_32, ig_md.d_12_level);
            update_12.apply(SRCIP, SRCPORT, ig_md.d_12_level);
        //

        T2_RUN_2_KEY_2(13, SRCIP, SRCPORT, SIZE)
        // MRAC for inst 14
            d_14_tcam_lpm.apply(ig_md.d_14_sampling_hash_16, ig_md.d_14_base_16);
            d_14_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_14_index1_16);
            update_14.apply(ig_md.d_14_base_16, ig_md.d_14_index1_16);
        //

        T1_RUN_3_KEY_2(15, DSTIP, DSTPORT) if (ig_md.d_15_est1_1 == 0 || ig_md.d_15_est1_2 == 0 || ig_md.d_15_est1_3 == 0) { /* process_new_flow() */ }

        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_18_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_18_res_hash);
        d_18_tcam_lpm_2.apply(ig_md.d_18_sampling_hash_16, ig_md.d_18_base_16_1024, ig_md.d_18_base_16_2048, ig_md.d_18_threshold);
        d_18_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_18_index1_16);
        update_18_1.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index1_16, ig_md.d_18_res_hash[1:1], SIZE, ig_md.d_18_est_1);
        d_18_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_18_index2_16);
        update_18_2.apply(ig_md.d_18_base_16_2048, ig_md.d_18_index2_16, ig_md.d_18_res_hash[2:2], SIZE, ig_md.d_18_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(18)
        // 

        // UnivMon for inst 17
            d_17_res_hash_call.apply(DSTIP, DSTPORT, ig_md.d_17_res_hash); 
            d_17_tcam_lpm.apply(ig_md.d_17_sampling_hash_16, ig_md.d_17_base_16, ig_md.d_17_threshold); 
            d_17_index_hash_call_1.apply(DSTIP, DSTPORT, ig_md.d_17_index1_16); 
            d_17_index_hash_call_2.apply(DSTIP, DSTPORT, ig_md.d_17_index2_16); 
            UM_RUN_END_2(17, ig_md.d_17_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_2(17) 
        //

        T1_RUN_3_KEY_4(19, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_19_est1_1 == 0 || ig_md.d_19_est1_2 == 0 || ig_md.d_19_est1_3 == 0) { /* process_new_flow() */ }
        // HLL for inst 20
            d_20_tcam_lpm.apply(ig_md.d_20_sampling_hash_32, ig_md.d_20_level);
            update_20.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_20_level);
        //

        T2_RUN_1_KEY_4(21, SRCIP, DSTIP, SRCPORT, DSTPORT, 1)
        // MRAC for inst 22
            d_22_tcam_lpm.apply(ig_md.d_22_sampling_hash_16, ig_md.d_22_base_16);
            d_22_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, ig_md.d_22_index1_16);
            update_22.apply(ig_md.d_22_base_16, ig_md.d_22_index1_16);
        //


        // apply SALUMerge; big - UnivMon / small - many MRACs 
        d_25_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_res_hash);
        d_25_tcam_lpm_2.apply(ig_md.d_25_sampling_hash_16, ig_md.d_25_base_16_1024, ig_md.d_25_base_16_2048, ig_md.d_25_threshold);
        d_25_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index1_16);
        update_25_1.apply(ig_md.d_25_base_16_2048, ig_md.d_25_index1_16, ig_md.d_25_res_hash[1:1], SIZE, ig_md.d_25_est_1);
        d_25_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_25_index2_16);
        update_25_2.apply(ig_md.d_25_base_16_1024, ig_md.d_25_index2_16, ig_md.d_25_res_hash[2:2], SIZE, ig_md.d_25_est_2);
        RUN_HEAVY_FLOWKEY_NOIF_2(25)
        // 

        // UnivMon for inst 24
            d_24_res_hash_call.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_res_hash); 
            d_24_tcam_lpm.apply(ig_md.d_24_sampling_hash_16, ig_md.d_24_base_16, ig_md.d_24_threshold); 
            d_24_index_hash_call_1.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index1_16); 
            d_24_index_hash_call_2.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index2_16); 
            d_24_index_hash_call_3.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index3_16); 
            d_24_index_hash_call_4.apply(SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, ig_md.d_24_index4_16); 
            UM_RUN_END_4(24, ig_md.d_24_res_hash, 1) 
            RUN_HEAVY_FLOWKEY_NOIF_4(24) 
        //

        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcip = SRCIP; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstip = DSTIP; 
        }
        if(
        ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_srcport = SRCPORT; 
        }
        if(
        ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_dstport = DSTPORT; 
        }
        if(
        ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
        ) {
            ig_md.hf_proto = PROTO; 
        }
        if(
        ig_md.d_8_above_threshold == 1
        || ig_md.d_18_above_threshold == 1
        || ig_md.d_17_above_threshold == 1
        || ig_md.d_25_above_threshold == 1
        || ig_md.d_24_above_threshold == 1
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