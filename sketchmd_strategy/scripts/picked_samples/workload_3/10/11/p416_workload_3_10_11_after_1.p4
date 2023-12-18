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
    bit<16> epoch_index;
    bit<32> epoch_count;
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> hf_srcip;
    bit<32> hf_dstip;
    bit<16> hf_srcport;
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
INIT_HEAVY_FLOWKEY_STORAGE_CONFIG_210(16384, 14, 16384)

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

// SAMPLING: 32w0x790900f3
// RES: 32w0x5b445b31
// set1 = [
// "32w0x30243f0b",
// "32w0x0f79f523",
// "32w0x6b8cb0c5",
// "32w0x00390fc3",
// "32w0x298ac673",
// "32w0x60180d91"]


    // O1 hash init
        COMPUTE_HASH_100_32_32(32w0x790900f3) d_1_auto_sampling_hash_call;

        COMPUTE_HASH_100_32_32(32w0x790900f3) d_2_auto_sampling_hash_call;

        COMPUTE_HASH_200_16_16(32w0x790900f3) d_4_auto_sampling_hash_call;

        COMPUTE_HASH_110_16_16(32w0x790900f3) d_5_auto_sampling_hash_call;

        COMPUTE_HASH_110_32_32(32w0x790900f3) d_6_auto_sampling_hash_call;

    //

    T4_INIT_1_WITH_POLY( 1, 100, 16384, 32w0x790900f3, 32w0x30243f0b)
    T4_INIT_1_WITH_POLY( 2, 100, 4096, 32w0x790900f3, 32w0x30243f0b)

    // apply SALUMerge; big - UnivMon / small - many MRACs 
        UM_INIT_SETUP_WITH_POLY(4, 200, 32w0x790900f3, 32w0x5b445b31, 32w0x60180d91)
        ABOVE_THRESHOLD_3() d_4_above_threshold;
        COMPUTE_HASH_200_16_11(32w0x30243f0b) d_4_index_hash_call_1;
        T3_T2_INDEX_UPDATE_32768() update_4_1;
        COMPUTE_HASH_200_16_11(32w0x0f79f523) d_4_index_hash_call_2;
        T3_INDEX_UPDATE_32768() update_4_2;
        COMPUTE_HASH_200_16_11(32w0x6b8cb0c5) d_4_index_hash_call_3;
        T3_INDEX_UPDATE_32768() update_4_3;
    // 

    UM_INIT_4_WITH_POLY( 5, 110, 11, 32768, 32w0x790900f3, 32w0x5b445b31, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673)


    // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
        TCAM_LPM_HLLPCSA() d_7_tcam_lpm;
        GET_BITMASK() d_7_get_bitmask;
        T5_T2_KEY_UPDATE_110_16384(32w0x30243f0b) update_7_1;
        T2_KEY_UPDATE_110_16384(32w0x0f79f523) update_7_2;
    //


    // apply O2
        T1_KEY_UPDATE_220_131072(32w0x30243f0b) update_8_1;
        T1_KEY_UPDATE_220_131072(32w0x0f79f523) update_8_2;
        T1_KEY_UPDATE_220_131072(32w0x6b8cb0c5) update_8_3;
    // 

    T2_INIT_5_WITH_POLY(10, 221, 4096, 32w0x30243f0b, 32w0x0f79f523, 32w0x6b8cb0c5, 32w0x00390fc3, 32w0x298ac673)

    HEAVY_FLOWKEY_STORAGE_CONFIG_210(32w0x60180d91) heavy_flowkey_storage;

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;
    action init() {
        ig_md.hf_srcip = -1;
        ig_md.hf_dstip = -1;
        ig_md.hf_srcport = -1;
        ig_md.d_4_above_threshold = 0;
        ig_md.d_5_above_threshold = 0;
    }


    apply {
        if (hdr.tcp.isValid() || hdr.udp.isValid()) {
            init();
            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.epoch_count);
            if(ig_md.epoch_count == 1) {
                ig_dprsr_md.digest_type = SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE;
            }
            // O1 hash run
                d_1_auto_sampling_hash_call.apply(SRCIP, ig_md.d_1_sampling_hash_32);

                d_2_auto_sampling_hash_call.apply(DSTIP, ig_md.d_2_sampling_hash_32);

                d_4_auto_sampling_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_sampling_hash_16);

                d_5_auto_sampling_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_sampling_hash_16);

                d_6_auto_sampling_hash_call.apply(DSTIP, DSTPORT, ig_md.d_6_sampling_hash_32);

            //

            // UnivMon for inst 5
                d_5_res_hash_call.apply(SRCIP, SRCPORT, ig_md.d_5_res_hash); 
                d_5_tcam_lpm.apply(ig_md.d_5_sampling_hash_16, ig_md.d_5_base_16, ig_md.d_5_threshold); 
                d_5_index_hash_call_1.apply(SRCIP, SRCPORT, ig_md.d_5_index1_16); 
                d_5_index_hash_call_2.apply(SRCIP, SRCPORT, ig_md.d_5_index2_16); 
                d_5_index_hash_call_3.apply(SRCIP, SRCPORT, ig_md.d_5_index3_16); 
                d_5_index_hash_call_4.apply(SRCIP, SRCPORT, ig_md.d_5_index4_16); 
                UM_RUN_END_4(5, ig_md.d_5_res_hash, 1) 
                RUN_HEAVY_FLOWKEY_NOIF_4(5) 
            //



            // HLL for inst 1
                d_1_tcam_lpm.apply(ig_md.d_1_sampling_hash_32, ig_md.d_1_level);
                update_1_1.apply(SRCIP, ig_md.d_1_level);
            //

            // HLL for inst 2
                d_2_tcam_lpm.apply(ig_md.d_2_sampling_hash_32, ig_md.d_2_level);
                update_2_1.apply(DSTIP, ig_md.d_2_level);
            //

            // apply SALUMerge; big - PCSA or ENT / small - ENT/CM/Kary, CS, PCSA 
                d_7_tcam_lpm.apply(ig_md.d_6_sampling_hash_32, ig_md.d_7_level);
                d_7_get_bitmask.apply(ig_md.d_7_level, ig_md.d_7_bitmask);
                update_7_1.apply(DSTIP, DSTPORT, 1, ig_md.d_7_bitmask, ig_md.d_7_est_1);
                update_7_2.apply(DSTIP, DSTPORT, 1, ig_md.d_7_est_2);
            //


            // apply SALUMerge; big - UnivMon / small - many MRACs 
            d_4_res_hash_call.apply(SRCIP, DSTIP, ig_md.d_4_res_hash);
            d_4_tcam_lpm.apply(ig_md.d_4_sampling_hash_16, ig_md.d_4_base_16,ig_md.d_4_threshold);
            d_4_index_hash_call_1.apply(SRCIP, DSTIP, ig_md.d_4_index1_16);
            update_4_1.apply(ig_md.d_4_base_16, ig_md.d_4_index1_16, ig_md.d_4_res_hash[0:0], 1, ig_md.d_4_est_1);
            d_4_index_hash_call_2.apply(SRCIP, DSTIP, ig_md.d_4_index2_16);
            update_4_2.apply(ig_md.d_4_base_16, ig_md.d_4_index2_16, ig_md.d_4_res_hash[1:1], 1, ig_md.d_4_est_2);
            d_4_index_hash_call_3.apply(SRCIP, DSTIP, ig_md.d_4_index3_16);
            update_4_3.apply(ig_md.d_4_base_16, ig_md.d_4_index3_16, ig_md.d_4_res_hash[2:2], 1, ig_md.d_4_est_3);
            RUN_HEAVY_FLOWKEY_NOIF_3(4)
            // 

            // apply O2
            T1_RUN_3_KEY_4(8, SRCIP, DSTIP, SRCPORT, DSTPORT) if (ig_md.d_8_est1_1 == 0 || ig_md.d_8_est1_2 == 0 || ig_md.d_8_est1_3 == 0) { /* process_new_flow() */ }
            // 

            T2_RUN_5_KEY_5(10, SRCIP, DSTIP, SRCPORT, DSTPORT, PROTO, 1)
            if(
            ig_md.d_4_above_threshold == 1
            || ig_md.d_5_above_threshold == 1
            ) {
                ig_md.hf_srcip = SRCIP; 
            }
            if(
            ig_md.d_4_above_threshold == 1
            ) {
                ig_md.hf_dstip = DSTIP; 
            }
            if(
            ig_md.d_5_above_threshold == 1
            ) {
                ig_md.hf_srcport = SRCPORT; 
            }
            if(
            ig_md.d_4_above_threshold == 1
            || ig_md.d_5_above_threshold == 1
            ) {
                heavy_flowkey_storage.apply(ig_dprsr_md,ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport); 
            }
        }
    }
}

struct heavy_flowkey_digest_t {
    bit<16> epoch_index;
    bit<32> epoch_count;
    bit<32> src_addr;
    bit<32> dst_addr;
    bit<16> src_port;
}

control SwitchIngressDeparserDigest(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Digest<heavy_flowkey_digest_t>() heavy_flowkey_digest;
    apply {
        if (ig_dprsr_md.digest_type == SKETCHMD_HEAVY_FLOWKEY_DIGEST_TYPE) {
            heavy_flowkey_digest.pack({ig_md.epoch_index, ig_md.epoch_count, ig_md.hf_srcip, ig_md.hf_dstip, ig_md.hf_srcport});
        }
        pkt.emit(hdr);
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
    SwitchIngressDeparserDigest(),
    EgressParser(),
    EmptyEgress(),
    EgressDeparser()
) pipe;
Switch(pipe) main;