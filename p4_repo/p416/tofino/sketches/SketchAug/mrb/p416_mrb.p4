#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

struct metadata_t {
    bit<16> epoch_index;
    bit<16> temp_index;

    bit<15> sampling_hash_value;
    // bit<4> input_level; // 5 bit is enough (2^5 = 32 > 20)
    bit<16> level; // 5 bit is enough (2^5 = 32 > 20)
    bit<16> index; // 11 bit is enough (2^11 = 2048)

    bit<16> index_shift_8;
    bit<16> index_shift_9;
    bit<16> index_shift_10;
    bit<16> index_shift_11;
    bit<16> index_shift_12;

    bit<16> total_hash;

    bit<16> hash_8;
    bit<16> hash_9;
    bit<16> hash_10;
    bit<16> hash_11;
    bit<16> hash_12;

    // bit<8> hash_8;
    // bit<9> hash_9;
    // bit<10> hash_10;
    // bit<11> hash_11;
    // bit<12> hash_12;

    bit<16> index_4096;
    bit<16> index_8192;
    bit<16> index_16384;
    bit<16> index_32768;
    bit<16> index_65536;
}

#include "headers.p4"
#include "util.p4"
#include "parser.p4"

#include "API_hash.p4"
#include "API_tcam.p4"
#include "API_salu.p4"
#include "API_debug.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // EPOCH_COUNT() epoch_count;

    EPOCH_COUNT_1() epoch_count_1;
    EPOCH_COUNT_2() epoch_count_2;

    HASH_COMPUTE_15_15(32w0x790900f3) sampling_hash;
    MRB_TCAM() tcam;

    MRB_UPDATE_4096() update_4096; // 256 * 16
    MRB_UPDATE_8192() update_8192; // 512 * 16
    MRB_UPDATE_16384() update_16384; // 1024 * 16
    MRB_UPDATE_32768() update_32768; // 2048 * 16
    MRB_UPDATE_65536() update_65536; // 4096 * 16
    // HASH_COMPUTE_16_16(32w0x30243f0b) index_hash;


    HASH_COMPUTE_8_16(32w0x30243f0b) index_hash_8;
    HASH_COMPUTE_9_16(32w0x30243f0b) index_hash_9;
    HASH_COMPUTE_10_16(32w0x30243f0b) index_hash_10;
    HASH_COMPUTE_11_16(32w0x30243f0b) index_hash_11;
    HASH_COMPUTE_12_16(32w0x30243f0b) index_hash_12;


    action bitmask() {
        ig_md.index_shift_8 = (ig_md.level << 8);
        ig_md.index_shift_9 = (ig_md.level << 9);
        ig_md.index_shift_10 = (ig_md.level << 10);
        ig_md.index_shift_11 = (ig_md.level << 11);
        ig_md.index_shift_12 = (ig_md.level << 12);
    }

    action add() {
        ig_md.index_4096 = ig_md.index_shift_8 + ig_md.hash_8;
        ig_md.index_8192 = ig_md.index_shift_9 + ig_md.hash_9;
        ig_md.index_16384 = ig_md.index_shift_10 + ig_md.hash_10;
        ig_md.index_32768 = ig_md.index_shift_11 + ig_md.hash_11;
        ig_md.index_65536 = ig_md.index_shift_12 + ig_md.hash_12;
    }

    
    apply {

        if(hdr.vlan_tag.isValid() && hdr.vlan_tag.ether_type == ETHERTYPE_IPV4) {
        // if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {

            epoch_count_1.apply(ig_md.epoch_index);
            epoch_count_2.apply(ig_md.epoch_index, ig_md.temp_index);

            sampling_hash.apply(hdr.ipv4.src_addr, ig_md.sampling_hash_value);
            tcam.apply(ig_md.sampling_hash_value, ig_md.level);

            index_hash_8.apply(hdr.ipv4.src_addr, ig_md.hash_8);
            index_hash_9.apply(hdr.ipv4.src_addr, ig_md.hash_9);
            index_hash_10.apply(hdr.ipv4.src_addr, ig_md.hash_10);
            index_hash_11.apply(hdr.ipv4.src_addr, ig_md.hash_11);
            index_hash_12.apply(hdr.ipv4.src_addr, ig_md.hash_12);

            bitmask();
            add();

            update_4096.apply(ig_md.index_4096);
            update_8192.apply(ig_md.index_8192);
            update_16384.apply(ig_md.index_16384);
            update_32768.apply(ig_md.index_32768);
            update_65536.apply(ig_md.index_65536);
        }
    }
}

struct my_egress_headers_t {
}

    /********  G L O B A L   E G R E S S   M E T A D A T A  *********/

struct my_egress_metadata_t {
}

parser EgressParser(packet_in        pkt,
    /* User */
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}

control EgressDeparser(packet_out pkt,
    /* User */
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    /* Intrinsic */
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

        // index_hash.apply(hdr.ipv4.src_addr, ig_md.total_hash);

        // ig_md.hash_8 = (bit<8>) ig_md.total_hash;
        // ig_md.hash_9 = (bit<9>) ig_md.total_hash;
        // ig_md.hash_10 = (bit<10>) ig_md.total_hash;
        // ig_md.hash_11 = (bit<11>) ig_md.total_hash;
        // ig_md.hash_12 = (bit<12>) ig_md.total_hash;

        // ig_md.index_4096 = ig_md.index_shift_8 + (bit<16>)ig_md.hash_8;
        // ig_md.index_8192 = ig_md.index_shift_9 + (bit<16>)ig_md.hash_9;
        // ig_md.index_16384 = ig_md.index_shift_10 + (bit<16>)ig_md.hash_10;
        // ig_md.index_32768 = ig_md.index_shift_11 + (bit<16>)ig_md.hash_11;
        // ig_md.index_65536 = ig_md.index_shift_12 + (bit<16>)ig_md.hash_12;
