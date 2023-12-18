#include <core.p4>
#include <tna.p4>

#include "headers.p4"

/*************************************************************************
 ************* C O N S T A N T S    A N D   T Y P E S  *******************
**************************************************************************/

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/


header ts_h {
    bit<32> start_hi;
    bit<16> start_lo;
    bit<32> end_hi;
    bit<16> end_lo;
}


struct my_ingress_headers_t {
    ethernet_h   ethernet;
    vlan_tag_h   vlan_tag;
    ipv4_h       ipv4;
    tcp_h        tcp;
    udp_h        udp;
    ts_h	 ts;
}

    /******  G L O B A L   I N G R E S S   M E T A D A T A  *********/

struct my_ingress_metadata_t {
    bool  ipv4_checksum_err;
}

    /***********************  P A R S E R  **************************/
parser IngressParser(packet_in        pkt,
    /* User */    
    out my_ingress_headers_t          hdr,
    out my_ingress_metadata_t         meta,
    /* Intrinsic */
    out ingress_intrinsic_metadata_t  ig_intr_md)
{
    Checksum() ipv4_checksum;

    /* This is a mandatory state, required by Tofino Architecture */
     state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        meta.ipv4_checksum_err = false;
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
	transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
	    default: accept;
	}
    }
   
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
	transition select(hdr.ipv4.protocol) {
            IP_PROTOCOLS_UDP: parse_udp;
	    default: accept;
	}
    }

    state parse_udp { 
	pkt.extract(hdr.udp);
	transition select(hdr.udp.src_port) {
	     9000: parse_ts;
	     default: accept;
	}
    }

    state parse_ts {
	pkt.extract(hdr.ts);
	transition accept;
    }
}

    /***************** M A T C H - A C T I O N  *********************/

control Ingress(
    /* User */
    inout my_ingress_headers_t                       hdr,
    inout my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md)
{

    action drop() {
        ig_dprsr_md.drop_ctl = 1;
    }
    
    action set_egr(bit<9> port){
        ig_tm_md.ucast_egress_port = port;
    }
    
	action set_default_egr(){
        ig_tm_md.ucast_egress_port = 144;
    }

    table forward {
        key = { 
            hdr.ethernet.dst_addr : exact;
        }
        actions = { set_egr; set_default_egr; NoAction; }
        const default_action = NoAction();
        //const default_action = set_default_egr();
    }
    
    
    apply {
	// For netronome latency measurement
	if (hdr.ts.isValid() && ig_intr_md.ingress_port == 60) { // beluga13 (netro)
		hdr.ts.end_hi = ig_prsr_md.global_tstamp[47:16];
		hdr.ts.end_lo = ig_prsr_md.global_tstamp[15:0];
	}
        forward.apply();
    }
}

    /*********************  D E P A R S E R  ************************/
control IngressDeparser(packet_out pkt,
    /* User */
    inout my_ingress_headers_t                       hdr,
    in    my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md)
{
    apply {
        pkt.emit(hdr);
    }
}


/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

    /***********************  H E A D E R S  ************************/

struct my_egress_headers_t {
    ethernet_h   ethernet;
    vlan_tag_h   vlan_tag;
    ipv4_h       ipv4;
    tcp_h        tcp;
    udp_h        udp;
    ts_h	 ts;
}

    /********  G L O B A L   E G R E S S   M E T A D A T A  *********/

struct my_egress_metadata_t {
}

    /***********************  P A R S E R  **************************/

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
        transition parse_ethernet;
    }
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
	transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
	    default: accept;
	}
    }
   
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
	transition select(hdr.ipv4.protocol) {
            IP_PROTOCOLS_UDP: parse_udp;
	    default: accept;
	}
    }

    state parse_udp { 
	pkt.extract(hdr.udp);
	transition select(hdr.udp.src_port) {
	     9000: parse_ts;
	     default: accept;
	}
    }

    state parse_ts {
	pkt.extract(hdr.ts);
	transition accept;
    }
}

    /***************** M A T C H - A C T I O N  *********************/

control Egress(
    /* User */
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    /* Intrinsic */    
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_oport_md)
{
    apply {
	// For netronome latency measurement
	if (hdr.ts.isValid() && eg_intr_md.egress_port == 60) { // beluga13 (netro)
		hdr.ts.start_hi = eg_prsr_md.global_tstamp[47:16];
		hdr.ts.start_lo = eg_prsr_md.global_tstamp[15:0];
	}
    }
}

    /*********************  D E P A R S E R  ************************/

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

/************ F I N A L   P A C K A G E ******************************/
Pipeline(
    IngressParser(),
    Ingress(),
    IngressDeparser(),
    EgressParser(),
    Egress(),
    EgressDeparser()
) pipe;

Switch(pipe) main;
