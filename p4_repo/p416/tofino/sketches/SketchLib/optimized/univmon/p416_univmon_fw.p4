#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"

struct metadata_t {
    bit<16> sampling_hash_value;
    bit<16> level;
    bit<16> base;
    bit<32> threshold;

    bit<16> index_1;
    bit<16> index_2;
    bit<16> index_3;
    bit<16> index_4;
    bit<16> index_5;

    // bit<5> res_all;
    bit<16> res_all;
    bit<1> res_1;
    bit<1> res_2;
    bit<1> res_3;
    bit<1> res_4;
    bit<1> res_5;

    bit<32> est_1;
    bit<32> est_2;
    bit<32> est_3;
    bit<32> est_4;
    bit<32> est_5;

    bit<16> base_1;
    bit<16> base_2;
    bit<16> base_3;
    bit<16> base_4;
    bit<16> base_5;

    bit<16> mem_index_1;
    bit<16> mem_index_2;
    bit<16> mem_index_3;
    bit<16> mem_index_4;
    bit<16> mem_index_5;

    bit<1> c_1;
    bit<1> c_2;
    bit<1> c_3;
    bit<1> c_4;
    bit<1> c_5;

    bit<1> above_threshold;

    bit<1> is_ext_lb;
    bit<1> is_ext_fw;
}

#include "parser.p4"

#include "API_common.p4"
#include "API_O1_hash.p4"
#include "API_O2_hash.p4"
#include "API_O3_tcam.p4"
#include "API_O5_salu.p4"
#include "API_O6_flowkey.p4"

control FW(inout header_t hdr,
            inout metadata_t ig_md,
            in ingress_intrinsic_metadata_t ig_intr_md) {
    /***************************** set IF info and others  **************************/
    action set_if_info(bit<1> is_ext) {
        ig_md.is_ext_fw = is_ext; // 0: internal, 1: external
    }
    table if_info {
        key = { 
            ig_intr_md.ingress_port: exact;
        }
        actions = {set_if_info; }
        // default_action = drop();     
    }
    /***************************** Firewall control *****************************************/
    action fwTcp_learn() {
        // ig_tm_md.ucast_egress_port = CPU_PORT;
        // hdr.cpu_ethernet.setValid();
        // hdr.cpu_ethernet.dst_addr   = 0xFFFFFFFFFFFF;
        // hdr.cpu_ethernet.src_addr   = 0xAAAAAAAAAAAA;
        // hdr.cpu_ethernet.ether_type = ETHERTYPE_TO_CPU;
    }

    table fw_ext_to_int {
	    key = { 
            hdr.ipv4.src_addr: exact;
            hdr.ipv4.dst_addr: exact;
            hdr.tcp.src_port: exact;
            hdr.tcp.dst_port: exact;
        }
        actions = { NoAction;  }
        // default_action = drop();
    }
    
    /************** forwarding ipv4 ******************/
          
    action set_nhop(bit<9> port){
        // ig_tm_md.ucast_egress_port = port;
    }
    
    table ipv4_lpm {
        key = {hdr.ipv4.dst_addr : lpm;}  
        actions = { set_nhop; }
    }
    
    apply {
        if(hdr.ipv4.isValid() && hdr.tcp.isValid()) {
            if(if_info.apply().hit) { // check whether the pkt comes from internal or external
                if(ig_md.is_ext_fw == 0){ // from internal
                    if (hdr.tcp.flags == 1) {
                        fwTcp_learn();
                    } else {
                        ipv4_lpm.apply();
                    }
                } else { // from external 
                    if (fw_ext_to_int.apply().hit) {
                        ipv4_lpm.apply();
                    }
                } 
            } 
        }
    }
}

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    lpm_optimization() tcam;

    HASH_COMPUTE_SRCIP_16_16(32w0x790900f3) sampling_hash;
    hash_consolidate_and_split_srcip(32w0x5b445b31) res_split;
    HASH_COMPUTE_SRCIP_16_11(32w0x30243f0b) index_hash_1;
    HASH_COMPUTE_SRCIP_16_11(32w0x0f79f523) index_hash_2;
    HASH_COMPUTE_SRCIP_16_11(32w0x6b8cb0c5) index_hash_3;
    HASH_COMPUTE_SRCIP_16_11(32w0x00390fc3) index_hash_4;
    HASH_COMPUTE_SRCIP_16_11(32w0x298ac673) index_hash_5;

    consolidate_update_univmon() update_1;
    consolidate_update_univmon() update_2;
    consolidate_update_univmon() update_3;
    consolidate_update_univmon() update_4;
    consolidate_update_univmon() update_5;

    heavy_flowkey_storage() store_flowkey;

    FW() fw_1;

    apply {

        if(hdr.ethernet.ether_type == ETHERTYPE_IPV4) {
            sampling_hash.apply(hdr.ipv4.src_addr, ig_md.sampling_hash_value);
            // l3_2.apply(hdr);
            fw_1.apply(hdr, ig_md, ig_intr_md);
            // lb_2.apply(hdr, ig_md, ig_intr_md);
            tcam.apply(ig_md.sampling_hash_value, ig_md.level, ig_md.base, ig_md.threshold);

            // l3_3.apply(hdr);
            // lb_3.apply(hdr, ig_md, ig_intr_md);
            res_split.apply(hdr.ipv4.src_addr, ig_md.res_all,
                            ig_md.res_1,
                            ig_md.res_2,
                            ig_md.res_3,
                            ig_md.res_4,
                            ig_md.res_5);

            // l3_4.apply(hdr);
            index_hash_1.apply(hdr.ipv4.src_addr, ig_md.index_1);
            index_hash_2.apply(hdr.ipv4.src_addr, ig_md.index_2);
            index_hash_3.apply(hdr.ipv4.src_addr, ig_md.index_3);
            index_hash_4.apply(hdr.ipv4.src_addr, ig_md.index_4);
            index_hash_5.apply(hdr.ipv4.src_addr, ig_md.index_5);

            if ((bit<10>)ig_md.level <= 16) {
                #if ROW >= 1
                    update_1.apply(ig_md.index_1, ig_md.res_1, ig_md.level, ig_md.base_1, ig_md.mem_index_1, ig_md.est_1);
                #endif

                #if ROW >= 2
                update_2.apply(ig_md.index_2, ig_md.res_2, ig_md.level, ig_md.base_2, ig_md.mem_index_2, ig_md.est_2);
                #endif

                #if ROW >= 3
                update_3.apply(ig_md.index_3, ig_md.res_3, ig_md.level, ig_md.base_3, ig_md.mem_index_3, ig_md.est_3);
                #endif

                #if ROW >= 4
                update_4.apply(ig_md.index_4, ig_md.res_4, ig_md.level, ig_md.base_4, ig_md.mem_index_4, ig_md.est_4);
                #endif

                #if ROW >= 5
                update_5.apply(ig_md.index_5, ig_md.res_5, ig_md.level, ig_md.base_5, ig_md.mem_index_5, ig_md.est_5);
                #endif

                store_flowkey.apply(hdr, ig_md, ig_tm_md);
            }
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
