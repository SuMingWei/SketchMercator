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

    bit<1> is_ext;
}

#include "parser.p4"

#include "API_common.p4"
#include "API_O1_hash.p4"
#include "API_O2_hash.p4"
#include "API_O3_tcam.p4"
#include "API_O5_salu.p4"
#include "API_O6_flowkey.p4"

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    // action drop() {
    //     ig_dprsr_md.drop_ctl = 1;
    // }

    // Load balancer
    /***************************** set IF info and others  **************************/
    action set_if_info(bit<1> is_ext) {
        ig_md.is_ext = is_ext; // 0: internal, 1: external
    }
    table if_info {
        key = { 
            ig_intr_md.ingress_port: exact;
        }
        actions = {set_if_info; }
        // default_action = drop();     
    }
    /***************************** LB control *****************************************/
    action lb_hit_int_to_ext(bit<32> front_addr) { 
        // hdr.ipv4.src_addr = front_addr;
    }
    table lb_int_to_ext {
        key = { 
            hdr.ipv4.src_addr: exact; 
            hdr.ipv4.dst_addr: exact; 
            hdr.tcp.src_port: exact; 
            hdr.tcp.dst_port: exact;
        }
        actions = {lb_hit_int_to_ext; }
        size = 32768;
        // default_action = drop();     
    }

    action lb_hit_ext_to_int(bit<32> back_addr) {
        // hdr.ipv4.dst_addr = back_addr;
    }

    table lb_ext_to_int {
	    key = { 
            hdr.ipv4.src_addr: exact; 
            hdr.ipv4.dst_addr: exact; 
            hdr.tcp.src_port: exact; 
            hdr.tcp.dst_port: exact;
        }
        actions = {lb_hit_ext_to_int;}
        size = 32768;
        // default_action = drop();
    }
    
    action lbTCP_learn() {
        // ig_tm_md.ucast_egress_port = CPU_PORT;
    }
    
    action set_nhop_lb(bit<9> port){
        // ig_tm_md.ucast_egress_port = port;
        // hdr.cpu_ethernet.setValid();
        // hdr.cpu_ethernet.dst_addr   = 0xFFFFFFFFFFFF;
        // hdr.cpu_ethernet.src_addr   = 0xAAAAAAAAAAAA;
        // hdr.cpu_ethernet.ether_type = ETHERTYPE_TO_CPU;
    }
    
    table ipv4_lpm_lb {
        key = {hdr.ipv4.dst_addr : lpm;}  
        actions = { set_nhop_lb; }
    }

    apply {
        if(hdr.ipv4.isValid() && hdr.tcp.isValid()) {
            if(if_info.apply().hit) { // check whether the pkt comes from internal or external
                if(ig_md.is_ext == 0){ // from internal
                    if (lb_int_to_ext.apply().hit) {
                        ipv4_lpm_lb.apply();
                    }
                } else { // from external
                    if (hdr.tcp.flags == 1) {
                        lbTCP_learn();
                    } else if (lb_ext_to_int.apply().hit) {
                        ipv4_lpm_lb.apply();
                    }
                } 
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
